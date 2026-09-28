/* Assist OpenUI Lang component library: Quasar v1 + Moqui m-* wrappers (Vue 2). */
(function(root) {
    'use strict';

    var CHART_JS_URL = '/libs/Chart.js/Chart.min.js';
    var MERMAID_URL = '/libs/mermaid/mermaid.min.js';
    var MARKED_URL = '/libs/marked/marked.umd.min.js';
    var PURIFY_URL = '/libs/dompurify/purify.min.js';
    var HLJS_URL = '/libs/highlight.js/highlight.min.js';
    var HLJS_CSS = '/libs/highlight.js/styles/github-dark.min.css';
    var CHART_COLORS = ['#1976d2', '#26a69a', '#9c27b0', '#ef6c00', '#c62828', '#546e7a', '#7cb342', '#f9a825'];
    var CHART_MAX_SERIES = 8;
    var CHART_MAX_POINTS = 200;
    var MD_MAX = 32768;
    var MERMAID_MAX = 8192;

    function asArray(v) {
        if (v == null) return [];
        return Array.isArray(v) ? v : [v];
    }
    function nodeProps(v) {
        if (v && v.type === 'element' && v.props) return v.props;
        return v && typeof v === 'object' ? v : {};
    }
    function isNodeValue(val) {
        if (val && typeof val === 'object' && val.type === 'element') return true;
        if (Array.isArray(val) && val.length && val[0] && typeof val[0] === 'object' && val[0].type === 'element')
            return true;
        return false;
    }
    function truthy(v) {
        return v === true || v === 'true' || v === 'wrap' || v === 1 || v === '1';
    }
    function asNumbers(arr) {
        return asArray(arr).slice(0, CHART_MAX_POINTS).map(function(v) {
            var n = typeof v === 'number' ? v : parseFloat(v);
            return isFinite(n) ? n : 0;
        });
    }
    function asLabels(arr) {
        return asArray(arr).slice(0, CHART_MAX_POINTS).map(function(v) {
            return v == null ? '' : String(v);
        });
    }
    function seriesFromProp(series, fillDefault) {
        return asArray(series).slice(0, CHART_MAX_SERIES).map(function(s, i) {
            var p = nodeProps(s);
            var color = CHART_COLORS[i % CHART_COLORS.length];
            return {
                label: p.category || p.label || ('s' + i),
                data: asNumbers(p.values),
                backgroundColor: fillDefault ? color : (fillDefault === false ? color : color),
                borderColor: color,
                fill: !!fillDefault,
                lineTension: 0
            };
        });
    }

    function validateNavPath(path) {
        if (path == null || path === '') return 'path required';
        path = String(path);
        if (path.charAt(0) !== '/') return 'path must start with /';
        if (/[\s\\\u0000-\u001f]/.test(path)) return 'path must not contain whitespace or backslash';
        if (path.indexOf('://') >= 0 || path.indexOf('//') === 0) return 'path must not contain a host';
        var decoded = path;
        try { decoded = decodeURIComponent(path); } catch (e) { return 'path is not a valid URL'; }
        if (decoded.indexOf('..') >= 0 || decoded.indexOf('\\') >= 0 || /[\s\u0000-\u001f]/.test(decoded))
            return 'path must not contain ..';
        var lower = decoded.toLowerCase();
        if (lower.indexOf('javascript:') >= 0 || lower.indexOf('data:') >= 0 || lower.indexOf('mailto:') >= 0)
            return 'path scheme not allowed';
        if (typeof URL !== 'undefined' && typeof location !== 'undefined' && location.origin) {
            try {
                var url = new URL(path, location.origin);
                if (url.origin !== location.origin) return 'path must stay on this origin';
            } catch (e2) {
                return 'path is not a valid URL';
            }
        }
        return null;
    }
    function validateNavHash(hash) {
        if (hash == null || hash === '') return null;
        var h = String(hash);
        if (h.charAt(0) === '#') h = h.slice(1);
        if (/[\s]/.test(h) || /javascript:/i.test(h) || h.indexOf('..') >= 0) return 'invalid hash';
        return null;
    }
    function encodeNavParams(params) {
        if (params == null || params === '') return { qs: '', error: null };
        if (typeof params !== 'object' || Array.isArray(params))
            return { qs: '', error: 'params must be an object' };
        var parts = [], keys = Object.keys(params), i, k, v;
        for (i = 0; i < keys.length; i++) {
            k = keys[i];
            if (!/^[A-Za-z0-9_.-]+$/.test(k)) return { qs: '', error: 'invalid param key' };
            v = params[k];
            if (v == null || v === '') continue;
            if (typeof v === 'boolean' || typeof v === 'number' || typeof v === 'string')
                parts.push(encodeURIComponent(k) + '=' + encodeURIComponent(String(v)));
            else return { qs: '', error: 'param values must be string, number, or boolean' };
        }
        return { qs: parts.length ? ('?' + parts.join('&')) : '', error: null };
    }
    function buildNavHref(path, params, hash, opts) {
        opts = opts || {};
        var err = validateNavPath(path);
        if (err) return { href: null, error: err };
        err = validateNavHash(hash);
        if (err) return { href: null, error: err };
        var pe = encodeNavParams(params);
        if (pe.error) return { href: null, error: pe.error };
        var href = String(path) + pe.qs;
        if (hash != null && hash !== '') {
            var h = String(hash);
            if (h.charAt(0) === '#') h = h.slice(1);
            if (h) href += '#' + (/^[A-Za-z0-9_.:-]+$/.test(h) ? h : encodeURIComponent(h));
        }
        var getLinkPath = opts.getLinkPath;
        var appRoot = opts.appRoot || '';
        if (opts.rewriteShell && typeof getLinkPath === 'function')
            href = getLinkPath(href);
        else if (appRoot && href.indexOf(appRoot) !== 0)
            href = appRoot + href;
        return { href: href, error: null };
    }
    root.AssistOpenUiNav = {
        validatePath: validateNavPath,
        build: buildNavHref
    };

    function loadAssistScript(src, validate, cb, integrity) {
        if (window.moqui && typeof moqui.loadScript === 'function' && !integrity) {
            moqui.loadScript(src, cb, validate);
            return;
        }
        var found = null;
        var scripts = document.getElementsByTagName('script');
        var i;
        for (i = 0; i < scripts.length; i++) {
            if (scripts[i].src && scripts[i].src.indexOf(src) !== -1) found = scripts[i];
        }
        function done() {
            if (!cb) return;
            if (validate && !validate()) {
                var n = 0;
                var t = setInterval(function() {
                    n++;
                    if (validate()) { clearInterval(t); cb(null); }
                    else if (n > 20) { clearInterval(t); cb(new Error('script validate timeout')); }
                }, 50);
                return;
            }
            cb(null);
        }
        if (found) { done(); return; }
        var script = document.createElement('script');
        script.src = src;
        script.async = false;
        if (integrity) { script.integrity = integrity; script.crossOrigin = 'anonymous'; }
        script.onload = function() { this.onload = this.onerror = null; done(); };
        script.onerror = function() {
            this.onload = this.onerror = null;
            if (cb) cb(new Error('Error loading script ' + src));
        };
        document.head.appendChild(script);
    }
    function loadAssistCss(href, integrity) {
        if (window.moqui && typeof moqui.loadStylesheet === 'function' && !integrity) {
            moqui.loadStylesheet(href);
            return;
        }
        var links = document.getElementsByTagName('link');
        var i;
        for (i = 0; i < links.length; i++) {
            if (links[i].href && links[i].href.indexOf(href) !== -1) return;
        }
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = href;
        if (integrity) { link.integrity = integrity; link.crossOrigin = 'anonymous'; }
        document.head.appendChild(link);
    }
    function navOpts(ctx, rewriteShell) {
        return {
            appRoot: (ctx && ctx.appRoot) || '',
            getLinkPath: ctx && typeof ctx.navGetLinkPath === 'function' ? ctx.navGetLinkPath() : null,
            rewriteShell: !!rewriteShell
        };
    }

    function fieldMixin(compType) {
        return {
            props: ['props', 'renderNode'],
            inject: {
                openui: { from: 'openui', default: null },
                openuiFormName: { from: 'openuiFormName', default: undefined }
            },
            computed: {
                fieldName: function() { return this.props && this.props.name; },
                fieldLabel: function() {
                    var p = this.props || {};
                    return p.label || p.name || '';
                },
                fieldValue: function() {
                    var ctx = this.openui, name = this.fieldName, p = this.props || {};
                    if (ctx && ctx.storeTick != null) { /* depend on store */ }
                    if (ctx && name) {
                        var fromStore = ctx.getState('$' + name);
                        if (fromStore != null && fromStore !== '') return fromStore;
                        var fromField = ctx.getFieldValue(this.openuiFormName, name);
                        if (fromField != null && fromField !== '') return fromField;
                    }
                    return p.value != null ? p.value : '';
                }
            },
            methods: {
                onFieldInput: function(v) {
                    var ctx = this.openui, name = this.fieldName;
                    if (!ctx || !name) return;
                    ctx.setState('$' + name, v);
                    ctx.setFieldValue(this.openuiFormName, compType, name, v, true);
                }
            }
        };
    }

    var Input = {
        mixins: [fieldMixin('Input')],
        template: '<m-text-line dense outlined :label="fieldLabel" :value="fieldValue" :name="fieldName" :placeholder="(props&&props.placeholder)||undefined" @input="onFieldInput"></m-text-line>'
    };
    var TextArea = {
        mixins: [fieldMixin('TextArea')],
        template: '<q-input dense outlined autogrow type="textarea" stack-label :label="fieldLabel" :value="fieldValue" :name="fieldName" @input="onFieldInput"></q-input>'
    };
    var CheckBox = {
        mixins: [fieldMixin('CheckBox')],
        template: '<q-checkbox :label="fieldLabel || (props&&props.label)" :value="!!fieldValue" @input="onFieldInput"></q-checkbox>'
    };
    var SwitchComp = {
        mixins: [fieldMixin('Switch')],
        template: '<q-toggle :label="fieldLabel || (props&&props.label)" :value="!!fieldValue" @input="onFieldInput"></q-toggle>'
    };
    var DateTime = {
        mixins: [fieldMixin('DateTime')],
        computed: {
            dateType: function() {
                var t = (this.props && this.props.type) || 'date-time';
                if (t === 'date' || t === 'time' || t === 'date-time') return t;
                return 'date-time';
            }
        },
        template: '<m-date-time :name="fieldName || \'dt\'" :label="fieldLabel" :type="dateType" :value="fieldValue" @input="onFieldInput"></m-date-time>'
    };
    var Lookup = {
        mixins: [fieldMixin('Lookup')],
        computed: {
            lookupFields: function() {
                var ctx = this.openui;
                if (ctx && ctx.storeTick != null) { /* depend */ }
                return (ctx && ctx.storeSnapshot) || {};
            },
            dependsOnObj: function() {
                var d = this.props && this.props.dependsOn;
                if (d == null || d === '') return undefined;
                if (typeof d === 'object' && !Array.isArray(d)) return d;
                if (typeof d === 'string') {
                    var o = {};
                    o[d] = d;
                    return o;
                }
                return undefined;
            },
            safeOptionsUrl: function() {
                var url = this.props && this.props.optionsUrl;
                if (url == null || url === '') return '';
                if (validateNavPath(String(url)) != null) return '';
                return String(url);
            }
        },
        template: '<m-drop-down dense outlined :label="fieldLabel" :value="fieldValue" :name="fieldName" :options-url="safeOptionsUrl" :value-field="(props&&props.valueField)||\'value\'" :label-field="(props&&props.labelField)||\'label\'" :server-search="true" :depends-on="dependsOnObj" :fields="lookupFields" @input="onFieldInput"></m-drop-down>'
    };
    function optionItems(propItems) {
        return asArray(propItems).map(function(it) {
            var p = nodeProps(it);
            return { value: p.value, label: p.label || p.value };
        });
    }
    var Select = {
        mixins: [fieldMixin('Select')],
        computed: {
            selectOptions: function() { return optionItems(this.props && this.props.items); }
        },
        template: '<q-select dense outlined emit-value map-options stack-label :label="fieldLabel" :value="fieldValue" :options="selectOptions" option-value="value" option-label="label" @input="onFieldInput"></q-select>'
    };
    var RadioGroup = {
        mixins: [fieldMixin('RadioGroup')],
        computed: {
            radioOptions: function() { return optionItems(this.props && this.props.items); }
        },
        template: '<div><div v-if="fieldLabel" class="text-caption text-grey-7">{{fieldLabel}}</div>' +
            '<q-option-group dense type="radio" :value="fieldValue" :options="radioOptions" @input="onFieldInput"></q-option-group></div>'
    };
    var Slider = {
        mixins: [fieldMixin('Slider')],
        computed: {
            sliderMin: function() {
                var n = parseFloat(this.props && this.props.min);
                return isFinite(n) ? n : 0;
            },
            sliderMax: function() {
                var n = parseFloat(this.props && this.props.max);
                return isFinite(n) ? n : 100;
            },
            sliderValue: function() {
                var n = parseFloat(this.fieldValue);
                return isFinite(n) ? n : this.sliderMin;
            }
        },
        template: '<div class="q-px-sm"><div v-if="fieldLabel" class="text-caption text-grey-7">{{fieldLabel}} ({{sliderValue}})</div>' +
            '<q-slider :value="sliderValue" :min="sliderMin" :max="sliderMax" label @input="onFieldInput"></q-slider></div>'
    };
    var PERIOD_SUFFIXES = ['_from', '_thru', '_poffset', '_period', '_pdate'];
    var DatePeriod = {
        props: ['props', 'renderNode'],
        inject: { openui: { from: 'openui', default: null } },
        data: function() { return { periodFields: {} }; },
        computed: {
            fieldName: function() { return (this.props && this.props.name) || 'period'; },
            fieldLabel: function() { return (this.props && this.props.label) || this.fieldName; },
            fromThruType: function() {
                var t = this.props && this.props.type;
                return t === 'date-time' || t === 'time' ? t : 'date';
            }
        },
        created: function() { this.periodFields = this.readFields(); },
        watch: {
            'openui.storeTick': function() {
                var next = this.readFields();
                if (JSON.stringify(next) !== JSON.stringify(this.periodFields)) this.periodFields = next;
            },
            periodFields: {
                deep: true,
                handler: function(v) { this.writeFields(v); }
            }
        },
        methods: {
            readFields: function() {
                var ctx = this.openui, name = this.fieldName, o = {};
                PERIOD_SUFFIXES.forEach(function(s) {
                    var k = name + s;
                    var v = ctx ? ctx.getState('$' + k) : '';
                    o[k] = v != null ? v : '';
                });
                return o;
            },
            writeFields: function(v) {
                var ctx = this.openui, name = this.fieldName;
                if (!ctx) return;
                PERIOD_SUFFIXES.forEach(function(s) {
                    var k = name + s;
                    ctx.setState('$' + k, v[k] != null ? v[k] : '');
                });
            }
        },
        template: '<m-date-period :name="fieldName" :label="fieldLabel" :fields="periodFields" :from-thru-type="fromThruType"></m-date-period>'
    };

    function xyChartConfig(type, labels, series, variant, xLabel, yLabel, fill) {
        var stacked = variant === 'stacked';
        var tension = variant === 'natural' ? 0.4 : 0;
        var stepped = variant === 'step';
        var datasets = seriesFromProp(series, fill).map(function(ds) {
            ds.lineTension = tension;
            ds.steppedLine = stepped;
            if (fill) ds.fill = true;
            return ds;
        });
        var options = {
            maintainAspectRatio: false,
            animation: { duration: 0 },
            legend: { display: datasets.length > 1 },
            scales: {
                xAxes: [{ stacked: stacked, scaleLabel: { display: !!xLabel, labelString: xLabel || '' } }],
                yAxes: [{ stacked: stacked, ticks: { beginAtZero: true },
                    scaleLabel: { display: !!yLabel, labelString: yLabel || '' } }]
            }
        };
        return { type: type, data: { labels: asLabels(labels), datasets: datasets }, options: options };
    }
    function pieChartConfig(labels, values, variant) {
        var labs = asLabels(labels);
        var vals = asNumbers(values);
        var n = Math.min(labs.length, vals.length, CHART_MAX_POINTS);
        labs = labs.slice(0, n);
        vals = vals.slice(0, n);
        var colors = labs.map(function(_, i) { return CHART_COLORS[i % CHART_COLORS.length]; });
        return {
            type: variant === 'donut' || variant === 'doughnut' ? 'doughnut' : 'pie',
            data: { labels: labs, datasets: [{ data: vals, backgroundColor: colors }] },
            options: { maintainAspectRatio: false, animation: { duration: 0 }, legend: { position: 'right' } }
        };
    }
    function chartMixin(configFn) {
        return {
            props: ['props', 'renderNode'],
            data: function() { return { instance: null, loadError: null, chartType: null }; },
            mounted: function() { this.ensureChart(); },
            beforeDestroy: function() { this.destroyChart(); },
            watch: {
                props: { deep: true, handler: function() { this.updateChart(); } }
            },
            methods: {
                destroyChart: function() {
                    if (this.instance) {
                        try { this.instance.destroy(); } catch (e) { /* ignore */ }
                        this.instance = null;
                    }
                },
                ensureChart: function() {
                    var vm = this;
                    loadAssistScript(CHART_JS_URL, function() { return !!window.Chart; }, function(err) {
                        if (err) { vm.loadError = 'Chart.js failed to load'; return; }
                        vm.updateChart();
                    });
                },
                updateChart: function() {
                    if (!window.Chart || !this.$refs.canvas) return;
                    var cfg = configFn(this.props || {});
                    if (!cfg || !cfg.data) return;
                    if (this.instance && this.chartType === cfg.type) {
                        this.instance.data.labels = cfg.data.labels;
                        this.instance.data.datasets = cfg.data.datasets;
                        this.instance.update();
                        return;
                    }
                    this.destroyChart();
                    this.chartType = cfg.type;
                    this.instance = new window.Chart(this.$refs.canvas, cfg);
                }
            },
            template: '<div class="chart-container" style="position:relative;height:280px;width:100%">' +
                '<div v-if="loadError" class="text-negative text-caption">{{loadError}}</div>' +
                '<canvas ref="canvas"></canvas></div>'
        };
    }
    var BarChart = {
        mixins: [chartMixin(function(p) {
            return xyChartConfig('bar', p.labels, p.series, p.variant, p.xLabel, p.yLabel, false);
        })]
    };
    var LineChart = {
        mixins: [chartMixin(function(p) {
            return xyChartConfig('line', p.labels, p.series, p.variant, p.xLabel, p.yLabel, false);
        })]
    };
    var AreaChart = {
        mixins: [chartMixin(function(p) {
            return xyChartConfig('line', p.labels, p.series, p.variant, p.xLabel, p.yLabel, true);
        })]
    };
    var PieChart = {
        mixins: [chartMixin(function(p) {
            return pieChartConfig(p.labels, p.values, p.variant);
        })]
    };

    function mermaidInit(el, text, cb) {
        loadAssistScript(MERMAID_URL, function() { return !!window.mermaid; }, function(err) {
            if (err || !window.mermaid) { if (cb) cb(err || new Error('mermaid missing')); return; }
            try {
                window.mermaid.initialize({ startOnLoad: false, securityLevel: 'strict' });
            } catch (e) { /* already init */ }
            var src = String(text || '').slice(0, MERMAID_MAX);
            el.textContent = src;
            el.className = 'mermaid';
            try {
                window.mermaid.init({ startOnLoad: false, securityLevel: 'strict' }, el);
                if (cb) cb(null);
            } catch (e3) {
                el.textContent = src;
                if (cb) cb(e3);
            }
        });
    }
    function loadMarkdownStack(cb) {
        loadAssistCss(HLJS_CSS);
        loadAssistScript(MARKED_URL, function() { return !!(window.marked && window.marked.parse); }, function(err) {
            if (err) { cb(err); return; }
            loadAssistScript(PURIFY_URL, function() { return !!(window.DOMPurify && window.DOMPurify.sanitize); }, function(err2) {
                if (err2) { cb(err2); return; }
                loadAssistScript(HLJS_URL, function() { return !!(window.hljs && window.hljs.highlightElement); }, cb);
            });
        });
    }
    function rewriteMdLinks(container) {
        var as = container.querySelectorAll('a[href]');
        var i, a, href;
        for (i = 0; i < as.length; i++) {
            a = as[i];
            href = a.getAttribute('href') || '';
            if (/^https?:\/\//i.test(href) || href.indexOf('mailto:') === 0) {
                a.setAttribute('target', '_blank');
                a.setAttribute('rel', 'noopener noreferrer');
            } else if (href.charAt(0) === '#') {
                /* keep */
            } else if (href.charAt(0) === '/' && validateNavPath(href) == null) {
                a.setAttribute('target', '_blank');
                a.setAttribute('rel', 'noopener noreferrer');
            } else {
                a.removeAttribute('href');
            }
        }
        var imgs = container.querySelectorAll('img[src]');
        for (i = 0; i < imgs.length; i++) {
            var src = imgs[i].getAttribute('src') || '';
            if (validateNavPath(src) != null) imgs[i].parentNode.removeChild(imgs[i]);
        }
    }
    function renderMarkdownInto(el, md, thenMermaid) {
        var text = String(md == null ? '' : md);
        if (text.length > MD_MAX) text = text.slice(0, MD_MAX);
        var mermaidBlocks = [];
        text = text.replace(/```mermaid\s*\n([\s\S]*?)```/gi, function(_, body) {
            var idx = mermaidBlocks.length;
            mermaidBlocks.push(body);
            return '\n\n<div class="openui-md-mermaid" data-openui-mmd="' + idx + '"></div>\n\n';
        });
        var html = window.marked.parse(text, { gfm: true, breaks: false });
        html = window.DOMPurify.sanitize(html, {
            USE_PROFILES: { html: true },
            ADD_ATTR: ['id', 'data-openui-mmd'],
            FORBID_TAGS: ['script', 'iframe', 'object', 'embed', 'form'],
            FORBID_ATTR: ['style']
        });
        el.innerHTML = html;
        rewriteMdLinks(el);
        if (window.hljs) {
            var blocks = el.querySelectorAll('pre code');
            var i;
            for (i = 0; i < blocks.length; i++) {
                try { window.hljs.highlightElement(blocks[i]); } catch (e) { /* ignore */ }
            }
        }
        if (thenMermaid && mermaidBlocks.length) {
            var holders = el.querySelectorAll('[data-openui-mmd]');
            for (i = 0; i < holders.length; i++) {
                (function(node) {
                    var idx = parseInt(node.getAttribute('data-openui-mmd'), 10);
                    var src = mermaidBlocks[idx] || '';
                    mermaidInit(node, src, function(err) {
                        if (err) node.textContent = src;
                    });
                })(holders[i]);
            }
        }
    }

    var comps = {
        Stack: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var p = this.props || {};
                var dir = p.direction === 'row' ? 'row' : 'column';
                var gap = p.gap === 's' ? 'q-gutter-sm' : (p.gap === 'l' ? 'q-gutter-lg' : 'q-gutter-md');
                var wrap = truthy(p.wrap) ? ' wrap' : '';
                return h('div', { class: dir + ' ' + gap + wrap }, this.renderNode(p.children));
            }
        },
        Card: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var p = this.props || {};
                return h('q-card', { class: 'q-mb-md' }, [
                    h('q-card-section', this.renderNode(p.children))
                ]);
            }
        },
        CardHeader: {
            props: ['props', 'renderNode'],
            template: '<div class="q-mb-sm"><div class="text-h6">{{props && props.title}}</div><div v-if="props && props.subtitle" class="text-body2 text-grey-7">{{props.subtitle}}</div></div>'
        },
        TextContent: {
            props: ['props', 'renderNode'],
            computed: {
                sizeClass: function() {
                    var s = (this.props && this.props.size) || 'body';
                    if (s === 'small') return 'text-caption';
                    if (s === 'large' || s === 'large-heavy') return 'text-h4';
                    return 'text-body1';
                }
            },
            template: '<div :class="sizeClass" style="white-space:pre-wrap">{{props && props.text}}</div>'
        },
        Callout: {
            props: ['props', 'renderNode'],
            computed: {
                bannerClass: function() {
                    var t = (this.props && this.props.type) || 'info';
                    if (t === 'warning' || t === 'negative' || t === 'positive' || t === 'info') return 'bg-' + t + ' text-white';
                    return 'bg-info text-white';
                }
            },
            template: '<q-banner dense class="q-mb-sm" :class="bannerClass">{{props && props.text}}</q-banner>'
        },
        Separator: {
            props: ['props', 'renderNode'],
            template: '<q-separator :inset="!!(props && props.inset)" class="q-my-sm"></q-separator>'
        },
        Accordion: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var self = this;
                var kids = asArray(this.props && this.props.children);
                var items = kids.map(function(k, i) {
                    var p = nodeProps(k);
                    return h('q-expansion-item', {
                        props: { dense: true, label: p.title || p.trigger || p.value || ('Item ' + i),
                            name: p.value || ('a' + i) }
                    }, asArray(self.renderNode(p.content)));
                });
                return h('q-list', { props: { bordered: true, dense: true }, class: 'q-mb-sm' }, items);
            }
        },
        AccordionItem: { props: ['props', 'renderNode'], template: '<span></span>' },
        Steps: {
            props: ['props', 'renderNode'],
            data: function() { return { step: null }; },
            created: function() {
                var kids = asArray(this.props && this.props.children);
                var first = kids[0] && nodeProps(kids[0]);
                this.step = (first && first.value) || 's0';
            },
            render: function(h) {
                var self = this;
                var kids = asArray(this.props && this.props.children);
                var steps = kids.map(function(k, i) {
                    var p = nodeProps(k);
                    var name = p.value || ('s' + i);
                    var nav = [];
                    if (i > 0) nav.push(h('q-btn', {
                        props: { flat: true, dense: true, label: 'Back' },
                        on: { click: function() { self.step = nodeProps(kids[i - 1]).value || ('s' + (i - 1)); } }
                    }));
                    if (i < kids.length - 1) nav.push(h('q-btn', {
                        props: { unelevated: true, dense: true, color: 'primary', label: 'Next' },
                        on: { click: function() { self.step = nodeProps(kids[i + 1]).value || ('s' + (i + 1)); } }
                    }));
                    return h('q-step', { props: { name: name, title: p.title || p.trigger || name } },
                        asArray(self.renderNode(p.content)).concat([h('q-stepper-navigation', nav)]));
                });
                return h('q-stepper', {
                    props: { animated: true, color: 'primary', contracted: true },
                    class: 'q-mb-sm',
                    model: { value: self.step, callback: function(v) { self.step = v; } }
                }, steps);
            }
        },
        StepsItem: { props: ['props', 'renderNode'], template: '<span></span>' },
        Modal: {
            props: ['props', 'renderNode'],
            inject: { openui: { from: 'openui', default: null } },
            computed: {
                isOpen: {
                    get: function() {
                        var ctx = this.openui, name = this.props && this.props.name;
                        if (ctx && ctx.storeTick != null) { /* depend */ }
                        if (!ctx || !name) return false;
                        return !!ctx.getState('$' + name);
                    },
                    set: function(v) {
                        var ctx = this.openui, name = this.props && this.props.name;
                        if (ctx && name) ctx.setState('$' + name, !!v);
                    }
                }
            },
            render: function(h) {
                var p = this.props || {};
                var self = this;
                return h('q-dialog', {
                    props: { value: self.isOpen },
                    on: { input: function(v) { self.isOpen = v; } }
                }, [
                    h('q-card', { style: { minWidth: '320px' } }, [
                        h('q-card-section', { class: 'row items-center q-pb-none' }, [
                            h('div', { class: 'text-h6' }, p.title || ''),
                            h('q-space'),
                            h('q-btn', { props: { icon: 'close', flat: true, round: true, dense: true },
                                on: { click: function() { self.isOpen = false; } } })
                        ]),
                        h('q-card-section', asArray(this.renderNode(p.children)))
                    ])
                ]);
            }
        },
        Form: {
            props: ['props', 'renderNode'],
            provide: function() {
                var p = this.props || {};
                return { openuiFormName: p.name };
            },
            render: function(h) {
                var p = this.props || {};
                var kids = asArray(this.renderNode(p.children));
                var submit = p.submit ? this.renderNode(p.submit) : null;
                var body = kids;
                if (submit) body = kids.concat([h('div', { class: 'q-mt-md' }, asArray(submit))]);
                return h('div', { class: 'column q-gutter-sm' }, body);
            }
        },
        FormControl: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var p = this.props || {};
                return h('div', { class: 'q-mb-sm' }, [
                    p.label ? h('div', { class: 'text-caption text-grey-7' }, p.label) : null,
                    this.renderNode(p.control)
                ]);
            }
        },
        Input: Input,
        TextArea: TextArea,
        Select: Select,
        SelectItem: { props: ['props', 'renderNode'], template: '<span></span>' },
        CheckBox: CheckBox,
        RadioGroup: RadioGroup,
        RadioItem: { props: ['props', 'renderNode'], template: '<span></span>' },
        Switch: SwitchComp,
        Slider: Slider,
        DateTime: DateTime,
        DatePeriod: DatePeriod,
        Lookup: Lookup,
        Display: {
            props: ['props', 'renderNode'],
            template: '<m-display :label="props && props.label" :display="props && props.text" :value-url="props && props.valueUrl"></m-display>'
        },
        Stat: {
            props: ['props', 'renderNode'],
            template: '<q-card flat bordered class="q-pa-md">' +
                '<div class="text-caption text-grey-7">{{props && props.label}}</div>' +
                '<div class="text-h4">{{props && props.value}}</div>' +
                '<div v-if="props && props.caption" class="text-caption">{{props.caption}}</div></q-card>'
        },
        Tag: {
            props: ['props', 'renderNode'],
            computed: {
                tagColor: function() {
                    var c = (this.props && this.props.color) || 'primary';
                    if (c === 'success') c = 'positive';
                    if (c === 'danger') c = 'negative';
                    if (c === 'neutral') c = 'grey';
                    return c;
                },
                tagSize: function() {
                    return (this.props && this.props.size) === 'sm' ? 'sm' : 'md';
                }
            },
            template: '<q-chip dense :color="tagColor" text-color="white" :size="tagSize">{{props && props.label}}</q-chip>'
        },
        ListBlock: {
            props: ['props', 'renderNode'],
            render: function(h) {
                return h('q-list', { props: { bordered: true, separator: true }, class: 'q-mb-sm' },
                    asArray(this.renderNode(this.props && this.props.children)));
            }
        },
        ListItem: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var p = this.props || {};
                var sections = [
                    h('q-item-section', [
                        h('q-item-label', p.title || ''),
                        p.caption ? h('q-item-label', { props: { caption: true } }, p.caption) : null
                    ])
                ];
                if (p.side != null && p.side !== '')
                    sections.push(h('q-item-section', { props: { side: true } }, asArray(this.renderNode(p.side))));
                return h('q-item', sections);
            }
        },
        Image: {
            props: ['props', 'renderNode'],
            inject: { openui: { from: 'openui', default: null } },
            computed: {
                imgSrc: function() {
                    var src = this.props && this.props.src;
                    var built = buildNavHref(src, null, null, navOpts(this.openui, false));
                    return built.href;
                },
                imgError: function() {
                    var src = this.props && this.props.src;
                    var built = buildNavHref(src, null, null, navOpts(this.openui, false));
                    return built.error;
                }
            },
            template: '<div><q-img v-if="imgSrc" :src="imgSrc" :alt="(props&&props.alt)||\'\'" style="max-width:100%"></q-img>' +
                '<div v-else class="text-caption text-grey-7">{{imgError || "Invalid image src"}}</div></div>'
        },
        Table: {
            props: ['props', 'renderNode'],
            render: function(h) {
                var self = this;
                var colsIn = asArray(this.props && this.props.columns);
                var colDefs = [];
                var i, p, vals, n = 0;
                for (i = 0; i < colsIn.length; i++) {
                    p = nodeProps(colsIn[i]);
                    vals = asArray(p.values);
                    if (vals.length > n) n = vals.length;
                    colDefs.push({
                        name: p.label || ('c' + i),
                        label: p.label || ('c' + i),
                        field: p.label || ('c' + i),
                        align: 'left',
                        values: vals
                    });
                }
                var rows = [];
                for (i = 0; i < n; i++) {
                    var row = { __i: i };
                    colDefs.forEach(function(c) { row[c.field] = c.values[i] != null ? c.values[i] : ''; });
                    rows.push(row);
                }
                var qCols = colDefs.map(function(c) {
                    return { name: c.name, label: c.label, field: c.field, align: 'left' };
                });
                return h('q-table', {
                    props: { dense: true, flat: true, hideBottom: true, pagination: { rowsPerPage: 0 },
                        columns: qCols, data: rows, rowKey: '__i' },
                    scopedSlots: {
                        body: function(slotProps) {
                            var cols = slotProps.cols || qCols;
                            var tds = cols.map(function(col) {
                                var val = slotProps.row[col.field];
                                var kids = isNodeValue(val) ? asArray(self.renderNode(val))
                                    : [val == null ? '' : String(val)];
                                return h('q-td', { key: col.name, props: { props: slotProps } }, kids);
                            });
                            return h('q-tr', { props: { props: slotProps } }, tds);
                        }
                    }
                });
            }
        },
        Col: { props: ['props', 'renderNode'], template: '<span></span>' },
        Series: { props: ['props', 'renderNode'], template: '<span></span>' },
        BarChart: BarChart,
        LineChart: LineChart,
        AreaChart: AreaChart,
        PieChart: PieChart,
        MarkDownRenderer: {
            props: ['props', 'renderNode'],
            data: function() { return { loadError: null }; },
            mounted: function() { this.draw(); },
            watch: {
                'props.textMarkdown': function() { this.draw(); }
            },
            methods: {
                draw: function() {
                    var vm = this;
                    var el = this.$refs.body;
                    if (!el) return;
                    loadMarkdownStack(function(err) {
                        if (err) { vm.loadError = 'Markdown libraries failed to load'; return; }
                        vm.loadError = null;
                        renderMarkdownInto(el, vm.props && vm.props.textMarkdown, true);
                    });
                }
            },
            template: '<div :class="(props && props.variant===\'card\') ? \'q-pa-md q-mb-sm bg-grey-2 rounded-borders\' : \'\'">' +
                '<div v-if="loadError" class="text-negative text-caption">{{loadError}}</div>' +
                '<div ref="body" class="openui-md"></div></div>'
        },
        Mermaid: {
            props: ['props', 'renderNode'],
            data: function() { return { loadError: null }; },
            mounted: function() { this.draw(); },
            watch: {
                'props.text': function() { this.draw(); }
            },
            methods: {
                draw: function() {
                    var el = this.$refs.out;
                    if (!el) return;
                    var text = (this.props && this.props.text) || '';
                    var vm = this;
                    mermaidInit(el, text, function(err) {
                        vm.loadError = err ? 'Mermaid failed to render' : null;
                        if (err) el.textContent = String(text).slice(0, MERMAID_MAX);
                    });
                }
            },
            template: '<div :style="{minHeight:(props&&props.height)||\'200px\'}">' +
                '<div v-if="loadError" class="text-caption text-grey-7">{{loadError}}</div>' +
                '<div ref="out"></div></div>'
        },
        CodeBlock: {
            props: ['props', 'renderNode'],
            mounted: function() { this.highlight(); },
            watch: {
                'props.code': function() { this.$nextTick(this.highlight); }
            },
            methods: {
                highlight: function() {
                    var el = this.$refs.code;
                    if (!el) return;
                    loadAssistCss(HLJS_CSS);
                    loadAssistScript(HLJS_URL, function() { return !!(window.hljs && window.hljs.highlightElement); }, function(err) {
                        if (err || !window.hljs) return;
                        try { window.hljs.highlightElement(el); } catch (e) { /* ignore */ }
                    });
                }
            },
            template: '<pre class="q-pa-sm bg-grey-9 text-white" style="overflow:auto"><code ref="code" :class="(props&&props.language)||\'\'">{{props && props.code}}</code></pre>'
        },
        Link: {
            props: ['props', 'renderNode'],
            inject: { openui: { from: 'openui', default: null } },
            computed: {
                navResult: function() {
                    var p = this.props || {};
                    if (this.openui && this.openui.storeTick != null) { /* depend */ }
                    return buildNavHref(p.path, p.params, p.hash, navOpts(this.openui, true));
                }
            },
            template: '<a v-if="navResult.href" class="q-link text-primary" :href="navResult.href" target="_blank" rel="noopener noreferrer">{{(props&&props.label)||navResult.href}}</a>' +
                '<span v-else class="text-caption text-grey-7">{{navResult.error || "Invalid link"}}</span>'
        },
        Button: {
            props: ['props', 'renderNode'],
            inject: { openui: { from: 'openui', default: null } },
            computed: {
                btnColor: function() {
                    var c = (this.props && this.props.color) || 'primary';
                    if (c === 'secondary') return 'grey';
                    if (c === 'negative' || c === 'primary' || c === 'positive' || c === 'warning' || c === 'info')
                        return c;
                    return 'primary';
                }
            },
            methods: {
                onClick: function() {
                    var ctx = this.openui, p = this.props || {};
                    if (!ctx || !ctx.triggerAction) return;
                    ctx.triggerAction(p.label || 'Submit', undefined, p.action);
                }
            },
            template: '<q-btn unelevated no-caps :color="btnColor" :label="(props&&props.label)||\'Submit\'" :disable="openui && openui.isStreaming" @click="onClick"></q-btn>'
        },
        Buttons: {
            props: ['props', 'renderNode'],
            render: function(h) {
                return h('div', { class: 'q-gutter-sm' }, this.renderNode(this.props && this.props.children));
            }
        },
        Tabs: {
            props: ['props', 'renderNode'],
            data: function() { return { tab: null }; },
            created: function() {
                var kids = asArray(this.props && this.props.children);
                var first = kids[0] && nodeProps(kids[0]);
                this.tab = (first && first.value) || 't0';
            },
            render: function(h) {
                var self = this;
                var kids = asArray(this.props && this.props.children);
                var tabs = [];
                var panels = [];
                kids.forEach(function(k, i) {
                    var p = nodeProps(k);
                    var name = p.value || ('t' + i);
                    tabs.push(h('q-tab', { props: { name: name, label: p.trigger || name } }));
                    panels.push(h('q-tab-panel', { props: { name: name } }, asArray(self.renderNode(p.content))));
                });
                return h('div', [
                    h('q-tabs', {
                        class: 'text-primary',
                        props: { dense: true },
                        model: { value: self.tab, callback: function(v) { self.tab = v; } }
                    }, tabs),
                    h('q-tab-panels', {
                        props: { animated: true },
                        model: { value: self.tab, callback: function(v) { self.tab = v; } }
                    }, panels)
                ]);
            }
        },
        TabItem: { props: ['props', 'renderNode'], template: '<span></span>' }
    };

    var library = { root: 'Stack', components: {} };
    Object.keys(comps).forEach(function(name) {
        library.components[name] = { name: name, component: comps[name], props: {} };
    });

    function loadSpec(cb) {
        if (root.AssistOpenUiSpec) { cb(null, root.AssistOpenUiSpec); return; }
        var rootPath = (root.moqui && root.moqui.webrootVue && root.moqui.webrootVue.appRootPath) || '';
        var url = rootPath + '/js/assist/AssistOpenUiLibrary.spec.json';
        fetch(url, { credentials: 'same-origin' }).then(function(r) {
            if (!r.ok) throw new Error('Failed to load OpenUI library spec');
            return r.json();
        }).then(function(j) {
            root.AssistOpenUiSpec = j;
            cb(null, j);
        }).catch(function(err) { cb(err); });
    }

    root.AssistOpenUiLibrary = library;
    root.loadAssistOpenUiSpec = loadSpec;
})(typeof window !== 'undefined' ? window : this);
