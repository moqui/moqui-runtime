/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */
var moqui = moqui || {};

(function(moqui, $, Vue) {
/* TODO:
 - going to minimal path causes menu reload; avoid? better to cache menus and do partial requests...

 - use vue-aware widgets or add vue component wrappers for scripts and widgets
 - remove as many inline m-script elements as possible...
 - add fully client rendered version of form-list when it has data prep embedded
   - current form-list.entity-find with special transition to get for data by name and current + paginate parameters
   - add form-list.rest-entity, rest-service (or just rest-call?), and maybe service-call/actions/etc

 - anchor (a) only used for link if UrlInstance.isScreenUrl() is false which looks only at default-response for url-type=plain or
   type=none; if a transition has conditional or error responses of different types it won't response properly
   - consider changing loadComponent to pass a header telling ScreenRenderImpl that it is for a component
   - in ScreenRenderImpl if we are sending back content handle some other way...
   - in SRI if redirecting to screen send JSON obj with screenUrl or for non-screen redirectUrl


 - big new feature for client rendered screens
   - on the server render to a Vue component object in JS file following pattern of MyAccountNav.js with define()
   - let vue component object have no template, using loadComponent feature to download same url with .html to get template string
   - make these completely static, not dependent on any inline data, so they can be cached
   - add caching of component objects to loadComponent; perhaps 20 (50?) item LRU array
   - separate request(s) to get data to populate
 - screen structure (Vue specific...)
   - use existing XML Screen with a new client-template and other elements?
   - if called from load component (identify with header) return js, or with .html extension return template string
   - client-template element with vue template (ie pseudo html with JS expressions)
   - client-template would still be simplified using Moqui library of Vue components
   - other elements for vue properties like data, methods, mounted/etc lifecycle, computed, watch, etc
   - can these be compatible with other tools like Angular2, React, etc or need something higher level?
 - screen structure for any client library (Angular2, React, etc) possible?
   - goal would be to use FTL macros to transform more detailed XML into library specific output
 */

var notifyOpts = { delay:6000, offset:{x:20,y:70}, type:'success', animate:{ enter:'animated fadeInDown', exit:'animated fadeOutUp' } };
var util = {
    isString: function(obj) { return typeof obj === 'string'; },
    isBoolean: function(obj) { return typeof obj === 'boolean'; },
    isNumber: function(obj) { return typeof obj === 'number'; },
    isArray: function(obj) { return Object.prototype.toString.call(obj) === '[object Array]'; },
    isFunction: function(obj) { return Object.prototype.toString.call(obj) === '[object Function]'; }
};

// simple stub for define if it doesn't exist (ie no require.js, etc); mimic pattern of require.js define()
if (!window.define) window.define = function(name, deps, callback) {
    if (!util.isString(name)) { callback = deps; deps = name; name = null; }
    if (!util.isArray(deps)) { callback = deps; deps = null; }
    if (util.isFunction(callback)) { return callback(); } else { return callback }
};

/* ========== script and stylesheet handling methods ========== */
function loadScript(src) {
    // make sure the script isn't loaded
    var loaded = false;
    $('head script').each(function(i, hscript) { if (hscript.src.indexOf(src) != -1) loaded = true; });
    if (loaded) return;
    // add it to the header
    var script = document.createElement('script'); script.src = src; script.async = false;
    document.head.appendChild(script);
}
function loadStylesheet(href, rel, type) {
    if (!rel) rel = 'stylesheet'; if (!type) type = 'text/css';
    // make sure the stylesheet isn't loaded
    var loaded = false;
    $('head link').each(function(i, hlink) { if (hlink.href.indexOf(href) != -1) loaded = true; });
    if (loaded) return;
    // add it to the header
    var link = document.createElement('link'); link.href = href; link.rel = rel; link.type = type;
    document.head.appendChild(link);
}
function retryInlineScript(src, count) {
    try { eval(src); } catch(e) {
        src = src.trim();
        console.log('error ' + count + ' running inline script: ' + src.slice(0, 30) + '...');
        console.log(e);
        if (count <= 5) setTimeout(retryInlineScript, 200, src, count+1);
    }
}

/* ========== component loading methods ========== */
function LruMap(limit) {
    this.limit = limit; this.valueMap = {}; this.lruList = []; // end of list is least recently used
    this.put = function(key, value) {
        var lruList = this.lruList; var valueMap = this.valueMap;
        valueMap[key] = value; this._keyUsed(key);
        while (lruList.length > this.limit) { var rem = lruList.pop(); valueMap[rem] = null; }
    };
    this.get = function (key) {
        var value = this.valueMap[key];
        if (value) { this._keyUsed(key); }
        return value;
    };
    this.containsKey = function (key) { return !!this.valueMap[key]; };
    this._keyUsed = function(key) {
        var lruList = this.lruList;
        var lruIdx = -1;
        for (var i=0; i<lruList.length; i++) { if (lruList[i] == key) { lruIdx = i; break; }}
        if (lruIdx >= 0) { lruList.splice(lruIdx,1); }
        lruList.unshift(key);
    };
}
var componentCache = new LruMap(50);

function handleAjaxError(jqXHR, textStatus, errorThrown) {
    console.log('ajax ' + textStatus + ' (' + jqXHR.status + '), message ' + errorThrown + '; response text: ' + jqXHR.responseText);
    // reload on 401 (Unauthorized) so server can remember current URL and redirect to login screen
    if (jqXHR.status == 401) { if (webrootVue) { window.location.href = webrootVue.currentLinkUrl; } else { window.location.reload(true); } }
    else if (jqXHR.status == 0) { $.notify({ message:'Could not connect to server' }, $.extend({}, notifyOpts, {delay:30000, type:'danger'})); }
    else { $.notify({ message:'Error: ' + errorThrown + ' (' + textStatus + ')' }, $.extend({}, notifyOpts, {delay:30000, type:'danger'})); }
}
// NOTE: this may eventually split to change the activeSubscreens only on currentPathList change (for screens that support it)
//     and if ever needed some sort of data refresh if currentParameters changes
function loadComponent(urlInfo, callback, divId) {
    var path, extraPath, search;
    if (typeof urlInfo === 'string') {
        var questIdx = urlInfo.indexOf('?');
        if (questIdx > 0) { path = urlInfo.slice(0, questIdx); search = urlInfo.slice(questIdx+1); }
        else { path = urlInfo; }
    } else {
        path = urlInfo.path; extraPath = urlInfo.extraPath; search = urlInfo.search;
    }

    // check cache
    // console.log('component lru ' + JSON.stringify(componentCache.lruList));
    var cachedComp = componentCache.get(path);
    if (cachedComp) {
        console.log('found cached component for path ' + path);
        callback(cachedComp); return;
    }

    // prep url
    var url = path; var isJsPath = (path.slice(-3) == '.js');
    if (!isJsPath) url += '.vuet';
    if (extraPath && extraPath.length > 0) url += ('/' + extraPath);
    if (search && search.length > 0) url += ('?' + search);

    console.log("loadComponent " + url + (divId ? " id " + divId : ''));
    $.ajax({ type:"GET", url:url, error:handleAjaxError, success: function(resp, status, jqXHR) {
        // console.log(resp);
        if (!resp) { callback(NotFound); }
        var isServerStatic = (jqXHR.getResponseHeader("Cache-Control").indexOf("max-age") >= 0);
        if (util.isString(resp) && resp.length > 0) {
            if (isJsPath || resp.slice(0,7) == 'define(') {
                console.log("loaded JS from " + url + (divId ? " id " + divId : ""));
                var compObj = eval(resp);
                if (compObj.template) {
                    if (isServerStatic) { componentCache.put(path, compObj); }
                    callback(compObj);
                } else {
                    var htmlUrl = (path.slice(-3) == '.js' ? path.slice(0, -3) : path) + '.vuet';
                    $.ajax({ type:"GET", url:htmlUrl, error:handleAjaxError, success: function (htmlText) {
                        compObj.template = htmlText;
                        if (isServerStatic) { componentCache.put(path, compObj); }
                        callback(compObj);
                    }});
                }
            } else {
                var templateText = resp.replace(/<script/g, '<m-script').replace(/<\/script>/g, '</m-script>').replace(/<link/g, '<m-stylesheet');
                console.log("loaded HTML template from " + url + (divId ? " id " + divId : "") /*+ ": " + templateText*/);
                var compObj = { template: '<div' + (divId && divId.length > 0 ? ' id="' + divId + '"' : '') + '>' + templateText + '</div>' };
                if (isServerStatic) { componentCache.put(path, compObj); }
                callback(compObj);
            }
        } else if (resp === Object(resp)) {
            if (resp.screenUrl && resp.screenUrl.length > 0) { this.$root.setUrl(resp.screenUrl); }
            else if (resp.redirectUrl && resp.redirectUrl.length > 0) { window.location.replace(resp.redirectUrl); }
        } else { callback(NotFound); }
    }});
}

/* ========== placeholder components ========== */
var NotFound = Vue.extend({ template: '<div id="current-page-root"><h4>Screen not found at {{this.$root.currentPath}}</h4></div>' });
var EmptyComponent = Vue.extend({ template: '<div id="current-page-root"><div class="spinner"><div>Loading…</div></div></div>' });

/* ========== inline components ========== */
Vue.component('m-link', {
    props: { href:{type:String,required:true}, loadId:String },
    template: '<a :href="linkHref" @click.prevent="go"><slot></slot></a>',
    methods: { go: function() { if (this.loadId && this.loadId.length > 0) { this.$root.loadContainer(this.loadId, this.href); }
        else { this.$root.setUrl(this.href); } }},
    computed: { linkHref: function () { return this.href.indexOf(this.$root.basePath) == 0 ? this.href.replace(this.$root.basePath, this.$root.linkBasePath) : this.href; } }
});
Vue.component('m-script', {
    props: { src:String, type:{type:String,'default':'text/javascript'} },
    template: '<div :type="type" style="display:none;"><slot></slot></div>',
    created: function() { if (this.src && this.src.length > 0) { loadScript(this.src); } },
    mounted: function() {
        var innerText = this.$el.innerText;
        if (innerText && innerText.trim().length > 0) {
            // console.log('running: ' + innerText);
            retryInlineScript(innerText, 1);
            /* these don't work on initial load (with script elements that have @src followed by inline script)
            // eval(innerText);
            var parent = this.$el.parentElement; var s = document.createElement('script');
            s.appendChild(document.createTextNode(this.$el.innerText)); parent.appendChild(s);
            */
        }
        // maybe better not to, nice to see in dom: $(this.$el).remove();
    }
});
Vue.component('m-stylesheet', {
    props: { href:{type:String,required:true}, rel:{type:String,'default':'stylesheet'}, type:{type:String,'default':'text/css'} },
    template: '<div :type="type" style="display:none;"></div>',
    created: function() { loadStylesheet(this.href, this.rel, this.type); }
});
/* ========== layout components ========== */
Vue.component('container-box', { template:
    '<div class="panel panel-default">' +
        '<div class="panel-heading">' +
            '<slot name="header"></slot>' +
            '<div class="panel-toolbar"><slot name="toolbar"></slot></div>' +
        '</div>' +
        '<slot></slot>' +
    '</div>'
});
Vue.component('box-body', { template: '<div class="panel-body"><slot></slot></div>' });
Vue.component('container-dialog', {
    props: { id:{type:String,required:true}, title:String, width:{type:String,'default':'760'}, openDialog:{type:Boolean,'default':false} },
    data: function() { return { isHidden:true, dialogStyle:{width:this.width + 'px'}}},
    template:
    '<div :id="id" class="modal dynamic-dialog" aria-hidden="true" style="display: none;" tabindex="-1">' +
        '<div class="modal-dialog" :style="dialogStyle"><div class="modal-content">' +
            '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
                '<h4 class="modal-title">{{title}}</h4></div>' +
            '<div class="modal-body"><slot></slot></div>' +
        '</div></div>' +
    '</div>',
    methods: { hide: function() { $(this.$el).modal('hide'); } },
    mounted: function() {
        var jqEl = $(this.$el); var vm = this;
        jqEl.on("hidden.bs.modal", function() { vm.isHidden = true; });
        jqEl.on("shown.bs.modal", function() { vm.isHidden = false;
                jqEl.find(":not(.noselect2)>select:not(.noselect2)").select2({ }); jqEl.find(".default-focus").focus(); });
        if (this.openDialog) { jqEl.modal('show'); }
    }
});
Vue.component('dynamic-container', {
    props: { id:{type:String,required:true}, url:{type:String} },
    data: function() { return { curComponent:EmptyComponent, curUrl:"" } },
    template: '<component :is="curComponent"></component>',
    methods: { reload: function() { var saveUrl = this.curUrl; this.curUrl = ""; var vm = this; setTimeout(function() { vm.curUrl = saveUrl; }, 20); },
        load: function(url) { this.curUrl = url; }},
    watch: { curUrl: function(newUrl) {
        if (!newUrl || newUrl.length === 0) { this.curComponent = EmptyComponent; return; }
        var vm = this; loadComponent(newUrl, function(comp) { vm.curComponent = comp; }, this.id);
    }},
    mounted: function() { this.$root.addContainer(this.id, this); this.curUrl = this.url; }
});
Vue.component('dynamic-dialog', {
    props: { id:{type:String,required:true}, url:{type:String,required:true}, title:String, width:{type:String,'default':'760'},
        openDialog:{type:Boolean,'default':false} },
    data: function() { return { curComponent:EmptyComponent, curUrl:"", isHidden:true, dialogStyle:{width:this.width + 'px'}}},
    template:
    '<div :id="id" class="modal dynamic-dialog" aria-hidden="true" style="display: none;" tabindex="-1">' +
        '<div class="modal-dialog" :style="dialogStyle"><div class="modal-content">' +
            '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
                '<h4 class="modal-title">{{title}}</h4></div>' +
            '<div class="modal-body"><component :is="curComponent"></component></div>' +
        '</div></div>' +
    '</div>',
    methods: {
        reload: function() { if (!this.isHidden) { var jqEl = $(this.$el); jqEl.modal('hide'); jqEl.modal('show'); }},
        load: function(url) { this.curUrl = url; }, hide: function() { $(this.$el).modal('hide'); }
    },
    watch: { curUrl: function (newUrl) { if (!newUrl || newUrl.length === 0) { this.curComponent = EmptyComponent; return; }
        var vm = this; loadComponent(newUrl, function(comp) { vm.curComponent = comp; }, this.id); }},
    mounted: function() {
        this.$root.addContainer(this.id, this); var jqEl = $(this.$el); var vm = this;
        jqEl.on("show.bs.modal", function() { vm.curUrl = vm.url; });
        jqEl.on("hidden.bs.modal", function() { vm.isHidden = true; vm.curUrl = ""; });
        jqEl.on("shown.bs.modal", function() { vm.isHidden = false;
                jqEl.find(":not(.noselect2)>select:not(.noselect2)").select2({ }); jqEl.find(".default-focus").focus(); });
        if (this.openDialog) { jqEl.modal('show'); }
    }
});
Vue.component('tree-top', {
    template: '<ul :id="id" class="tree-list"><tree-item v-for="model in itemList" :model="model" :top="top"/></ul>',
    props: { id:{type:String,required:true}, items:{type:[String,Array],required:true}, openPath:String, parameters:Object },
    data: function() { return { urlItems:null, currentPath:null, top:this }},
    computed: {
        itemList: function() { if (this.urlItems) { return this.urlItems; } return util.isArray(this.items) ? this.items : []; }
    },
    methods: { },
    mounted: function() { if (util.isString(this.items)) {
        this.currentPath = this.openPath;
        var allParms = $.extend({ moquiSessionToken:this.$root.moquiSessionToken, treeNodeId:'#', treeOpenPath:this.openPath }, this.parameters);
        // console.log('tree-top parms ' + JSON.stringify(allParms));
        var vm = this; $.ajax({ type:'POST', dataType:'json', url:this.items, headers:{Accept:'application/json'}, data:allParms,
            error:handleAjaxError, success:function(resp) { vm.urlItems = resp; /*console.log('tree-top response ' + JSON.stringify(resp));*/ } });
    }}
});
Vue.component('tree-item', {
    template:
    '<li :id="model.id">' +
        '<i v-if="isFolder" @click="toggle" class="glyphicon" :class="{\'glyphicon-chevron-right\':!open, \'glyphicon-chevron-down\':open}"></i>' +
        '<span v-else style="width:1em;display:inline-block;"></span>' +
        ' <span @click="setSelected"><m-link :href="model.a_attr.urlText" :load-id="model.a_attr.loadId" :class="{\'text-success\':selected}">{{model.text}}</m-link></span>' +
        '<ul v-show="open" v-if="hasChildren"><tree-item v-for="model in model.children" :model="model" :top="top"/></ul></li>',
    props: { model:Object, top:Object },
    data: function() { return { open:false }},
    computed: {
        isFolder: function() { var children = this.model.children; if (!children) { return false; }
            if (util.isArray(children)) { return children.length > 0 } return true; },
        hasChildren: function() { var children = this.model.children; return util.isArray(children) && children.length > 0; },
        selected: function() { return this.top.currentPath == this.model.id; }
    },
    watch: { open: function(newVal) { if (newVal) {
        var children = this.model.children;
        var url = this.top.items;
        if (this.open && children && util.isBoolean(children) && util.isString(url)) {
            var li_attr = this.model.li_attr;
            var allParms = $.extend({ moquiSessionToken:this.$root.moquiSessionToken, treeNodeId:this.model.id,
                treeNodeName:(li_attr && li_attr.treeNodeName ? li_attr.treeNodeName : ''), treeOpenPath:this.top.currentPath }, this.top.parameters);
            // console.log('tree-item parms ' + JSON.stringify(allParms));
            var vm = this; $.ajax({ type:'POST', dataType:'json', url:url, headers:{Accept:'application/json'}, data:allParms,
                error:handleAjaxError, success:function(resp) { vm.model.children = resp; } });
        }
    }}},
    methods: {
        toggle: function() { if (this.isFolder) { this.open = !this.open; } },
        setSelected: function() { this.top.currentPath = this.model.id; this.open = true; }
    },
    mounted: function() { if (this.model.state && this.model.state.opened) { this.open = true; } }
});
/* ========== general field components ========== */
Vue.component('m-editable', {
    props: { id:{type:String,required:true}, labelType:{type:String,'default':'span'}, labelValue:{type:String,required:true},
        url:{type:String,required:true}, urlParameters:{type:Object,'default':{}},
        parameterName:{type:String,'default':'value'}, widgetType:{type:String,'default':'textarea'},
        loadUrl:String, loadParameters:Object, indicator:{type:String,'default':'Saving'}, tooltip:{type:String,'default':'Click to edit'},
        cancel:{type:String,'default':'Cancel'}, submit:{type:String,'default':'Save'} },
    mounted: function() {
        var reqData = $.extend({ moquiSessionToken:this.$root.moquiSessionToken, parameterName:this.parameterName }, this.urlParameters);
        var edConfig = { indicator:this.indicator, tooltip:this.tooltip, cancel:this.cancel, submit:this.submit,
                name:this.parameterName, type:this.widgetType, cssclass:'editable-form', submitdata:reqData };
        if (this.loadUrl && this.loadUrl.length > 0) {
            var vm = this; edConfig.loadurl = this.loadUrl; edConfig.loadtype = "POST";
            edConfig.loaddata = function(value) { return $.extend({ currentValue:value, moquiSessionToken:vm.$root.moquiSessionToken }, vm.loadParameters); };
        }
        $(this.$el).editable(this.url, edConfig);
    },
    render: function(createEl) { return createEl(this.labelType, { attrs:{ id:this.id, 'class':'editable-label' }, domProps: { innerHTML:this.labelValue } }); }
});

/* ========== form components ========== */
Vue.component('m-form', {
    props: { action:{type:String,required:true}, method:{type:String,'default':'POST'},
        submitMessage:String, submitReloadId:String, submitHideId:String, focusField:String, noValidate:Boolean },
    data: function() { return { fields:{} }},
    template: '<form @submit.prevent="submitForm" class="validation-engine-init"><slot></slot></form>',
    methods: {
        submitForm: function submitForm() {
            var jqEl = $(this.$el);
            if (this.noValidate || jqEl.valid()) {
                var allParms = $.extend({ moquiSessionToken:this.$root.moquiSessionToken }, this.fields);
                var $btn = $(document.activeElement);
                if ($btn.length && jqEl.has($btn) && $btn.is('button[type="submit"], input[type="submit"], input[type="image"]') && $btn.is('[name]')) {
                    allParms[$btn.attr('name')] = $btn.val(); }

                var parmList = jqEl.serializeArray();
                for (var i=0; i<parmList.length; i++) {
                    var parm = parmList[i];
                    var cur = allParms[parm.name];
                    if (cur) { if (util.isArray(cur)) { cur.push(parm.value); } else { allParms[parm.name] = [cur, parm.value]; } }
                    else { allParms[parm.name] = parm.value; }
                }
                // console.log('m-form parameters ' + JSON.stringify(allParms));
                $.ajax({ type:this.method, url:this.action, data:allParms, headers:{Accept:'application/json'},
                    error:handleAjaxError, success:this.handleResponse });
            }
        },
        handleResponse: function(resp) {
            var notified = false;
            // console.log('m-form response ' + JSON.stringify(resp));
            if (resp && resp === Object(resp)) {
                if (resp.messages) for (var mi=0; mi < resp.messages.length; mi++) {
                    $.notify({ message:resp.messages[mi] }, $.extend({}, notifyOpts, {type:'info'})); notified = true; }
                if (resp.errors) for (var ei=0; ei < resp.messages.length; ei++) {
                    $.notify({ message:resp.messages[ei] }, $.extend({}, notifyOpts, {delay:60000, type:'danger'})); notified = true; }
                if (resp.screenUrl && resp.screenUrl.length > 0) { this.$root.setUrl(resp.screenUrl); }
                else if (resp.redirectUrl && resp.redirectUrl.length > 0) { window.location.href = resp.redirectUrl; }
            } else { console.log('m-form no reponse or non-JSON response: ' + JSON.stringify(resp)) }
            if (this.submitHideId && this.submitHideId.length > 0) { $('#' + this.submitHideId).modal('hide'); }
            if (this.submitReloadId && this.submitReloadId.length > 0) { this.$root.reloadContainer(this.submitReloadId); }
            var msg = this.submitMessage && this.submitMessage.length > 0 ? this.submitMessage : (notified ? null : "Form data saved");
            if (msg) $.notify({ message:msg }, $.extend({}, notifyOpts, {type:'success'}));
        }
    },
    mounted: function() {
        var jqEl = $(this.$el);
        if (!this.noValidate) jqEl.validate({ errorClass: 'help-block', errorElement: 'span',
            highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
            unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
        });
        jqEl.find('[data-toggle="tooltip"]').tooltip();
        if (this.focusField && this.focusField.length > 0) jqEl.find('[name=' + this.focusField + ']').addClass('default-focus').focus();
    }
});
Vue.component('form-link', {
    props: { action:{type:String,required:true}, focusField:String, noValidate:Boolean },
    data: function() { return { fields:{} }},
    template: '<form @submit.prevent="submitForm" class="validation-engine-init"><slot></slot></form>',
    methods: {
        submitForm: function submitForm() {
            var jqEl = $(this.$el); if (this.noValidate || jqEl.valid()) {
                var otherParms = this.fields;
                var parmStr = ""; var parmList = jqEl.serializeArray();
                for (var parmName in otherParms) { if (otherParms.hasOwnProperty(parmName)) {
                    if (parmStr.length > 0) { parmStr += '&'; } parmStr += (parmName + '=' + otherParms[parmName]); }}
                var extraList = []; var plainKeyList = [];
                for (var pi=0; pi<parmList.length; pi++) {
                    var parm = parmList[pi]; var key = parm.name; var value = parm.value;
                    if (value.length == 0 || key == "moquiSessionToken" || key.indexOf('%5B%5D') > 0) continue;
                    if (key.indexOf("_op") > 0 || key.indexOf("_not") > 0 || key.indexOf("_ic") > 0) { extraList.push(parm); }
                    else {
                        plainKeyList.push(key);
                        if (parmStr.length > 0) { parmStr += '&'; }
                        parmStr += (encodeURIComponent(key) + '=' + encodeURIComponent(value));
                    }
                }
                for (var ei=0; ei<extraList.length; ei++) {
                    var eparm = extraList[ei]; var keyName = eparm.name.substring(0, eparm.name.indexOf('_'));
                    if (plainKeyList.indexOf(keyName) >= 0) {
                        if (parmStr.length > 0) { parmStr += '&'; }
                        parmStr += (encodeURIComponent(eparm.name) + '=' + encodeURIComponent(eparm.value));
                    }
                }
                var url = this.action;
                if (url.indexOf('?') > 0) { url = url + '&' + parmStr; } else { url = url + '?' + parmStr; }
                this.$root.setUrl(url);
            }
        }
    },
    mounted: function() {
        var jqEl = $(this.$el);
        if (!this.noValidate) jqEl.validate({ errorClass: 'help-block', errorElement: 'span',
            highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
            unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
        });
        jqEl.find('[data-toggle="tooltip"]').tooltip();
        if (this.focusField && this.focusField.length > 0) jqEl.find('[name=' + this.focusField + ']').addClass('default-focus').focus();
    }
});

/* ========== form field widget components ========== */
Vue.component('drop-down', {
    props: { options:Array, value:[Array,String], combo:Boolean, allowEmpty:Boolean, multiple:String,
        optionsUrl:String, optionsParameters:Object, labelField:String, valueField:String, dependsOn:Object },
    data: function() { return { curData: null, s2Opts: null } },
    template: '<select><slot></slot></select>',
    methods: {
        populateFromUrl: function() {
            if (!this.optionsUrl || this.optionsUrl.length === 0) return;
            var hasAllParms = true; var dependsOnMap = this.dependsOn; var parmMap = this.optionsParameters;
            var reqData = { moquiSessionToken: this.$root.moquiSessionToken };
            for (var parmName in parmMap) { if (parmMap.hasOwnProperty(parmName)) reqData[parmName] = parmMap[parmName]; }
            for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                var doValue = $('#' + dependsOnMap[doParm]).val(); if (!doValue) { hasAllParms = false; break; } reqData[doParm] = doValue; }}
            if (!hasAllParms) { this.curData = null; return; }
            var vm = this; $.ajax({ type:"POST", url:this.optionsUrl, data:reqData, dataType:"json", error:handleAjaxError, success: function(list) { if (list) {
                var newData = []; if (vm.allowEmpty) newData.push({ id:'', text:'' });
                var labelField = vm.labelField; if (!labelField) labelField = "label";
                var valueField = vm.valueField; if (!valueField) valueField = "value";
                $.each(list, function(idx, curObj) { newData.push({ id: curObj[valueField], text: curObj[labelField] }) });
                vm.curData = newData;
            }}});
        }
    },
    mounted: function() {
        var vm = this; var opts = { minimumResultsForSearch:15 };
        if (this.combo) { opts.tags = true; opts.tokenSeparators = [',',' ']; }
        if (this.multiple == "multiple") { opts.multiple = true; }
        if (this.options && this.options.length > 0) { opts.data = this.options; }
        this.s2Opts = opts; var jqEl = $(this.$el);
        jqEl.select2(opts).on('change', function () { vm.$emit('input', this.value); })
            .on('select2:select', function () { jqEl.select2('open').select2('close'); });
        if (this.value && this.value.length > 0) { this.curVal = this.value; }
        if (this.optionsUrl && this.optionsUrl.length > 0) {
            var dependsOnMap = this.dependsOn;
            for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                $('#' + dependsOnMap[doParm]).on('change', function() { vm.populateFromUrl(); }); }}
            this.populateFromUrl();
        }
    },
    computed: { curVal: { get: function() { return $(this.$el).select2().val(); },
        set: function(value) { $(this.$el).val(value).trigger('change'); } } },
    watch: { value: function(value) { this.curVal = value; }, options: function(options) { this.curData = options; },
        curData: function(options) { this.s2Opts.data = options; $(this.$el).select2(this.s2Opts); } },
    destroyed: function() { $(this.$el).off().select2('destroy') }
});
Vue.component('text-autocomplete', {
    props: { id:{type:String,required:true}, name:{type:String,required:true}, value:String, valueText:String,
        type:String, size:String, maxlength:String, disabled:Boolean, validationClasses:String, dataVvValidation:String,
        required:Boolean, pattern:String, tooltip:String, form:String,
        url:{type:String,required:true}, dependsOn:Object, acParameters:Object, minLength:Number, showValue:Boolean, useActual:Boolean, skipInitial:Boolean },
    template:
    '<span><input ref="acinput" :id="acId" :name="acName" :type="type" :value="valueText" :size="size" :maxlength="maxlength" :disabled="disabled"' +
        ' :class="allClasses" :data-vv-validation="validationClasses" :required="required" :pattern="pattern"' +
        ' :data-toggle="tooltipToggle" :title="tooltip" autocomplete="off" :form="form">' +
        '<input ref="hidden" :id="id" type="hidden" :name="name" :value="value" :form="form">' +
        '<span ref="show" v-if="showValue" :id="showId" class="form-autocomplete-value">{{valueText}}</span>' +
    '</span>',
    computed: { acId: function() { return this.id + '_ac'; }, acName: function() { return this.name + '_ac'; },
        allClasses: function() { return 'form-control typeahead' + (this.validationClasses ? ' ' + this.validationClasses : ''); },
        showId: function() { return this.id + '_show'; }, tooltipToggle: function() { return this.tooltip && this.tooltip.length > 0 ? 'tooltip' : null; }
    },
    mounted: function() {
        var vm = this; var acJqEl = $(this.$refs.acinput); var hidJqEl = $(this.$refs.hidden);
        var showJqEl = this.$refs.show ? $(this.$refs.show) : null;
        acJqEl.typeahead({ minLength:(this.minLength ? this.minLength : 1), highlight:true, hint:false }, { limit:20,
            source: function(query, syncResults, asyncResults) {
                var dependsOnMap = vm.dependsOn; var parmMap = vm.acParameters;
                var reqData = { term: query, moquiSessionToken: vm.$root.moquiSessionToken };
                for (var parmName in parmMap) { if (parmMap.hasOwnProperty(parmName)) reqData[parmName] = parmMap[parmName]; }
                for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                    var doValue = $('#' + dependsOnMap[doParm]).val(); if (doValue) reqData[doParm] = doValue; }}
                $.ajax({ url: vm.url, type:"POST", dataType:"json", data:reqData, error:handleAjaxError, success: function(data) {
                    asyncResults($.map(data, function(item) { return { label:item.label, value:item.value } })); }});
            }, display: function(item) { return item.label; }
        });
        acJqEl.bind('typeahead:select', function(event, item) {
            if (item) { this.value = item.value; hidJqEl.val(item.value); hidJqEl.trigger("change"); acJqEl.val(item.label);
                if (showJqEl && item.label) { showJqEl.html(item.label); } return false; }
        });
        acJqEl.change(function() { if (!acJqEl.val()) { hidJqEl.val(""); hidJqEl.trigger("change"); }
                else if (this.useActual) { hidJqEl.val(acJqEl.val()); hidJqEl.trigger("change"); } });
        var dependsOnMap = this.dependsOn;
        for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
            $('#' + dependsOnMap[doParm]).change(function() { hidJqEl.val(""); acJqEl.val(""); }); }}
        if (!this.skipInitial && hidJqEl.val()) {
            var parmMap = this.acParameters;
            var reqData = { term: hidJqEl.val(), moquiSessionToken: this.$root.moquiSessionToken };
            for (var parmName in parmMap) { if (parmMap.hasOwnProperty(parmName)) reqData[parmName] = parmMap[parmName]; }
            for (doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                var doValue = $('#' + dependsOnMap[doParm]).val(); if (doValue) reqData[doParm] = doValue; }}
            $.ajax({ url:this.url, type:"POST", dataType:"json", data:reqData, error:handleAjaxError, success: function(data) {
                var curValue = hidJqEl.val();
                for (var i = 0; i < data.length; i++) { if (data[i].value == curValue) {
                    acJqEl.val(data[i].label); if (showJqEl) { showJqEl.html(data[i].label); } break; }}
            }});
        }
    }
});

/* ========== webrootVue - root Vue component with router ========== */
Vue.component('subscreens-tabs', {
    data: function() { return { pathIndex:-1 }},
    template:
    '<ul v-if="subscreens.length > 0" class="nav nav-tabs" role="tablist">' +
        '<li v-for="tab in subscreens" :class="{active:tab.active,disabled:tab.disableLink}">' +
            '<span v-if="tab.disabled">{{tab.title}}</span>' +
            '<m-link v-else :href="tab.pathWithParams">{{tab.title}}</m-link>' +
        '</li>' +
    '</ul>',
    computed: { subscreens: function() {
        if (!this.pathIndex || this.pathIndex < 0) return [];
        var navMenu = this.$root.navMenuList[this.pathIndex];
        if (!navMenu || !navMenu.subscreens) return [];
        return navMenu.subscreens;
    }},
    // this approach to get pathIndex won't work if the subscreens-active tag comes before subscreens-tabs
    mounted: function() { this.pathIndex = this.$root.activeSubscreens.length; }
});
Vue.component('subscreens-active', {
    data: function() { return { activeComponent:EmptyComponent, pathIndex:-1, pathName:null } },
    template: '<component :is="activeComponent"></component>',
    // method instead of a watch on pathName so that it runs even when newPath is the same for non-static reloading
    methods: { loadActive: function() {
        var vm = this; var root = vm.$root; var pathIndex = vm.pathIndex; var curPathList = root.currentPathList;
        var newPath = curPathList[pathIndex];
        var pathChanged = (this.pathName != newPath);
        this.pathName = newPath;
        if (!newPath || newPath.length === 0) { this.activeComponent = EmptyComponent; return true; }
        var fullPath = root.basePath + '/' + curPathList.slice(0, pathIndex + 1).join('/');
        if (!pathChanged && componentCache.containsKey(fullPath)) { return false; } // no need to reload component
        var urlInfo = { path:fullPath };
        if (pathIndex == (curPathList.length - 1)) {
            var extra = root.extraPathList; if (extra && extra.length > 0) { urlInfo.extraPath = extra.join('/'); } }
        var search = root.currentSearch; if (search && search.length > 0) { urlInfo.search = search; }
        console.log('subscreens-active loadActive pathIndex ' + pathIndex + ' pathName ' + vm.pathName + ' urlInfo ' + JSON.stringify(urlInfo));
        root.loading++;
        loadComponent(urlInfo, function(comp) { vm.activeComponent = comp; root.loading--; });
        return true;
    }},
    mounted: function() { this.$root.addSubscreen(this); }
});
var webrootVue = new Vue({
    el: '#apps-root',
    data: { basePath:"", linkBasePath:"", currentPathList:[], extraPathList:[], activeSubscreens:[], currentParameters:{},
        navMenuList:[], navHistoryList:[], navPlugins:[], lastNavTime:Date.now(), loading:0, activeContainers:{},
        moquiSessionToken:"", appHost:"", appRootPath:"", userId:"", notificationClient:null },
    methods: {
        setUrl: function (url) {
            // make sure any open modals are closed before setting currentUrl
            $('.modal.in').modal('hide');
            if (url.indexOf(this.basePath) == 0) url = url.replace(this.basePath, this.linkBasePath);
            // NOTE: this may have to change, don't set to empty first as kills the path diff based load
            if (this.currentUrl == url) {  this.currentUrl = ""; var vm = this; setTimeout(function() { vm.currentUrl = url; }, 10) }
            else { this.currentUrl = url; window.history.pushState(null, this.ScreenTitle, url); }
        },
        addSubscreen: function(saComp) {
            var pathIdx = this.activeSubscreens.length;
            // console.log('addSubscreen idx ' + pathIdx + ' pathName ' + this.currentPathList[pathIdx]);
            saComp.pathIndex = pathIdx;
            // setting pathName here handles initial load of subscreens-active; this may be undefined if we have more activeSubscreens than currentPathList items
            saComp.loadActive();
            this.activeSubscreens.push(saComp);
        },
        // all container components added with this must have reload() and load(url) methods
        addContainer: function(contId, comp) { this.activeContainers[contId] = comp; },
        reloadContainer: function(contId) { var contComp = this.activeContainers[contId];
            if (contComp) { contComp.reload(); } else { console.log("Container with ID " + contId + " not found, not reloading"); }},
        loadContainer: function(contId, url) { var contComp = this.activeContainers[contId];
            if (contComp) { contComp.load(url); } else { console.log("Container with ID " + contId + " not found, not loading url " + url); }},
        addNavPlugin: function(url) { var vm = this; loadComponent(url, function(comp) { vm.navPlugins.push(comp); }) },
        switchDarkLight: function() {
            var jqBody = $("body"); jqBody.toggleClass("bg-dark"); jqBody.toggleClass("bg-light");
            var currentStyle = jqBody.hasClass("bg-dark") ? "bg-dark" : "bg-light";
            $.ajax({ type:'POST', url:'/apps/setPreference', data:{ moquiSessionToken: this.moquiSessionToken,
                preferenceKey:'OUTER_STYLE', preferenceValue:currentStyle } });
        }
    },
    watch: {
        currentUrl: function(newUrl) {
            if (!newUrl || newUrl.length === 0) return;
            var vm = this;
            console.log("currentUrl changing to " + newUrl);
            this.lastNavTime = Date.now();
            // TODO: somehow only clear out activeContainers that are in subscreens actually reloaded? may cause issues if any but last screen have dynamic-container
            this.activeContainers = {};
            // update menu, which triggers update of screen/subscreen components
            $.ajax({ type:"GET", url:"/menuData" + newUrl, dataType:"json", error:handleAjaxError, success: function(outerList) {
                if (outerList) { vm.navMenuList = outerList; /*console.log('navMenuList ' + JSON.stringify(outerList));*/ } }});
        },
        navMenuList: function(newList) { if (newList.length > 0) {
            var cur = newList[newList.length - 1]; var par = newList.length > 1 ? newList[newList.length - 2] : null;
            // if there is an extraPathList set it now
            if (cur.extraPathList) this.extraPathList = cur.extraPathList;
            // make sure full currentPathList and activeSubscreens is populated (necessary for minimal path urls)
            var basePathSize = this.basePath.split('/').length;
            var fullPathList = cur.path.split('/').slice(basePathSize);
            console.log('nav updated fullPath ' + JSON.stringify(fullPathList) + ' currentPathList ' + JSON.stringify(this.currentPathList));
            this.currentPathList = fullPathList;

            if (fullPathList.length == 0 && this.activeSubscreens.length > 0) { this.activeSubscreens[0].loadActive(); this.activeSubscreens.splice(1); return; }
            for (var i=0; i<this.activeSubscreens.length; i++) {
                if (i >= fullPathList.length) break;
                // always try loading the active subscreen and see if actually loaded
                var loaded = this.activeSubscreens[i].loadActive();
                // clear out remaining activeSubscreens, after first changed loads its placeholders will register and load
                if (loaded) this.activeSubscreens.splice(i+1);
            }

            // update history and document.title
            var newTitle = (par ? par.title + ' - ' : '') + cur.title;
            var curUrl = cur.pathWithParams; var questIdx = curUrl.indexOf("?");
            if (questIdx > 0) {
                var parmList = curUrl.substring(questIdx+1).split("&");
                curUrl = curUrl.substring(0, questIdx);
                var dpCount = 0; var titleParms = "";
                for (var pi=0; pi<parmList.length; pi++) {
                    var parm = parmList[pi]; if (parm.indexOf("pageIndex=") == 0) continue;
                    if (curUrl.indexOf("?") == -1) { curUrl += "?"; } else { curUrl += "&"; }
                    curUrl += parm;
                    if (dpCount > 1) continue; // add up to 2 parms to the title
                    var eqIdx = parm.indexOf("=");
                    if (eqIdx > 0) {
                        var key = parm.substring(0, eqIdx);
                        if (key.indexOf("_op") > 0 || key.indexOf("_not") > 0 || key.indexOf("_ic") > 0 || key == "moquiSessionToken") continue;
                        if (titleParms.length > 0) titleParms += ", ";
                        titleParms += parm.substring(eqIdx + 1);
                    }
                }
                if (titleParms.length > 0) newTitle = newTitle + " (" + titleParms + ")";
            }
            for (var hi=0; hi<this.navHistoryList.length;) {
                if (this.navHistoryList[hi].pathWithParams == curUrl) { this.navHistoryList.splice(hi,1); } else { hi++; } }
            this.navHistoryList.unshift({ title:newTitle, pathWithParams:curUrl, image:cur.image, imageType:cur.imageType });
            while (this.navHistoryList.length > 25) { this.navHistoryList.pop(); }
            document.title = newTitle;
        }},
        currentPathList: function(newList) {
            // console.log('set currentPathList to ' + JSON.stringify(newList) + ' activeSubscreens.length ' + this.activeSubscreens.length);
            var lastPath = newList[newList.length - 1];
            if (lastPath) { $(this.$el).removeClass().addClass(lastPath); }
        }
    },
    computed: {
        currentPath: {
            get: function() { return this.basePath + '/' + this.currentPathList.join('/') +
                (this.extraPathList && this.extraPathList.length > 0 ? '/' + this.extraPathList.join('/') : ''); },
            set: function(newPath) {
                if (!newPath || newPath.length == 0) { this.currentPathList = []; return; }
                if (newPath.slice(newPath.length - 1) == '/') newPath = newPath.slice(0, newPath.length - 1);
                var basePathSize = this.basePath.split('/').length;
                this.currentPathList = newPath.split('/').slice(basePathSize);
            }},
        currentLinkPath: function() { return this.linkBasePath + '/' + this.currentPathList.join('/'); },
        currentSearch: {
            get: function() { var search = ''; $.each(this.currentParameters, function (key, value) {
                search = search + (search.length > 0 ? '&' : '') + key + '=' + value; }); return search; },
            set: function(newSearch) {
                this.currentParameters = {}; if (!newSearch || newSearch.length == 0) { return; }
                var parmList = newSearch.split("&");
                for (var i=0; i<parmList.length; i++) {
                    var parm = parmList[i]; var ps = parm.split("="); if (ps.length > 1) { this.currentParameters[ps[0]] = ps[1]; } }
            }},
        currentUrl: {
            get: function() { var srch = this.currentSearch; return this.currentPath + (srch.length > 0 ? '?' + srch : ''); },
            set: function(href) {
                var ssIdx = href.indexOf('//');
                if (ssIdx >= 0) { var slIdx = href.indexOf('/', ssIdx + 1); if (slIdx == -1) { return; } href = href.slice(slIdx); }
                var splitHref = href.split("?");
                // clear out extra path, to be set from nav menu data if needed
                this.extraPathList = [];
                // set currentSearch before currentPath so that it is available when path updates
                if (splitHref.length > 1 && splitHref[1].length > 0) { this.currentSearch = splitHref[1]; } else { this.currentSearch = ""; }
                this.currentPath = splitHref[0];
            }
        },
        currentLinkUrl: function() { var srch = this.currentSearch; return this.currentLinkPath + (srch.length > 0 ? '?' + srch : ''); },
        ScreenTitle: function() { return this.navMenuList.length > 0 ? this.navMenuList[this.navMenuList.length - 1].title : ""; }
    },
    components: {
        'add-nav-plugin': { props:{url:{type:String,required:true}}, template:'<span></span>',
            mounted:function() { this.$root.addNavPlugin(this.url); Vue.util.remove(this.$el); }}
    },
    created: function() {
        this.moquiSessionToken = $("#moquiSessionToken").val();
        this.appHost = $("#appHost").val(); this.appRootPath = $("#appRootPath").val();
        this.basePath = $("#basePath").val(); this.linkBasePath = $("#linkBasePath").val();
        this.userId = $("#userId").val();
        this.notificationClient = new moqui.NotificationClient("ws://" + this.appHost + this.appRootPath + "/notws");
    },
    mounted: function() {
        $('.navbar [data-toggle="tooltip"]').tooltip();
        $('#history-menu-link').tooltip({ placement:'bottom', trigger:'hover' });
        // load the current screen
        this.currentUrl = window.location.pathname + window.location.search;
        // init the NotificationClient and register 'displayNotify' as the default listener
        this.notificationClient.registerListener("ALL");
    }
});
window.addEventListener('popstate', function() { webrootVue.setUrl(window.location.pathname + window.location.search); });
})(moqui, $, Vue);

