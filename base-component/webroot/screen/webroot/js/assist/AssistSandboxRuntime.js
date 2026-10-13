/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */
/*
 * Runs INSIDE the sandboxed frame that renders a generated (vue-sfc) Assist screen. The frame has an opaque origin
 * (sandbox="allow-scripts", no allow-same-origin), so nothing here can read the page's cookies, DOM, session token or
 * storage, and a CSP with connect-src 'none' leaves it no network of its own.
 *
 * Its only way out is one MessageChannel port that the parent hands over after load. Messages, all small JSON:
 *   parent -> frame:  init {sfc, schema, mode, values}   values {values}   getResult {id, ok, status, json, text, error}
 *   frame -> parent:  ready   input {payload}   submit {payload}   cancel   resize {height}
 *                     error {phase, message}   get {id, path, query}
 * The protocol names no Vue or Quasar type, so a different frame runtime can replace this file.
 *
 * Generated code gets this.$bridge.get(path, query), which returns a Promise of {status, json, text}. It is read-only:
 * the parent sends the request through a server endpoint that refuses a path that would change data.
 * Plain ES5 on purpose, like the other Assist scripts.
 */
(function() {
    'use strict';
    var boot = window.__ASSIST_SANDBOX || {};
    var port = null;
    var pending = {};
    var nextId = 1;
    var root = null;
    // The values as the parent last knew them, so a change the screen makes can be reported as input and an echo is not
    var valuesSnap = {};
    var GET_TIMEOUT_MS = 30000;

    function send(msg) { if (port) { try { port.postMessage(msg); } catch (e) { /* port closed */ } } }
    function plain(v) {
        // Structured clone fails on functions and Vue observers. JSON keeps just the data.
        try { return v === undefined ? null : JSON.parse(JSON.stringify(v)); } catch (e) { return null; }
    }
    function report(phase, err) {
        var m = (err && err.message) ? err.message : String(err);
        send({ t: 'error', phase: phase, message: m.length > 2000 ? m.slice(0, 2000) : m });
    }
    window.addEventListener('error', function(e) { report('runtime', e.error || e.message); });
    window.addEventListener('unhandledrejection', function(e) { report('runtime', e.reason || 'unhandled rejection'); });

    // ---------- the single way in: the port the parent transfers after load ----------
    window.addEventListener('message', function onPort(e) {
        if (port) return;
        if (e.source !== window.parent) return;
        var d = e.data;
        if (!d || d.t !== 'port' || d.nonce !== boot.nonce || !e.ports || !e.ports[0]) return;
        port = e.ports[0];
        port.onmessage = onPortMessage;
        window.removeEventListener('message', onPort);
        send({ t: 'ready' });
    });

    function onPortMessage(e) {
        var m = e.data;
        if (!m || typeof m.t !== 'string') return;
        if (m.t === 'init') init(m);
        else if (m.t === 'values') {
            if (root && m.values && typeof m.values === 'object') { valuesSnap = plain(m.values) || {}; root.values = m.values; }
        }
        else if (m.t === 'getResult') settle(m);
    }

    // ---------- the bridge ----------
    function bridgeGet(path, query) {
        return new Promise(function(resolve, reject) {
            var id = 'g' + (nextId++);
            var timer = setTimeout(function() {
                delete pending[id];
                reject(new Error('Read timed out: ' + path));
            }, GET_TIMEOUT_MS);
            pending[id] = { resolve: resolve, reject: reject, timer: timer };
            send({ t: 'get', id: id, path: String(path || ''), query: plain(query) || {} });
        });
    }
    function settle(m) {
        var p = pending[m.id];
        if (!p) return;
        clearTimeout(p.timer);
        delete pending[m.id];
        if (m.ok) p.resolve({ status: m.status, json: m.json, text: m.text });
        else p.reject(new Error(m.error || ('Read failed' + (m.status ? ' (' + m.status + ')' : ''))));
    }
    // A value for a text field from a read result: the text itself, or the JSON as text.
    function resultText(r) {
        if (r == null) return '';
        if (typeof r.text === 'string' && r.text.length) return r.text;
        if (typeof r.json === 'string') return r.json;
        return r.json == null ? '' : JSON.stringify(r.json);
    }
    function isArray(a) { return Array.isArray(a); }

    // ---------- dependent-field helper shared by the widgets ----------
    // Builds the query for a read from a widget's static parameters and the fields it depends on.
    // Returns null when a required dependency has no value yet and the widget does not mark dependencies optional.
    function dependentQuery(vm, staticParams, dependsOn, fields, optional) {
        var q = {};
        var key;
        if (staticParams) for (key in staticParams) { if (Object.prototype.hasOwnProperty.call(staticParams, key)) q[key] = staticParams[key]; }
        var all = true;
        if (dependsOn) for (key in dependsOn) {
            if (!Object.prototype.hasOwnProperty.call(dependsOn, key)) continue;
            var v = fields ? fields[dependsOn[key]] : null;
            if (!v) all = false; else q[key] = v;
        }
        return (all || optional) ? q : null;
    }

    // ---------- widget shims: the six m-* widgets a generated screen may use, on Quasar, reads through the bridge ----------
    function registerWidgets(Vue) {
        Vue.component('m-container-box', {
            name: 'mContainerBox',
            props: { type: { type: String, 'default': 'default' }, title: String, initialOpen: { type: Boolean, 'default': true } },
            data: function() { return { isBodyOpen: this.initialOpen }; },
            template:
                '<q-card flat bordered class="q-ma-sm m-container-box">' +
                    '<q-card-actions @click.self="toggleBody">' +
                        '<h5 v-if="title && title.length" @click="toggleBody" :class="\'text-\' + type">{{title}}</h5>' +
                        '<slot name="header"></slot><q-space></q-space><slot name="toolbar"></slot>' +
                        '<q-btn color="grey" round flat dense :icon="isBodyOpen ? \'keyboard_arrow_up\' : \'keyboard_arrow_down\'" @click="toggleBody"></q-btn>' +
                    '</q-card-actions>' +
                    '<div v-show="isBodyOpen"><q-card-section><slot></slot></q-card-section></div>' +
                '</q-card>',
            methods: { toggleBody: function() { this.isBodyOpen = !this.isBodyOpen; } }
        });

        Vue.component('m-text-line', {
            name: 'mTextLine',
            props: { value: String, type: { type: String, 'default': 'text' }, id: String, name: String, size: String, fields: { type: Object },
                dense: Boolean, outlined: Boolean, bgColor: String, label: String, tooltip: String, prefix: String, disable: Boolean,
                mask: String, fillMask: String, reverseFillMask: Boolean, rules: Array,
                defaultUrl: String, defaultParameters: Object, dependsOn: Object, dependsOptional: Boolean, defaultLoadInit: Boolean },
            data: function() { return { loading: false }; },
            template:
                '<q-input :dense="dense" :outlined="outlined" :bg-color="bgColor" stack-label :label="label" :prefix="prefix"' +
                        ' v-bind:value="value" v-on:input="$emit(\'input\', $event)" :type="type" :id="id" :name="name" :size="size"' +
                        ' :loading="loading" :rules="rules" :disable="disable" :mask="mask" :fill-mask="fillMask"' +
                        ' :reverse-fill-mask="reverseFillMask" autocapitalize="off" autocomplete="off">' +
                    '<q-tooltip v-if="tooltip">{{tooltip}}</q-tooltip>' +
                '</q-input>',
            methods: {
                populateFromUrl: function() {
                    if (!this.defaultUrl || !this.defaultUrl.length) return;
                    var q = dependentQuery(this, this.defaultParameters, this.dependsOn, this.fields, this.dependsOptional);
                    if (q === null) return;
                    var vm = this;
                    this.loading = true;
                    bridgeGet(this.defaultUrl, q).then(function(r) {
                        vm.loading = false;
                        var text = resultText(r);
                        if (text && text.length) vm.$emit('input', text);
                    }, function(err) { vm.loading = false; report('runtime', err); });
                }
            },
            mounted: function() {
                if (!this.defaultUrl || !this.defaultUrl.length) return;
                var vm = this;
                if (this.fields && this.dependsOn) {
                    Object.keys(this.dependsOn).forEach(function(k) {
                        vm.$watch('fields.' + vm.dependsOn[k], function() { vm.populateFromUrl(); });
                    });
                }
                if (this.defaultLoadInit) this.populateFromUrl();
            }
        });

        Vue.component('m-display', {
            name: 'mDisplay',
            props: { value: String, display: String, valueUrl: String, valueParameters: Object, dependsOn: Object, dependsOptional: Boolean,
                valueLoadInit: Boolean, fields: { type: Object }, tooltip: String, label: String, labelWrapper: Boolean, name: String, id: String },
            data: function() { return { curDisplay: this.display, loading: false }; },
            template:
                '<q-input v-if="labelWrapper" dense outlined readonly stack-label autogrow :value="displayValue" :label="label"' +
                        ' :id="id" :name="name" :loading="loading"><q-tooltip v-if="tooltip">{{tooltip}}</q-tooltip></q-input>' +
                '<span v-else :id="id"><q-tooltip v-if="tooltip">{{tooltip}}</q-tooltip><slot></slot>{{displayValue}}</span>',
            computed: { displayValue: function() { return this.curDisplay && this.curDisplay.length ? this.curDisplay : this.value; } },
            methods: {
                populateFromUrl: function() {
                    if (!this.valueUrl || !this.valueUrl.length) return;
                    var q = dependentQuery(this, this.valueParameters, this.dependsOn, this.fields, this.dependsOptional);
                    if (q === null) { this.$emit('input', null); this.curDisplay = null; return; }
                    var vm = this;
                    this.loading = true;
                    bridgeGet(this.valueUrl, q).then(function(r) {
                        vm.loading = false;
                        var text = resultText(r), label = '', value = '';
                        var response = r ? r.json : null;
                        if (isArray(response) && response.length) response = response[0];
                        else if (response && typeof response === 'object' && isArray(response.options) && response.options.length) response = response.options[0];
                        if (response && typeof response === 'object') {
                            if (response.label != null) label = String(response.label);
                            if (response.value != null) value = String(response.value);
                        }
                        if (!label.length) label = text;
                        if (!value.length) value = text;
                        vm.$emit('input', value);
                        vm.curDisplay = label;
                    }, function(err) { vm.loading = false; report('runtime', err); });
                }
            },
            mounted: function() {
                if (!this.valueUrl || !this.valueUrl.length) return;
                var vm = this;
                if (this.fields && this.dependsOn) {
                    Object.keys(this.dependsOn).forEach(function(k) {
                        vm.$watch('fields.' + vm.dependsOn[k], function() { vm.populateFromUrl(); });
                    });
                }
                if (this.valueLoadInit) this.populateFromUrl();
            }
        });

        Vue.component('m-date-time', {
            name: 'mDateTime',
            props: { id: String, name: { type: String, required: true }, value: String, type: { type: String, 'default': 'date-time' }, label: String,
                size: String, format: String, tooltip: String, form: String, required: String, rules: Array, disable: Boolean,
                minuteStep: { type: Number, 'default': 5 }, bgColor: String },
            template:
                '<q-input dense outlined stack-label :label="label" v-bind:value="value" v-on:input="$emit(\'input\', $event)" :rules="rules"' +
                        ' :mask="inputMask" fill-mask :id="id" :name="name" :form="form" :disable="disable" :size="sizeVal"' +
                        ' style="max-width:max-content;" :bg-color="bgColor">' +
                    '<template v-slot:prepend v-if="type==\'date\' || type==\'date-time\' || !type">' +
                        '<q-icon name="event" class="cursor-pointer"><q-popup-proxy ref="qDateProxy" transition-show="scale" transition-hide="scale">' +
                            '<q-date v-bind:value="value" v-on:input="$emit(\'input\', $event)" :mask="formatVal" @input="function(){$refs.qDateProxy.hide()}"></q-date>' +
                        '</q-popup-proxy></q-icon>' +
                    '</template>' +
                    '<template v-slot:append v-if="type==\'time\' || type==\'date-time\' || !type">' +
                        '<q-icon name="access_time" class="cursor-pointer"><q-popup-proxy ref="qTimeProxy" transition-show="scale" transition-hide="scale">' +
                            '<q-time v-bind:value="value" v-on:input="$emit(\'input\', $event)" :mask="formatVal" format24h @input="function(){$refs.qTimeProxy.hide()}"></q-time>' +
                        '</q-popup-proxy></q-icon>' +
                    '</template>' +
                    '<template v-slot:after><slot name="after"></slot></template>' +
                '</q-input>',
            computed: {
                formatVal: function() {
                    if (this.format && this.format.length) return this.format;
                    return this.type === 'time' ? 'HH:mm' : (this.type === 'date' ? 'YYYY-MM-DD' : 'YYYY-MM-DD HH:mm');
                },
                inputMask: function() { return this.formatVal.replace(/\w/g, '#'); },
                sizeVal: function() {
                    if (this.size && this.size.length) return this.size;
                    return this.type === 'time' ? '9' : (this.type === 'date' ? '10' : '16');
                }
            }
        });

        Vue.component('m-date-period', {
            name: 'mDatePeriod',
            props: { fields: { type: Object, required: true }, name: { type: String, required: true }, id: String,
                allowEmpty: Boolean, fromThruType: { type: String, 'default': 'date' }, form: String, tooltip: String, label: String },
            data: function() {
                return { fromThruMode: false,
                    dateOffsets: [{ value: '0', label: 'This' }, { value: '-1', label: 'Last' }, { value: '1', label: 'Next' },
                        { value: '-2', label: '-2' }, { value: '2', label: '+2' }, { value: '-3', label: '-3' }, { value: '-4', label: '-4' },
                        { value: '-6', label: '-6' }, { value: '-12', label: '-12' }],
                    datePeriods: [{ value: 'day', label: 'Day' }, { value: '7d', label: '7 Days' }, { value: '30d', label: '30 Days' },
                        { value: 'week', label: 'Week' }, { value: 'weeks', label: 'Weeks' }, { value: 'month', label: 'Month' },
                        { value: 'months', label: 'Months' }, { value: 'quarter', label: 'Quarter' }, { value: 'year', label: 'Year' },
                        { value: '7r', label: '+/-7d' }, { value: '30r', label: '+/-30d' }] };
            },
            template:
                '<div v-if="fromThruMode" class="row">' +
                    '<m-date-time :name="name+\'_from\'" :id="id+\'_from\'" :label="label+\' From\'" :form="form" :type="fromThruType" v-model="fields[name+\'_from\']"></m-date-time>' +
                    '<q-icon class="q-my-auto" name="remove"></q-icon>' +
                    '<m-date-time :name="name+\'_thru\'" :id="id+\'_thru\'" :label="label+\' Thru\'" :form="form" :type="fromThruType" v-model="fields[name+\'_thru\']">' +
                        '<template v-slot:after>' +
                            '<q-btn dense flat icon="calendar_view_day" @click="toggleMode"><q-tooltip>Period Select Mode</q-tooltip></q-btn>' +
                            '<q-btn dense flat icon="clear" @click="clearAll"><q-tooltip>Clear</q-tooltip></q-btn>' +
                        '</template>' +
                    '</m-date-time>' +
                '</div>' +
                '<div v-else class="row"><q-input dense outlined stack-label :label="label" v-model="fields[name+\'_pdate\']"' +
                        ' mask="####-##-##" fill-mask :id="id" :name="name+\'_pdate\'" :form="form" style="max-width:max-content;">' +
                    '<q-tooltip v-if="tooltip">{{tooltip}}</q-tooltip>' +
                    '<template v-slot:before>' +
                        '<q-select class="q-pr-xs" dense outlined options-dense emit-value map-options v-model="fields[name+\'_poffset\']"' +
                            ' :name="name+\'_poffset\'" stack-label label="Offset" :options="dateOffsets" :form="form" behavior="menu"></q-select>' +
                        '<q-select dense outlined options-dense emit-value map-options v-model="fields[name+\'_period\']"' +
                            ' :name="name+\'_period\'" stack-label label="Period" :options="datePeriods" :form="form" behavior="menu"></q-select>' +
                    '</template>' +
                    '<template v-slot:prepend><q-icon name="event" class="cursor-pointer"><q-popup-proxy ref="qDateProxy" transition-show="scale" transition-hide="scale">' +
                        '<q-date v-model="fields[name+\'_pdate\']" mask="YYYY-MM-DD" @input="function(){$refs.qDateProxy.hide()}"></q-date>' +
                    '</q-popup-proxy></q-icon></template>' +
                    '<template v-slot:after>' +
                        '<q-btn dense flat icon="date_range" @click="toggleMode"><q-tooltip>Date Range Mode</q-tooltip></q-btn>' +
                        '<q-btn dense flat icon="clear" @click="clearAll"><q-tooltip>Clear</q-tooltip></q-btn>' +
                    '</template>' +
                '</q-input></div>',
            methods: {
                toggleMode: function() { this.fromThruMode = !this.fromThruMode; },
                clearAll: function() {
                    var n = this.name, f = this.fields;
                    ['_pdate', '_poffset', '_period', '_from', '_thru'].forEach(function(suffix) { f[n + suffix] = null; });
                }
            },
            mounted: function() {
                var from = this.fields[this.name + '_from'], thru = this.fields[this.name + '_thru'];
                if ((from && from.length) || (thru && thru.length)) this.fromThruMode = true;
            }
        });

        Vue.component('m-drop-down', {
            name: 'mDropDown',
            props: { value: [Array, String], options: { type: Array, 'default': function() { return []; } }, combo: Boolean,
                allowEmpty: Boolean, multiple: Boolean, requiredManualSelect: Boolean, submitOnSelect: Boolean,
                optionsUrl: String, optionsParameters: Object, optionsLoadInit: Boolean,
                serverSearch: Boolean, serverDelay: { type: Number, 'default': 300 }, serverMinLength: { type: Number, 'default': 1 },
                labelField: { type: String, 'default': 'label' }, valueField: { type: String, 'default': 'value' },
                dependsOn: Object, dependsOptional: Boolean, form: String, fields: { type: Object },
                tooltip: String, label: String, name: String, id: String, disable: Boolean, bgColor: String },
            data: function() { return { curOptions: this.options, allOptions: this.options, lastSearch: null, loading: false }; },
            template:
                '<q-select ref="qSelect" v-bind:value="value" v-on:input="$emit(\'input\', $event)"' +
                        ' dense outlined options-dense use-input :hide-selected="multiple" :name="name" :id="id" :form="form"' +
                        ' input-debounce="500" @filter="filterFn" :clearable="allowEmpty||multiple" :disable="disable"' +
                        ' :multiple="multiple" emit-value map-options behavior="menu"' +
                        ' :rules="[val => allowEmpty||multiple||val===\'\'||(val&&val.length)||\'Please select an option\']"' +
                        ' stack-label :label="label" :loading="loading" :bg-color="bgColor" :options="curOptions">' +
                    '<q-tooltip v-if="tooltip">{{tooltip}}</q-tooltip>' +
                    '<template v-slot:no-option><q-item><q-item-section class="text-grey">No results</q-item-section></q-item></template>' +
                    '<template v-if="multiple" v-slot:prepend><div>' +
                        '<q-chip v-for="valueEntry in value" :key="valueEntry" dense size="md" class="q-my-xs" removable @remove="removeValue(valueEntry)">{{optionLabel(valueEntry)}}</q-chip>' +
                    '</div></template>' +
                '</q-select>',
            methods: {
                filterFn: function(search, doneFn, abortFn) {
                    var vm = this;
                    if (this.serverSearch) {
                        if (this.lastSearch === search || (this.serverMinLength && ((search ? search.length : 0) < this.serverMinLength))) { doneFn(); return; }
                        this.lastSearch = search;
                        this.populateFromUrl({ term: search }, doneFn, abortFn);
                    } else if (this.allOptions && this.allOptions.length) {
                        if (search && search.length) {
                            doneFn(function() {
                                var needle = search.toLowerCase();
                                vm.curOptions = vm.allOptions.filter(function(v) { return v.label && v.label.toLowerCase().indexOf(needle) > -1; });
                            });
                        } else if ((vm.curOptions ? vm.curOptions.length : 0) === (vm.allOptions ? vm.allOptions.length : 0)) doneFn();
                        else doneFn(function() { vm.curOptions = vm.allOptions; });
                    } else if (this.optionsUrl && this.optionsUrl.length) {
                        this.populateFromUrl({}, doneFn, abortFn);
                    } else { abortFn(); }
                },
                processOptionList: function(list) {
                    var labelField = this.labelField, valueField = this.valueField, out = [];
                    (list || []).forEach(function(cur) {
                        if (!cur || typeof cur !== 'object') return;
                        var v = cur[valueField], l = cur[labelField];
                        out.push(Object.assign({}, cur, { value: v || l, label: l || v }));
                    });
                    return out;
                },
                populateFromUrl: function(params, doneFn, abortFn) {
                    if (!this.optionsUrl || !this.optionsUrl.length) { if (abortFn) abortFn(); return; }
                    var q = dependentQuery(this, this.optionsParameters, this.dependsOn, this.fields, this.dependsOptional);
                    if (q === null) { this.curOptions = []; this.allOptions = []; if (abortFn) abortFn(); return; }
                    if (params) { q.term = params.term || ''; q.pageIndex = (params.page || 1) - 1; }
                    else if (this.serverSearch) { q.term = ''; q.pageIndex = 0; }
                    var vm = this;
                    this.loading = true;
                    bridgeGet(this.optionsUrl, q).then(function(r) {
                        vm.loading = false;
                        var data = r ? r.json : null;
                        var list = isArray(data) ? data : (data && data.options);
                        if (!list) { if (abortFn) abortFn(); return; }
                        var procList = vm.processOptionList(list);
                        if (doneFn) doneFn(function() { vm.setNewOptions(procList); });
                        else vm.setNewOptions(procList);
                    }, function(err) { vm.loading = false; report('runtime', err); if (abortFn) abortFn(); });
                },
                setNewOptions: function(options) {
                    this.curOptions = options;
                    this.allOptions = options;
                    var inNew = false, val = this.value, isArr = isArray(val);
                    if (val && val.length) for (var i = 0; i < options.length; i++) {
                        if (isArr ? val.indexOf(options[i].value) >= 0 : options[i].value === val) { inNew = true; break; }
                    }
                    if (!inNew && !this.multiple) {
                        if (!this.allowEmpty && options.length && options[0].value && !this.requiredManualSelect) this.$emit('input', options[0].value);
                        else this.$emit('input', null);
                    }
                },
                optionLabel: function(value) {
                    var options = this.allOptions || [];
                    for (var i = 0; i < options.length; i++) { if (value === options[i].value) return options[i].label; }
                    return '';
                },
                removeValue: function(value) {
                    if (!isArray(this.value)) return;
                    this.$emit('input', this.value.filter(function(v) { return v !== value; }));
                }
            },
            mounted: function() {
                var vm = this;
                if (this.optionsUrl && this.optionsUrl.length) {
                    if (this.fields && this.dependsOn) {
                        Object.keys(this.dependsOn).forEach(function(k) {
                            vm.$watch('fields.' + vm.dependsOn[k], function() { vm.$emit('input', null); vm.populateFromUrl({ term: vm.lastSearch }); });
                        });
                    }
                    if (this.optionsLoadInit) {
                        if (!this.serverSearch) this.populateFromUrl();
                        else if (this.value && this.value.length && typeof this.value === 'string') this.populateFromUrl({ term: this.value });
                    }
                }
                if (!this.multiple && !this.allowEmpty && (!this.value || !this.value.length) && this.options && this.options.length
                        && !this.requiredManualSelect) this.$emit('input', this.options[0].value);
            }
        });
    }

    // ---------- compile and render the generated component ----------
    function ensureSfcProps(comp) {
        var base = {
            values: { type: Object, 'default': function() { return {}; } },
            schema: { type: Object },
            mode: { type: String }
        };
        if (!comp.props) { comp.props = base; return comp; }
        if (isArray(comp.props)) {
            ['values', 'schema', 'mode'].forEach(function(p) { if (comp.props.indexOf(p) < 0) comp.props.push(p); });
            return comp;
        }
        if (!comp.props.values) comp.props.values = base.values;
        if (!comp.props.schema) comp.props.schema = base.schema;
        if (!comp.props.mode) comp.props.mode = base.mode;
        return comp;
    }

    function init(msg) {
        if (root) return;   // one canvas per frame; the parent makes a new frame for new source
        try {
            var Vue = window.Vue;
            if (!Vue || !window.httpVueLoader) throw new Error('The sandbox libraries did not load');
            if (window.Quasar && !(Vue.options.components && Vue.options.components.QInput)) Vue.use(window.Quasar, { config: {} });
            Vue.prototype.$bridge = { get: bridgeGet };
            registerWidgets(Vue);
            var parsed = window.httpVueLoader.parse(String(msg.sfc || ''), '');
            Promise.resolve(typeof parsed === 'function' ? parsed() : parsed).then(function(comp) {
                if (!comp || !comp.template) { report('compile', 'Generated screen failed to compile: missing template'); return; }
                mount(Vue, ensureSfcProps(comp), msg);
            }).catch(function(err) { report('compile', 'Generated screen failed to compile: ' + ((err && err.message) || err)); });
        } catch (err) {
            report('compile', 'Generated screen failed to compile: ' + ((err && err.message) || err));
        }
    }

    function mount(Vue, comp, msg) {
        root = new Vue({
            el: '#assist-sandbox-app',
            data: { comp: comp, values: msg.values || {}, schema: msg.schema || {}, mode: msg.mode || 'script' },
            render: function(h) {
                return h('div', { 'class': 'q-pa-xs' }, [ h(this.comp, {
                    props: { values: this.values, schema: this.schema, mode: this.mode },
                    on: {
                        input: function(payload) { send({ t: 'input', payload: plain(payload) }); },
                        submit: function(payload) { send({ t: 'submit', payload: plain(payload) }); },
                        cancel: function() { send({ t: 'cancel' }); }
                    }
                }) ]);
            },
            errorCaptured: function(err) { report('runtime', err); return false; }
        });
        Vue.config.errorHandler = function(err) { report('runtime', err); };
        // Some widgets, m-date-period for one, write into the values object itself instead of emitting. Report those writes.
        valuesSnap = plain(root.values) || {};
        root.$watch('values', function(now) {
            var cur = plain(now) || {};
            Object.keys(cur).forEach(function(k) {
                if (JSON.stringify(cur[k]) !== JSON.stringify(valuesSnap[k])) send({ t: 'input', payload: { name: k, value: cur[k] } });
            });
            valuesSnap = cur;
        }, { deep: true });
        // Tell the parent how tall the content is so the frame can fit it without an inner scrollbar
        var last = 0;
        function measure() {
            var h = Math.ceil(document.documentElement.scrollHeight);
            if (h !== last) { last = h; send({ t: 'resize', height: h }); }
        }
        if (window.ResizeObserver) new ResizeObserver(measure).observe(document.body);
        setInterval(measure, 500);
        measure();
    }
})();
