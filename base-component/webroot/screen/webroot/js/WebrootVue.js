/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

/* TODO:
 - add fully client rendered version of form-list when it has data prep embedded
   - add form-list.rest-entity, rest-service (or just rest-call?), and maybe service-call/actions/etc
   - now enabled with form-list.@server-static=vuet
   - pagination
     - implement dynamic pagination header based on response headers
     - handle search parameters in some way other than $root.currentParameters so that page loads are not triggered on paginate
   - for display implement client side formatting based on display.@format; defaults for date/time, numbers, etc

 - authorization in separate requests issue
   - implied screen authz (user has authz for child screen for not parent, so implied for parent); see moqui-runtime issue #71
   - inherited REST authz (REST services used in screen and user has authz for screen)
 - client side localization using $root.locale string
   - some sort of moqui.l10n object with entries for each locale, then entries for each string
   - get translations on the fly from the server and cache locally?

 - going to minimal path causes menu reload; avoid? better to cache menus and do partial requests...

 - use vue-aware widgets or add vue component wrappers for scripts and widgets
 - remove as many inline m-script elements as possible...

 - anchor (a) only used for link if UrlInstance.isScreenUrl() is false which looks only at default-response for url-type=plain or
   type=none; if a transition has conditional or error responses of different types it won't response properly
   - consider changing loadComponent to pass a header telling ScreenRenderImpl that it is for a component
   - in ScreenRenderImpl if we are sending back content handle some other way...
   - in SRI if redirecting to screen send JSON obj with screenUrl or for non-screen redirectUrl


 - big new feature for client rendered screens
   - on the server render to a Vue component object in JS file following pattern of MyAccountNav.js with define(), allow separate .vuet file
   - make these completely static, not dependent on any inline data, so they can be cached
   - separate request(s) to get data to populate
 - screen structure (Vue specific...)
   - use existing XML Screen with a new client-template and other elements?
   - screen should have extension .js.xml so existing code finds things like FindExample.js for FindExample.js.xml
   - allow separate screen or static file with .vuet extension for template string
   - client-template element with vue template (ie pseudo html with JS expressions)
   - client-template would still be simplified using Moqui library of Vue components
   - other elements for vue properties like data, methods, mounted/etc lifecycle, computed, watch, etc
   - can these be compatible with other tools like Angular2, React, etc or need something higher level?
 - screen structure for any client library (Angular2, React, etc) possible?
   - goal would be to use FTL macros to transform more detailed XML into library specific output
 */

// simple stub for define if it doesn't exist (ie no require.js, etc); mimic pattern of require.js define()
if (!window.define) window.define = function(name, deps, callback) {
    if (!moqui.isString(name)) { callback = deps; deps = name; name = null; }
    if (!moqui.isArray(deps)) { callback = deps; deps = null; }
    if (moqui.isFunction(callback)) { return callback(); } else { return callback }
};
// map locale to a locale that exists in moment-with-locales.js
moqui.localeMap = { 'zh':'zh-cn' };
moqui.objToSearch = function(obj) {
    var search = '';
    $.each(obj, function (key, value) { search = search + (search.length > 0 ? '&' : '') + key + '=' + value; });
    return search;
};
moqui.searchToObj = function(search) {
    if (!search || search.length === 0) { return {}; }
    var newParams = {};
    var parmList = search.split("&");
    for (var i=0; i<parmList.length; i++) {
        var parm = parmList[i]; var ps = parm.split("=");
        if (ps.length > 1) {
            var key = ps[0]; var value = ps[1]; var exVal = newParams[key];
            if (exVal) { if (moqui.isArray(exVal)) { exVal.push(value); } else { newParams[key] = [exVal, value]; } }
            else { newParams[key] = value; }
        }
    }
    return newParams;
};
moqui.decodeHtml = function(html) { var txt = document.createElement("textarea"); txt.innerHTML = html; return txt.value; };
Vue.filter('decodeHtml', moqui.decodeHtml);
moqui.format = function(value, format, type) {
    // console.log('format ' + value + ' with ' + format + ' of type ' + type);
    // number formatting: http://numeraljs.com/ https://github.com/andrewgp/jsNumberFormatter http://www.asual.com/jquery/format/
    if (format && format.length) { format = format.replace(/a/,'A').replace(/d/,'D').replace(/y/,'Y'); } // change java date/time format to moment
    if (type && type.length) {
        type = type.toLowerCase();
        if (type === "date") {
            if (!format || format.length === 0) format = "YYYY-MM-DD";
            return moment(value).format(format);
        } else if (type === "time") {
            if (!format || format.length === 0) format = "HH:mm:ss";
            return moment(value).format(format);
        } else if (type === "timestamp") {
            if (!format || format.length === 0) format = "YYYY-MM-DD HH:mm";
            return moment(value).format(format);
        } else if (type === "bigdecimal" || type === "long" || type === "integer" || type === "double" || type === "float") {
            return value; // TODO format numbers
        } else {
            console.warn('format type unknown: ' + type);
        }
    }
    if (moqui.isNumber(value)) {
        return value; // TODO format numbers
    } else {
        // is it a number or any sort of date/time that moment supports? if anything else return as-is
        var momentVal = moment(value);
        if (momentVal.isValid()) {
            if (!format || format.length === 0) format = "YYYY-MM-DD HH:mm";
            return momentVal.format(format);
        }
        // TODO
        return value;
    }
};
Vue.filter('format', moqui.format);

/* ========== script and stylesheet handling methods ========== */
moqui.loadScript = function(src) {
    // make sure the script isn't loaded
    var loaded = false;
    $('head script').each(function(i, hscript) { if (hscript.src.indexOf(src) !== -1) loaded = true; });
    if (loaded) return;
    // add it to the header
    var script = document.createElement('script'); script.src = src; script.async = false;
    document.head.appendChild(script);
};
moqui.loadStylesheet = function(href, rel, type) {
    if (!rel) rel = 'stylesheet'; if (!type) type = 'text/css';
    // make sure the stylesheet isn't loaded
    var loaded = false;
    $('head link').each(function(i, hlink) { if (hlink.href.indexOf(href) !== -1) loaded = true; });
    if (loaded) return;
    // add it to the header
    var link = document.createElement('link'); link.href = href; link.rel = rel; link.type = type;
    document.head.appendChild(link);
};
moqui.retryInlineScript = function(src, count) {
    try { eval(src); } catch(e) {
        src = src.trim();
        console.warn('error ' + count + ' running inline script: ' + src.slice(0, 30) + '...');
        console.warn(e);
        if (count <= 5) setTimeout(moqui.retryInlineScript, 200, src, count+1);
    }
};

/* ========== notify and error handling ========== */
moqui.notifyOpts = { delay:1500, offset:{x:20,y:60}, placement:{from:'top',align:'right'}, z_index:1100, type:'success',
    animate:{ enter:'animated fadeInDown', exit:'' } }; // no animate on exit: animated fadeOutUp
moqui.notifyOptsInfo = { delay:3000, offset:{x:20,y:60}, placement:{from:'top',align:'right'}, z_index:1100, type:'info',
    animate:{ enter:'animated fadeInDown', exit:'' } }; // no animate on exit: animated fadeOutUp
moqui.notifyOptsError = { delay:5000, offset:{x:20,y:60}, placement:{from:'top',align:'right'}, z_index:1100, type:'danger',
    animate:{ enter:'animated fadeInDown', exit:'' } }; // no animate on exit: animated fadeOutUp
moqui.notifyMessages = function(messages, errors) {
    var notified = false;
    if (messages) {
        if (moqui.isArray(messages)) {
            for (var mi=0; mi < messages.length; mi++) {
                $.notify({message:messages[mi]}, moqui.notifyOptsInfo); moqui.webrootVue.addNotify(messages[mi], 'info'); notified = true; }
        } else { $.notify({message:messages}, moqui.notifyOptsInfo); moqui.webrootVue.addNotify(messages, 'info'); notified = true; }
    }
    if (errors) {
        if (moqui.isArray(errors)) {
            for (var ei=0; ei < errors.length; ei++) {
                $.notify({message:errors[ei]}, moqui.notifyOptsError); moqui.webrootVue.addNotify(errors[ei], 'danger'); notified = true; }
        } else { $.notify({message:errors}, moqui.notifyOptsError); moqui.webrootVue.addNotify(errors, 'danger'); notified = true; }
    }
    return notified;
};
moqui.handleAjaxError = function(jqXHR, textStatus, errorThrown) {
    var resp = jqXHR.responseText;
    var respObj;
    try { respObj = JSON.parse(resp); } catch (e) { /* ignore error, don't always expect it to be JSON */ }
    console.warn('ajax ' + textStatus + ' (' + jqXHR.status + '), message ' + errorThrown /*+ '; response: ' + resp*/);
    // console.error('respObj: ' + JSON.stringify(respObj));
    var notified = false;
    if (respObj && moqui.isPlainObject(respObj)) { notified = moqui.notifyMessages(respObj.messages, respObj.errors); }
    else if (resp && moqui.isString(resp) && resp.length) { notified = moqui.notifyMessages(resp); }

    // reload on 401 (Unauthorized) so server can remember current URL and redirect to login screen
    if (jqXHR.status === 401) { if (moqui.webrootVue) { window.location.href = moqui.webrootVue.currentLinkUrl; } else { window.location.reload(true); }
    } else if (jqXHR.status === 0) { if (errorThrown.indexOf('abort') < 0) { var msg = 'Could not connect to server';
        $.notify({ message:msg }, moqui.notifyOptsError); moqui.webrootVue.addNotify(msg, 'danger'); }
    } else if (!notified) { var errMsg = 'Error: ' + errorThrown + ' (' + textStatus + ')';
        $.notify({ message:errMsg }, moqui.notifyOptsError); moqui.webrootVue.addNotify(errMsg, 'danger');
    }
};

/* ========== component loading methods ========== */
moqui.componentCache = new moqui.LruMap(50);

moqui.handleLoadError = function (jqXHR, textStatus, errorThrown) {
    moqui.webrootVue.loading = 0;
    moqui.handleAjaxError(jqXHR, textStatus, errorThrown);
};
// NOTE: this may eventually split to change the activeSubscreens only on currentPathList change (for screens that support it)
//     and if ever needed some sort of data refresh if currentParameters changes
moqui.loadComponent = function(urlInfo, callback, divId) {
    var path, extraPath, search, bodyParameters;
    if (typeof urlInfo === 'string') {
        var questIdx = urlInfo.indexOf('?');
        if (questIdx > 0) { path = urlInfo.slice(0, questIdx); search = urlInfo.slice(questIdx+1); }
        else { path = urlInfo; }
    } else {
        path = urlInfo.path; extraPath = urlInfo.extraPath; search = urlInfo.search; bodyParameters = urlInfo.bodyParameters;
    }

    // check cache
    // console.info('component lru ' + JSON.stringify(moqui.componentCache.lruList));
    var cachedComp = moqui.componentCache.get(path);
    if (cachedComp) {
        console.info('found cached component for path ' + path);
        callback(cachedComp); return;
    }

    // prep url
    var url = path; var isJsPath = (path.slice(-3) === '.js');
    if (!isJsPath) url += '.vuet';
    if (extraPath && extraPath.length > 0) url += ('/' + extraPath);
    if (search && search.length > 0) url += ('?' + search);

    console.info("loadComponent " + url + (divId ? " id " + divId : ''));
    var ajaxSettings = { type:"GET", url:url, error:moqui.handleLoadError, success: function(resp, status, jqXHR) {
        // console.info(resp);
        if (!resp) { callback(moqui.NotFound); }
        var isServerStatic = (jqXHR.getResponseHeader("Cache-Control").indexOf("max-age") >= 0);
        if (moqui.isString(resp) && resp.length > 0) {
            if (isJsPath || resp.slice(0,7) === 'define(') {
                console.info("loaded JS from " + url + (divId ? " id " + divId : ""));
                var jsCompObj = eval(resp);
                if (jsCompObj.template) {
                    if (isServerStatic) { moqui.componentCache.put(path, jsCompObj); }
                    callback(jsCompObj);
                } else {
                    var htmlUrl = (path.slice(-3) === '.js' ? path.slice(0, -3) : path) + '.vuet';
                    $.ajax({ type:"GET", url:htmlUrl, error:moqui.handleLoadError, success: function (htmlText) {
                        jsCompObj.template = htmlText;
                        if (isServerStatic) { moqui.componentCache.put(path, jsCompObj); }
                        callback(jsCompObj);
                    }});
                }
            } else {
                var templateText = resp.replace(/<script/g, '<m-script').replace(/<\/script>/g, '</m-script>').replace(/<link/g, '<m-stylesheet');
                console.info("loaded HTML template from " + url + (divId ? " id " + divId : "") /*+ ": " + templateText*/);
                // using this fixes encoded values in attributes and such that Vue does not decode (but is decoded in plain HTML),
                //     but causes many other problems as all needed encoding is lost too: moqui.decodeHtml(templateText)
                var compObj = { template: '<div' + (divId && divId.length > 0 ? ' id="' + divId + '"' : '') + '>' + templateText + '</div>' };
                if (isServerStatic) { moqui.componentCache.put(path, compObj); }
                callback(compObj);
            }
        } else if (moqui.isPlainObject(resp)) {
            if (resp.screenUrl && resp.screenUrl.length > 0) { this.$root.setUrl(resp.screenUrl); }
            else if (resp.redirectUrl && resp.redirectUrl.length > 0) { window.location.replace(resp.redirectUrl); }
        } else { callback(moqui.NotFound); }
    }};
    if (bodyParameters && !$.isEmptyObject(bodyParameters)) { ajaxSettings.type = "POST"; ajaxSettings.data = bodyParameters; }
    $.ajax(ajaxSettings);
};

/* ========== placeholder components ========== */
moqui.NotFound = Vue.extend({ template: '<div id="current-page-root"><h4>Screen not found at {{this.$root.currentPath}}</h4></div>' });
moqui.EmptyComponent = Vue.extend({ template: '<div id="current-page-root"><div class="spinner"><div>Loading…</div></div></div>' });

/* ========== inline components ========== */
Vue.component('m-link', {
    props: { href:{type:String,required:true}, loadId:String },
    template: '<a :href="linkHref" @click.prevent="go"><slot></slot></a>',
    methods: { go: function(event) {
        if (event.button !== 0) { return; }
        if (this.loadId && this.loadId.length > 0) { this.$root.loadContainer(this.loadId, this.href); }
        else { if (event.ctrlKey || event.metaKey) { window.open(this.linkHref, "_blank"); } else { this.$root.setUrl(this.linkHref); } }
    }},
    computed: { linkHref: function () { return this.href.indexOf(this.$root.basePath) === 0 ? this.href.replace(this.$root.basePath, this.$root.linkBasePath) : this.href; } }
});
Vue.component('m-script', {
    props: { src:String, type:{type:String,'default':'text/javascript'} },
    template: '<div :type="type" style="display:none;"><slot></slot></div>',
    created: function() { if (this.src && this.src.length > 0) { moqui.loadScript(this.src); } },
    mounted: function() {
        var innerText = this.$el.innerText;
        if (innerText && innerText.trim().length > 0) {
            // console.info('running: ' + innerText);
            moqui.retryInlineScript(innerText, 1);
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
    created: function() { moqui.loadStylesheet(this.href, this.rel, this.type); }
});
/* ========== layout components ========== */
Vue.component('container-box', {
    props: { type:{type:String,'default':'default'}, title:String, initialOpen:{type:Boolean,'default':true} },
    data: function() { return { isBodyOpen:this.initialOpen }},
    template:
    '<div :class="\'panel panel-\' + type"><div class="panel-heading" @click.self="toggleBody">' +
            '<h5 v-if="title && title.length" @click="toggleBody">{{title}}</h5><slot name="header"></slot>' +
            '<div class="panel-toolbar"><slot name="toolbar"></slot></div></div>' +
        '<div class="panel-collapse collapse" :class="{in:isBodyOpen}"><slot></slot></div>' +
    '</div>',
    methods: { toggleBody: function() { this.isBodyOpen = !this.isBodyOpen; } }
});
Vue.component('box-body', { template: '<div class="panel-body"><slot></slot></div>' });
Vue.component('container-dialog', {
    props: { id:{type:String,required:true}, title:String, width:{type:String,'default':'760'}, openDialog:{type:Boolean,'default':false} },
    data: function() { return { isHidden:true, dialogStyle:{width:this.width + 'px'}}},
    template:
    '<div :id="id" class="modal dynamic-dialog" aria-hidden="true" style="display:none;" tabindex="-1">' +
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
            jqEl.find(":not(.noResetSelect2)>select:not(.noResetSelect2)").select2({ });
            var defFocus = jqEl.find(".default-focus");
            if (defFocus.length) { defFocus.focus(); } else { jqEl.find('form :input:visible:first').focus(); }
        });
        if (this.openDialog) { jqEl.modal('show'); }
    }
});
Vue.component('dynamic-container', {
    props: { id:{type:String,required:true}, url:{type:String} },
    data: function() { return { curComponent:moqui.EmptyComponent, curUrl:"" } },
    template: '<component :is="curComponent"></component>',
    methods: { reload: function() { var saveUrl = this.curUrl; this.curUrl = ""; var vm = this; setTimeout(function() { vm.curUrl = saveUrl; }, 20); },
        load: function(url) { if (this.curUrl === url) { this.reload(); } else { this.curUrl = url; } }},
    watch: { curUrl: function(newUrl) {
        if (!newUrl || newUrl.length === 0) { this.curComponent = moqui.EmptyComponent; return; }
        var vm = this; moqui.loadComponent(newUrl, function(comp) { vm.curComponent = comp; }, this.id);
    }},
    mounted: function() { this.$root.addContainer(this.id, this); this.curUrl = this.url; }
});
Vue.component('dynamic-dialog', {
    props: { id:{type:String,required:true}, url:{type:String,required:true}, title:String, width:{type:String,'default':'760'},
        openDialog:{type:Boolean,'default':false} },
    data: function() { return { curComponent:moqui.EmptyComponent, curUrl:"", isHidden:true, dialogStyle:{width:this.width + 'px'}}},
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
    watch: { curUrl: function (newUrl) {
        if (!newUrl || newUrl.length === 0) { this.curComponent = moqui.EmptyComponent; return; }
        var vm = this;
        moqui.loadComponent(newUrl, function(comp) {
            comp.mounted = function() {
                var jqEl = $(vm.$el);
                jqEl.find(":not(.noResetSelect2)>select:not(.noResetSelect2)").select2({ });
                var defFocus = jqEl.find(".default-focus");
                // console.log(defFocus);
                if (defFocus.length) { defFocus.focus(); } else { jqEl.find('form :input:visible:first').focus(); }
            };
            vm.curComponent = comp;
        }, this.id);
    }},
    mounted: function() {
        this.$root.addContainer(this.id, this); var jqEl = $(this.$el); var vm = this;
        jqEl.on("show.bs.modal", function() { vm.curUrl = vm.url; });
        jqEl.on("hidden.bs.modal", function() { vm.isHidden = true; vm.curUrl = ""; });
        jqEl.on("shown.bs.modal", function() { vm.isHidden = false; });
        if (this.openDialog) { jqEl.modal('show'); }
    }
});
Vue.component('tree-top', {
    template: '<ul :id="id" class="tree-list"><tree-item v-for="model in itemList" :key="model.id" :model="model" :top="top"/></ul>',
    props: { id:{type:String,required:true}, items:{type:[String,Array],required:true}, openPath:String, parameters:Object },
    data: function() { return { urlItems:null, currentPath:null, top:this }},
    computed: {
        itemList: function() { if (this.urlItems) { return this.urlItems; } return moqui.isArray(this.items) ? this.items : []; }
    },
    methods: { },
    mounted: function() { if (moqui.isString(this.items)) {
        this.currentPath = this.openPath;
        var allParms = $.extend({ moquiSessionToken:this.$root.moquiSessionToken, treeNodeId:'#', treeOpenPath:this.openPath }, this.parameters);
        var vm = this; $.ajax({ type:'POST', dataType:'json', url:this.items, headers:{Accept:'application/json'}, data:allParms,
            error:moqui.handleAjaxError, success:function(resp) { vm.urlItems = resp; /*console.info('tree-top response ' + JSON.stringify(resp));*/ } });
    }}
});
Vue.component('tree-item', {
    template:
    '<li :id="model.id">' +
        '<i v-if="isFolder" @click="toggle" class="glyphicon" :class="{\'glyphicon-chevron-right\':!open, \'glyphicon-chevron-down\':open}"></i>' +
        '<span v-else style="width:1em;display:inline-block;"></span>' +
        ' <span @click="setSelected">' +
            '<m-link v-if="model.a_attr" :href="model.a_attr.urlText" :load-id="model.a_attr.loadId" :class="{\'text-success\':selected}">{{model.text}}</m-link>' +
            '<span v-if="!model.a_attr" :class="{\'text-success\':selected}">{{model.text}}</span>' +
        '</span>' +
        '<ul v-show="open" v-if="hasChildren"><tree-item v-for="model in model.children" :key="model.id" :model="model" :top="top"/></ul></li>',
    props: { model:Object, top:Object },
    data: function() { return { open:false }},
    computed: {
        isFolder: function() { var children = this.model.children; if (!children) { return false; }
            if (moqui.isArray(children)) { return children.length > 0 } return true; },
        hasChildren: function() { var children = this.model.children; return moqui.isArray(children) && children.length > 0; },
        selected: function() { return this.top.currentPath === this.model.id; }
    },
    watch: { open: function(newVal) { if (newVal) {
        var children = this.model.children;
        var url = this.top.items;
        if (this.open && children && moqui.isBoolean(children) && moqui.isString(url)) {
            var li_attr = this.model.li_attr;
            var allParms = $.extend({ moquiSessionToken:this.$root.moquiSessionToken, treeNodeId:this.model.id,
                treeNodeName:(li_attr && li_attr.treeNodeName ? li_attr.treeNodeName : ''), treeOpenPath:this.top.currentPath }, this.top.parameters);
            var vm = this; $.ajax({ type:'POST', dataType:'json', url:url, headers:{Accept:'application/json'}, data:allParms,
                error:moqui.handleAjaxError, success:function(resp) { vm.model.children = resp; } });
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
    data: function() { return { fields:{}, fieldsChanged:{} }},
    template: '<form @submit.prevent="submitForm"><slot></slot></form>',
    methods: {
        submitForm: function submitForm() {
            var jqEl = $(this.$el);
            if (this.noValidate || jqEl.valid()) {
                // get button pressed value and disable ASAP to avoid double submit
                var btnName = null, btnValue = null;
                var $btn = $(document.activeElement);
                if ($btn.length && jqEl.has($btn) && $btn.is('button[type="submit"], input[type="submit"], input[type="image"]')) {
                    if ($btn.is('[name]')) { btnName = $btn.attr('name'); btnValue = $btn.val(); }
                    $btn.prop('disabled', true);
                    setTimeout(function() { $btn.prop('disabled', false); }, 3000);
                }
                var formData = new FormData(this.$el);
                formData.append('moquiSessionToken', this.$root.moquiSessionToken);
                $.each(this.fields, function (key, value) { formData.append(key, value); });
                if (btnName) { formData.append(btnName, btnValue); }

                // console.info('m-form parameters ' + JSON.stringify(formData));
                // for (var key of formData.keys()) { console.log('m-form key ' + key + ' val ' + JSON.stringify(formData.get(key))); }
                this.$root.loading++;
                $.ajax({ type:this.method, url:this.action, data:formData, contentType:false, processData:false,
                    headers:{Accept:'application/json'}, error:moqui.handleLoadError, success:this.handleResponse });
            } else if (!this.noValidate) {
                // For convenience, attempt to focus the first invalid element.
                // Begin by finding the first invalid input
                var invEle = jqEl.find('div.has-error input, div.has-error select, div.has-error textarea').first();
                if (invEle.length) {
                    // If the element is inside a collapsed panel, attempt to open it.
                    // Find parent (if it exists) with class .panel-collapse.collapse (works for accordion and regular panels)
                    var nearestPanel = invEle.parents('div.panel-collapse.collapse').last();
                    if (nearestPanel.length) {
                        // Only bother if the panel is not currently open
                        if (!nearestPanel.hasClass('in')) {
                            // From there find sibling with class panel-heading
                            var panelHeader = nearestPanel.prevAll('div.panel-heading').last();
                            if (panelHeader.length) {
                                // Here is where accordion and regular panels diverge.
                                var panelLink = panelHeader.find('a[data-toggle="collapse"]').first();
                                if (panelLink.length) panelLink.click();
                                else panelHeader.click();
                                setTimeout(function() { invEle.focus(); }, 250);
                            } else invEle.focus();
                        } else invEle.focus();
                    } else invEle.focus();
                }
            }
        },
        handleResponse: function(resp) {
            this.$root.loading--;
            var notified = false;
            // console.info('m-form response ' + JSON.stringify(resp));
            if (resp && moqui.isPlainObject(resp)) {
                notified = moqui.notifyMessages(resp.messages, resp.errors);
                if (resp.screenUrl && resp.screenUrl.length > 0) { this.$root.setUrl(resp.screenUrl); }
                else if (resp.redirectUrl && resp.redirectUrl.length > 0) { window.location.href = resp.redirectUrl; }
            } else { console.warn('m-form no response or non-JSON response: ' + JSON.stringify(resp)) }
            var hideId = this.submitHideId; if (hideId && hideId.length > 0) { $('#' + hideId).modal('hide'); }
            var reloadId = this.submitReloadId; if (reloadId && reloadId.length > 0) { this.$root.reloadContainer(reloadId); }
            var subMsg = this.submitMessage;
            if (subMsg && subMsg.length) {
                var responseText = resp; // this is set for backward compatibility in case message relies on responseText as in old JS
                var message = eval('"' + subMsg + '"');
                $.notify({ message:message }, moqui.notifyOpts);
                moqui.webrootVue.addNotify(message, 'success');
            } else if (!notified) {
                $.notify({ message:"Form data saved" }, moqui.notifyOpts);
            }
        },
        fieldChange: function (evt) {
            var targetDom = evt.delegateTarget; var targetEl = $(targetDom);
            if (targetEl.hasClass("input-group") && targetEl.children("input").length) {
                // special case for date-time using bootstrap-datetimepicker
                targetEl = targetEl.children("input").first();
                targetDom = targetEl.get(0);
            }
            var changed = false;
            if (targetDom.nodeName === "INPUT" || targetDom.nodeName === "TEXTAREA") {
                if (targetEl.attr("type") === "radio" || targetEl.attr("type") === "checkbox") {
                    changed = targetDom.checked !== targetDom.defaultChecked; }
                else { changed = targetDom.value !== targetDom.defaultValue; }
            } else if (targetDom.nodeName === "SELECT") {
                // TODO: doesn't seem to work with select2, always shows changed; defaultSelected may not work as set by JS
                if (targetDom.multiple) {
                    var optLen = targetDom.options.length;
                    for (var i = 0; i < optLen; i++) {
                        var opt = targetDom.options[i];
                        if (opt.selected !== opt.defaultSelected) { changed = true; break; }
                    }
                } else {
                    changed = !targetDom.options[targetDom.selectedIndex].defaultSelected;
                }
            }
            // console.log("changed? " + changed + " node " + targetDom.nodeName + " type " + targetEl.attr("type") + " " + targetEl.attr("name") + " to " + targetDom.value + " default " + targetDom.defaultValue);
            // console.log(targetDom.defaultValue);
            if (changed) {
                this.fieldsChanged[targetEl.attr("name")] = true;
                targetEl.parents(".form-group").children("label").addClass("is-changed");
                targetEl.parents(".form-group").find(".select2-selection").addClass("is-changed");
                targetEl.addClass("is-changed");
            } else {
                this.fieldsChanged[targetEl.attr("name")] = false;
                targetEl.parents(".form-group").children("label").removeClass("is-changed");
                targetEl.parents(".form-group").find(".select2-selection").removeClass("is-changed");
                targetEl.removeClass("is-changed");
            }
        }
    },
    mounted: function() {
        var jqEl = $(this.$el);
        if (!this.noValidate) jqEl.validate({ errorClass: 'help-block', errorElement: 'span',
            highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
            unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
        });
        jqEl.find('[data-toggle="tooltip"]').tooltip({placement:'auto top'});
        if (this.focusField && this.focusField.length > 0) jqEl.find('[name^="' + this.focusField + '"]').addClass('default-focus').focus();
        // watch changed fields
        jqEl.find(':input').on('change', this.fieldChange);
        // special case for date-time using bootstrap-datetimepicker
        jqEl.find('div.input-group.date').on('change', this.fieldChange);
    }
});
Vue.component('form-link', {
    props: { action:{type:String,required:true}, focusField:String, noValidate:Boolean, bodyParameterNames:Array },
    data: function() { return { fields:{} }},
    template: '<form @submit.prevent="submitForm"><slot :clearForm="clearForm"></slot></form>',
    methods: {
        submitForm: function() {
            var jqEl = $(this.$el);
            if (this.noValidate || jqEl.valid()) {
                // get button pressed value and disable ASAP to avoid double submit
                var btnName = null, btnValue = null;
                var $btn = $(document.activeElement);
                if ($btn.length && jqEl.has($btn) && $btn.is('button[type="submit"], input[type="submit"], input[type="image"]')) {
                    if ($btn.is('[name]')) { btnName = $btn.attr('name'); btnValue = $btn.val(); }
                    $btn.prop('disabled', true);
                    setTimeout(function() { $btn.prop('disabled', false); }, 3000);
                }
                var parmList = jqEl.serializeArray();
                $.each(this.fields, function (key, value) { parmList.push({name:key, value:value}); });
                var extraList = [];
                var plainKeyList = [];
                var parmStr = "";
                var bodyParameters = null;
                for (var pi=0; pi<parmList.length; pi++) {
                    var parm = parmList[pi]; var key = parm.name; var value = parm.value;
                    if (value.trim().length === 0 || key === "moquiSessionToken" || key === "moquiFormName" || key.indexOf('%5B%5D') > 0) continue;
                    if (key.indexOf("_op") > 0 || key.indexOf("_not") > 0 || key.indexOf("_ic") > 0) {
                        extraList.push(parm);
                    } else {
                        plainKeyList.push(key);
                        if (this.bodyParameterNames && this.bodyParameterNames.indexOf(key) >= 0) {
                            if (!bodyParameters) bodyParameters = {};
                            bodyParameters[key] = value;
                        } else {
                            if (parmStr.length > 0) { parmStr += '&'; }
                            parmStr += (encodeURIComponent(key) + '=' + encodeURIComponent(value));
                        }
                    }
                }
                for (var ei=0; ei<extraList.length; ei++) {
                    var eparm = extraList[ei]; var keyName = eparm.name.substring(0, eparm.name.indexOf('_'));
                    if (plainKeyList.indexOf(keyName) >= 0) {
                        if (parmStr.length > 0) { parmStr += '&'; }
                        parmStr += (encodeURIComponent(eparm.name) + '=' + encodeURIComponent(eparm.value));
                    }
                }
                if (btnName && btnValue && btnValue.trim().length) {
                    if (parmStr.length > 0) { parmStr += '&'; }
                    parmStr += (encodeURIComponent(btnName) + '=' + encodeURIComponent(btnValue));
                }
                var url = this.action;
                if (url.indexOf('?') > 0) { url = url + '&' + parmStr; } else { url = url + '?' + parmStr; }
                // console.log("form-link url " + url + " bodyParameters " + JSON.stringify(bodyParameters));
                this.$root.setUrl(url, bodyParameters);
            }
        },
        clearForm: function() {
            var jqEl = $(this.$el);
            jqEl.find(':radio, :checkbox').removeAttr('checked');
            jqEl.find('textarea, :text, select').val('').trigger('change');
        }
    },
    mounted: function() {
        var jqEl = $(this.$el);
        if (!this.noValidate) jqEl.validate({ errorClass: 'help-block', errorElement: 'span',
            highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
            unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
        });
        jqEl.find('[data-toggle="tooltip"]').tooltip({placement:'auto top'});
        if (this.focusField && this.focusField.length > 0) jqEl.find('[name=' + this.focusField + ']').addClass('default-focus').focus();
    }
});

Vue.component('form-paginate', {
    props: { paginate:Object, formList:Object },
    template:
    '<ul v-if="paginate" class="pagination">' +
        '<template v-if="paginate.pageIndex > 0">' +
            '<li><a href="#" @click.prevent="setIndex(0)"><i class="glyphicon glyphicon-fast-backward"></i></a></li>' +
            '<li><a href="#" @click.prevent="setIndex(paginate.pageIndex-1)"><i class="glyphicon glyphicon-backward"></i></a></li></template>' +
        '<template v-else><li><span><i class="glyphicon glyphicon-fast-backward"></i></span></li><li><span><i class="glyphicon glyphicon-backward"></i></span></li></template>' +
        '<li v-for="prevIndex in prevArray"><a href="#" @click.prevent="setIndex(prevIndex)">{{prevIndex+1}}</a></li>' +
        '<li><span>Page {{paginate.pageIndex+1}} of {{paginate.pageMaxIndex+1}} ({{paginate.pageRangeLow}} - {{paginate.pageRangeHigh}} of {{paginate.count}})</span></li>' +
        '<li v-for="nextIndex in nextArray"><a href="#" @click.prevent="setIndex(nextIndex)">{{nextIndex+1}}</a></li>' +
        '<template v-if="paginate.pageIndex < paginate.pageMaxIndex">' +
            '<li><a href="#" @click.prevent="setIndex(paginate.pageIndex+1)"><i class="glyphicon glyphicon-forward"></i></a></li>' +
            '<li><a href="#" @click.prevent="setIndex(paginate.pageMaxIndex)"><i class="glyphicon glyphicon-fast-forward"></i></a></li></template>' +
        '<template v-else><li><span><i class="glyphicon glyphicon-forward"></i></span></li><li><span><i class="glyphicon glyphicon-fast-forward"></i></span></li></template>' +
    '</ul>',
    computed: {
        prevArray: function() {
            var pag = this.paginate; var arr = []; if (!pag || pag.pageIndex < 1) return arr;
            var pageIndex = pag.pageIndex; var indexMin = pageIndex - 3; if (indexMin < 0) { indexMin = 0; } var indexMax = pageIndex - 1;
            while (indexMin <= indexMax) { arr.push(indexMin++); } return arr;
        },
        nextArray: function() {
            var pag = this.paginate; var arr = []; if (!pag || pag.pageIndex >= pag.pageMaxIndex) return arr;
            var pageIndex = pag.pageIndex; var pageMaxIndex = pag.pageMaxIndex;
            var indexMin = pageIndex + 1; var indexMax = pageIndex + 3; if (indexMax > pageMaxIndex) { indexMax = pageMaxIndex; }
            while (indexMin <= indexMax) { arr.push(indexMin++); } return arr;
        }
    },
    methods: { setIndex: function(newIndex) {
        if (this.formList) { this.formList.setPageIndex(newIndex); } else { this.$root.setParameters({pageIndex:newIndex}); }
    }}
});
Vue.component('form-go-page', {
    props: { idVal:{type:String,required:true}, maxIndex:Number, formList:Object },
    template:
    '<form v-if="!formList || (formList.paginate && formList.paginate.pageMaxIndex > 4)" @submit.prevent="goPage" class="form-inline" :id="idVal+\'_GoPage\'">' +
        '<div class="form-group">' +
            '<label class="sr-only" :for="idVal+\'_GoPage_pageIndex\'">Page Number</label>' +
            '<input type="text" class="form-control" size="6" name="pageIndex" :id="idVal+\'_GoPage_pageIndex\'" placeholder="Page #">' +
        '</div><button type="submit" class="btn btn-default">Go</button>' +
    '</form>',
    methods: { goPage: function() {
        var formList = this.formList;
        var jqEl = $('#' + this.idVal + '_GoPage_pageIndex');
        var newIndex = jqEl.val() - 1;
        if (newIndex < 0 || (formList && newIndex > formList.paginate.pageMaxIndex) || (this.maxIndex && newIndex > this.maxIndex)) {
            jqEl.parents('.form-group').addClass('has-error');
        } else {
            jqEl.parents('.form-group').removeClass('has-error');
            if (formList) { formList.setPageIndex(newIndex); } else { this.$root.setParameters({pageIndex:newIndex}); }
            jqEl.val('');
        }
    }}
});
Vue.component('form-list', {
    // rows can be a full path to a REST service or transition, a plain form name on the current screen, or a JS Array with the actual rows
    props: { name:{type:String,required:true}, id:String, rows:{type:[String,Array],required:true}, search:{type:Object},
            action:String, multi:Boolean, skipForm:Boolean, skipHeader:Boolean, headerForm:Boolean, headerDialog:Boolean,
            savedFinds:Boolean, selectColumns:Boolean, allButton:Boolean, csvButton:Boolean, textButton:Boolean, pdfButton:Boolean,
            columns:[String,Number] },
    data: function() { return { rowList:[], paginate:null, searchObj:null, moqui:moqui } },
    // slots (props): headerForm (search), header (search), nav (), rowForm (fields), row (fields)
    // TODO: QuickSavedFind drop-down
    // TODO: change find options form to update searchObj and run fetchRows instead of changing main page and reloading
    // TODO: update window url on paginate and other searchObj update?
    // TODO: review for actual static (no server side rendering, cachable)
    template:
    '<div>' +
        '<template v-if="!multi && !skipForm">' +
            '<m-form v-for="(fields, rowIndex) in rowList" :name="idVal+\'_\'+rowIndex" :id="idVal+\'_\'+rowIndex" :action="action">' +
                '<slot name="rowForm" :fields="fields"></slot></m-form></template>' +
        '<m-form v-if="multi && !skipForm" :name="idVal" :id="idVal" :action="action">' +
            '<input type="hidden" name="moquiFormName" :value="name"><input type="hidden" name="_isMulti" value="true">' +
            '<template v-for="(fields, rowIndex) in rowList"><slot name="rowForm" :fields="fields"></slot></template></m-form>' +
        '<form-link v-if="!skipHeader && headerForm && !headerDialog" :name="idVal+\'_header\'" :id="idVal+\'_header\'" :action="$root.currentLinkPath">' +
            '<input v-if="searchObj && searchObj.orderByField" type="hidden" name="orderByField" :value="searchObj.orderByField">' +
            '<slot name="headerForm"  :search="searchObj"></slot></form-link>' +
        '<table class="table table-striped table-hover table-condensed" :id="idVal+\'_table\'"><thead>' +
            '<tr class="form-list-nav-row"><th :colspan="columns?columns:\'100\'"><nav class="form-list-nav">' +
                '<button v-if="savedFinds || headerDialog" :id="idVal+\'_hdialog_button\'" type="button" data-toggle="modal" :data-target="\'#\'+idVal+\'_hdialog\'" data-original-title="Find Options" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> Find Options</button>' +
                '<button v-if="selectColumns" :id="idVal+\'_SelColsDialog_button\'" type="button" data-toggle="modal" :data-target="\'#\'+idVal+\'_SelColsDialog\'" data-original-title="Columns" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> Columns</button>' +
                '<form-paginate :paginate="paginate" :form-list="this"></form-paginate>' +
                '<form-go-page :id-val="idVal" :form-list="this"></form-go-page>' +
                '<a v-if="csvButton" :href="csvUrl" class="btn btn-default">CSV</a>' +
                '<button v-if="textButton" :id="idVal+\'_TextDialog_button\'" type="button" data-toggle="modal" :data-target="\'#\'+idVal+\'_TextDialog\'" data-original-title="Text" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> Text</button>' +
                '<button v-if="pdfButton" :id="idVal+\'_PdfDialog_button\'" type="button" data-toggle="modal" :data-target="\'#\'+idVal+\'_PdfDialog\'" data-original-title="PDF" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> PDF</button>' +
                '<slot name="nav"></slot>' +
            '</nav></th></tr>' +
            '<slot name="header" :search="searchObj"></slot>' +
        '</thead><tbody><tr v-for="(fields, rowIndex) in rowList"><slot name="row" :fields="fields" :row-index="rowIndex" :moqui="moqui"></slot></tr>' +
        '</tbody></table>' +
    '</div>',
    computed: {
        idVal: function() { if (this.id && this.id.length > 0) { return this.id; } else { return this.name; } },
        csvUrl: function() { return this.$root.currentPath + '?' + moqui.objToSearch($.extend({}, this.searchObj,
                { renderMode:'csv', pageNoLimit:'true', lastStandalone:'true', saveFilename:(this.name + '.csv') })); }
    },
    methods: {
        fetchRows: function() {
            if (moqui.isArray(this.rows)) { console.warn('Tried to fetch form-list-body rows but rows prop is an array'); return; }
            var vm = this;
            var searchObj = this.search; if (!searchObj) { searchObj = this.$root.currentParameters; }
            var url = this.rows; if (url.indexOf('/') === -1) { url = this.$root.currentPath + '/actions/' + url; }
            console.info("Fetching rows with url " + url + " searchObj " + JSON.stringify(searchObj));
            $.ajax({ type:"GET", url:url, data:searchObj, dataType:"json", headers:{Accept:'application/json'},
                     error:moqui.handleAjaxError, success: function(list, status, jqXHR) {
                if (list && moqui.isArray(list)) {
                    var getHeader = jqXHR.getResponseHeader;
                    var count = Number(getHeader("X-Total-Count"));
                    if (count && !isNaN(count)) {
                        vm.paginate = { count:Number(count), pageIndex:Number(getHeader("X-Page-Index")),
                            pageSize:Number(getHeader("X-Page-Size")), pageMaxIndex:Number(getHeader("X-Page-Max-Index")),
                            pageRangeLow:Number(getHeader("X-Page-Range-Low")), pageRangeHigh:Number(getHeader("X-Page-Range-High")) };
                    }
                    vm.rowList = list;
                    console.info("Fetched " + list.length + " rows, paginate: " + JSON.stringify(vm.paginate));
                }
            }});
        },
        setPageIndex: function(newIndex) {
            if (!this.searchObj) { this.searchObj = { pageIndex:newIndex }} else { this.searchObj.pageIndex = newIndex; }
            this.fetchRows();
        }
    },
    watch: {
        rows: function(newRows) { if (moqui.isArray(newRows)) { this.rowList = newRows; } else { this.fetchRows(); } },
        search: function () { this.fetchRows(); }
    },
    mounted: function() {
        if (this.search) { this.searchObj = this.search; } else { this.searchObj = this.$root.currentParameters; }
        if (moqui.isArray(this.rows)) { this.rowList = this.rows; } else { this.fetchRows(); }
    }
});

/* ========== form field widget components ========== */
Vue.component('date-time', {
    props: { id:String, name:{type:String,required:true}, value:String, type:{type:String,'default':'date-time'},
        size:String, format:String, tooltip:String, form:String, required:String, autoYear:String },
    template:
    '<input v-if="type==\'time\'" type="text" class="form-control" :pattern="timePattern" :name="name" :value="value" :size="sizeVal" :data-toggle="{tooltip:(tooltip&&tooltip.length>0)}" :title="tooltip" :form="form">' +
    '<div v-else class="input-group date" :id="id">' +
        '<input ref="dateInput" @focus="focusDate" @blur="blurDate" type="text" class="form-control" :name="name" :value="value" :size="sizeVal" :data-toggle="{tooltip:(tooltip&&tooltip.length>0)}" :title="tooltip" :form="form" :required="required == \'required\' ? true : false">' +
        '<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>' +
    '</div>',
    methods: {
        focusDate: function() {
            if (this.type === 'time' || this.autoYear === 'false') return;
            var inputEl = $(this.$refs.dateInput); var curVal = inputEl.val();
            if (!curVal || !curVal.length) inputEl.val(new Date().getFullYear());
        },
        blurDate: function() {
            if (this.type === 'time') return;
            var inputEl = $(this.$refs.dateInput); var curVal = inputEl.val();
            // console.log("date/time unfocus val " + curVal);
            // if contains 'd ' (month/day missing, or month specified but date missing or partial) clear input
            // Sufficient to check for just 'd', since the mask handles any scenario where there would only be a single 'd'
            if (curVal.indexOf('d') > 0) { inputEl.val(''); inputEl.trigger("change"); return; }
            // default time to noon, or minutes to 00
            if (curVal.indexOf('hh:mm') > 0) { inputEl.val(curVal.replace('hh:mm', '12:00')); inputEl.trigger("change"); return; }
            if (curVal.indexOf(':mm') > 0) { inputEl.val(curVal.replace(':mm', ':00')); inputEl.trigger("change"); return; }
        }
    },
    computed: {
        formatVal: function() { var format = this.format; if (format && format.length > 0) { return format; }
            return this.type === 'time' ? 'HH:mm' : (this.type === 'date' ? 'YYYY-MM-DD' : 'YYYY-MM-DD HH:mm'); },
        extraFormatsVal: function() { return this.type === 'time' ? ['LT', 'LTS', 'HH:mm'] :
            (this.type === 'date' ? ['l', 'L', 'YYYY-MM-DD'] : ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss', 'MM/DD/YYYY HH:mm']); },
        sizeVal: function() { var size = this.size; if (size && size.length > 0) { return size; }
            return this.type === 'time' ? '9' : (this.type === 'date' ? '10' : '16'); },
        timePattern: function() { return '^(?:(?:([01]?\\d|2[0-3]):)?([0-5]?\\d):)?([0-5]?\\d)$'; }
    },
    mounted: function() {
        var value = this.value;
        var format = this.formatVal;
        var jqEl = $(this.$el);
        if (this.type !== "time") {
            jqEl.datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, useStrict:true,
                defaultDate:(value && value.length ? moment(value,this.formatVal) : null), format:format,
                extraFormats:this.extraFormatsVal, stepping:5, locale:this.$root.locale});
            jqEl.on("dp.change", function() { jqEl.val(jqEl.find("input").first().val()); jqEl.trigger("change"); })
        }
        if (format === "YYYY-MM-DD") { jqEl.find('input').inputmask("yyyy-mm-dd", { clearIncomplete:false, clearMaskOnLostFocus:true, showMaskOnFocus:true, showMaskOnHover:false, removeMaskOnSubmit:false }); }
        if (format === "YYYY-MM-DD HH:mm") { jqEl.find('input').inputmask("yyyy-mm-dd hh:mm", { clearIncomplete:false, clearMaskOnLostFocus:true, showMaskOnFocus:true, showMaskOnHover:false, removeMaskOnSubmit:false }); }
    }
});
moqui.dateOffsets = [{id:'0',text:'This'},{id:'-1',text:'Last'},{id:'1',text:'Next'},
    {id:'-2',text:'-2'},{id:'2',text:'+2'},{id:'-3',text:'-3'},{id:'3',text:'+3'}];
moqui.datePeriods = [{id:'day',text:'Day'},{id:'7d',text:'7 Days'},{id:'30d',text:'30 Days'},{id:'week',text:'Week'},
    {id:'month',text:'Month'},{id:'quarter',text:'Quarter'},{id:'year',text:'Year'},{id:'7r',text:'+/-7d'},{id:'30r',text:'+/-30d'}];
moqui.emptyOpt = {id:'',text:'\u00a0'};
Vue.component('date-period', {
    props: { name:{type:String,required:true}, id:String, allowEmpty:Boolean, offset:String, period:String, date:String, form:String },
    template: '<div class="date-period" :id="id"><select ref="poffset" :name="name+\'_poffset\'" :form="form"></select> ' +
        '<select ref="period" :name="name+\'_period\'" :form="form"></select> ' +
        '<date-time :name="name+\'_pdate\'" :id="id+\'_pdate\'" :form="form" type="date" :value="date"/></div>',
    mounted: function() {
        var pofsEl = $(this.$refs.poffset); var perEl = $(this.$refs.period);
        var offsets = moqui.dateOffsets.slice(); var periods = moqui.datePeriods.slice();
        if (this.allowEmpty) { offsets.unshift(moqui.emptyOpt); periods.unshift(moqui.emptyOpt); }
        pofsEl.select2({ data:offsets }); perEl.select2({ data:periods });
        var offset = this.offset; if (offset && offset.length) { pofsEl.val(offset).trigger('change'); }
        var period = this.period; if (period && period.length) { perEl.val(period).trigger('change'); }
    }
});
Vue.component('drop-down', {
    props: { options:Array, value:[Array,String], combo:Boolean, allowEmpty:Boolean, multiple:String, optionsUrl:String,
        serverSearch:{type:Boolean,'default':false}, serverDelay:{type:Number,'default':300}, serverMinLength:{type:Number,'default':1},
        optionsParameters:Object, labelField:String, valueField:String, dependsOn:Object, dependsOptional:Boolean, form:String },
    data: function() { return { curData:null, s2Opts:null, lastVal:null } },
    template: '<select :form="form"><slot></slot></select>',
    methods: {
        processOptionList: function(list, page) {
            var newData = [];
            // funny case where select2 specifies no option.@value if empty so &nbsp; ends up passed with form submit; now filtered on server for \u00a0 only and set to null
            if (this.allowEmpty && (!page || page <= 1)) newData.push({ id:'\u00a0', text:'\u00a0' });
            var labelField = this.labelField; if (!labelField) { labelField = "label"; }
            var valueField = this.valueField; if (!valueField) { valueField = "value"; }
            $.each(list, function(idx, curObj) {
                var idVal = curObj[valueField]; if (!idVal) idVal = '\u00a0';
                newData.push({ id:idVal, text:curObj[labelField] })
            });
            return newData;
        },
        serverData: function(params) {
            var hasAllParms = true;
            var dependsOnMap = this.dependsOn; var parmMap = this.optionsParameters;
            var reqData = { moquiSessionToken: this.$root.moquiSessionToken };
            for (var parmName in parmMap) { if (parmMap.hasOwnProperty(parmName)) reqData[parmName] = parmMap[parmName]; }
            for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                var doValue = $('#' + dependsOnMap[doParm]).val();
                if (!doValue || doValue === "\u00a0") { hasAllParms = false; } else { reqData[doParm] = doValue; }
            }}
            if (params) { reqData.term = params.term || ''; reqData.pageIndex = (params.page || 1) - 1; }
            else if (this.serverSearch) { reqData.term = ''; reqData.pageIndex = 0; }
            reqData.hasAllParms = hasAllParms;
            return reqData;
        },
        processResponse: function(data, params) {
            if (moqui.isArray(data)) {
                return { results:this.processOptionList(data) };
            } else {
                params.page = params.page || 1; // NOTE: 1 based index, is 0 based on server side
                var pageSize = data.pageSize || 20;
                return { results: this.processOptionList(data.options, params.page),
                    pagination: { more: (data.count ? (params.page * pageSize) < data.count : false) } };
            }
        },
        populateFromUrl: function(params) {
            if (!this.optionsUrl || this.optionsUrl.length === 0) return;
            var reqData = this.serverData(params);
            if (!reqData.hasAllParms && !this.dependsOptional) { this.curData = null; return; }
            var vm = this;
            $.ajax({ type:"POST", url:this.optionsUrl, data:reqData, dataType:"json", headers:{Accept:'application/json'},
                error:moqui.handleAjaxError, success: function(data) {
                    var list = moqui.isArray(data) ? data : data.options;
                    if (list) { vm.curData = vm.processOptionList(list); }
                }});
        }
    },
    mounted: function() {
        var jqEl = $(this.$el);
        var vm = this; var opts = { minimumResultsForSearch:10 };
        if (this.combo) { opts.tags = true; opts.tokenSeparators = [',',' ']; }
        if (this.multiple === "multiple") {
            opts.multiple = true; opts.closeOnSelect = false; opts.width = "100%";
            jqEl.css("min-width", "240px"); // this gets ignored, not sure why select2 isn't passing it through
            jqEl.addClass("noResetSelect2"); // so doesn't get reset on container dialog load
        }
        if (this.options && this.options.length > 0) { opts.data = this.options; }
        if (this.serverSearch) {
            if (!this.optionsUrl) console.error("drop-down in form " + this.form + " has no options-url but has server-search=true");
            opts.ajax = { url:this.optionsUrl, type:"POST", dataType:"json", delay:this.serverDelay, cache:true,
                data:this.serverData, processResults:this.processResponse, error:moqui.handleAjaxError };
            opts.minimumInputLength = this.serverMinLength; opts.minimumResultsForSearch = 0;
            // handle width differently because with no options will go to min-width, for table cells/etc use reasonable min-width
            opts.width = "100%";
            jqEl.css("min-width", "200px");
            jqEl.addClass("noResetSelect2"); // so doesn't get reset on container dialog load
        }
        this.s2Opts = opts;
        jqEl.select2(opts);
        // needed? was a hack for something, but interferes with closeOnSelect:false for multiple: .on('select2:select', function () { jqEl.select2('open').select2('close'); });
        // needed? caused some issues: .on('change', function () { vm.$emit('input', vm.curVal); })
        var initValue = this.value;
        if (initValue && initValue.length) { this.curVal = initValue; }
        if (this.optionsUrl && this.optionsUrl.length > 0) {
            var dependsOnMap = this.dependsOn;
            for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                $('#' + dependsOnMap[doParm]).on('change', function() { vm.populateFromUrl({term:initValue}); }); }}
            // do initial populate if not a serverSearch or for serverSearch if we have an initial value do the search so we don't display the ID
            if (!this.serverSearch) { this.populateFromUrl(); }
            else if (initValue && initValue.length && moqui.isString(initValue)) { this.populateFromUrl({term:initValue}); }
        }
    },
    computed: { curVal: { get: function() { return $(this.$el).select2().val(); },
        set: function(value) { $(this.$el).val(value).trigger('change'); /* console.log('set ' + $(this.$el).attr('name') + ' to ' + this.curVal); */ } } },
    watch: {
        value: function(value) { this.curVal = value; },
        options: function(options) { this.curData = options; },
        curData: function(options) {
            var jqEl = $(this.$el); var vm = this;
            // save the lastVal if there is one to remember what was selected even if new options don't have it, just in case options change again
            var saveVal = jqEl.select2().val(); if (saveVal && saveVal.length > 1) this.lastVal = saveVal;
            jqEl.select2('destroy'); jqEl.empty();
            this.s2Opts.data = options; jqEl.select2(this.s2Opts);
            setTimeout(function() {
                var setVal = vm.lastVal; if (!setVal || setVal.length < 2) { setVal = vm.value; }
                if (setVal) {
                    var isInList = false;
                    var setValIsArray = moqui.isArray(setVal);
                    $.each(options, function(idx, curObj) {
                        if (setValIsArray ? $.inArray(curObj.id, setVal) : curObj.id === setVal) isInList = true; });
                    if (isInList) jqEl.val(setVal);
                }
                jqEl.trigger('change');
            }, 50);
        }
    },
    destroyed: function() { $(this.$el).off().select2('destroy'); }
});
Vue.component('text-autocomplete', {
    props: { id:{type:String,required:true}, name:{type:String,required:true}, value:String, valueText:String,
        type:String, size:String, maxlength:String, disabled:Boolean, validationClasses:String, dataVvValidation:String,
        required:Boolean, pattern:String, tooltip:String, form:String, delay:{type:Number,'default':300},
        url:{type:String,required:true}, dependsOn:Object, acParameters:Object, minLength:{type:Number,'default':1},
        showValue:Boolean, useActual:Boolean, skipInitial:Boolean },
    data: function () { return { delayTimeout:null } },
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
    methods: { fetchResults: function(query, syncResults, asyncResults) {
        if (this.delayTimeout) { clearTimeout(this.delayTimeout); }
        var vm = this;
        this.delayTimeout = setTimeout(function() {
            var dependsOnMap = vm.dependsOn; var parmMap = vm.acParameters;
            var reqData = { term: query, moquiSessionToken: vm.$root.moquiSessionToken };
            for (var parmName in parmMap) { if (parmMap.hasOwnProperty(parmName)) reqData[parmName] = parmMap[parmName]; }
            for (var doParm in dependsOnMap) { if (dependsOnMap.hasOwnProperty(doParm)) {
                var doValue = $('#' + dependsOnMap[doParm]).val(); if (doValue) reqData[doParm] = doValue; }}
            $.ajax({ url: vm.url, type:"POST", dataType:"json", data:reqData, error:moqui.handleAjaxError, success: function(data) {
                var list = moqui.isArray(data) ? data : data.options;
                asyncResults($.map(list, function(item) { return { label:item.label, value:item.value } })); }});
        }, this.delay);
    }},
    mounted: function() {
        var vm = this; var acJqEl = $(this.$refs.acinput); var hidJqEl = $(this.$refs.hidden);
        var showJqEl = this.$refs.show ? $(this.$refs.show) : null;
        acJqEl.typeahead({ minLength:this.minLength, highlight:true, hint:false },
            { limit:99, source: this.fetchResults, display: function(item) { return item.label; }
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
            $.ajax({ url:this.url, type:"POST", dataType:"json", data:reqData, error:moqui.handleAjaxError, success: function(data) {
                var list = moqui.isArray(data) ? data : data.options;
                var curValue = hidJqEl.val();
                for (var i = 0; i < list.length; i++) { if (list[i].value == curValue) {
                    acJqEl.val(list[i].label); if (showJqEl) { showJqEl.html(list[i].label); } break; }}
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
    data: function() { return { activeComponent:moqui.EmptyComponent, pathIndex:-1, pathName:null } },
    template: '<component :is="activeComponent"></component>',
    // method instead of a watch on pathName so that it runs even when newPath is the same for non-static reloading
    methods: { loadActive: function() {
        var vm = this; var root = vm.$root; var pathIndex = vm.pathIndex; var curPathList = root.currentPathList;
        var newPath = curPathList[pathIndex];
        var pathChanged = (this.pathName !== newPath);
        this.pathName = newPath;
        if (!newPath || newPath.length === 0) { this.activeComponent = moqui.EmptyComponent; return true; }
        var fullPath = root.basePath + '/' + curPathList.slice(0, pathIndex + 1).join('/');
        if (!pathChanged && moqui.componentCache.containsKey(fullPath)) { return false; } // no need to reload component
        var urlInfo = { path:fullPath };
        if (pathIndex === (curPathList.length - 1)) {
            var extra = root.extraPathList; if (extra && extra.length > 0) { urlInfo.extraPath = extra.join('/'); } }
        var search = root.currentSearch; if (search && search.length > 0) { urlInfo.search = search; }
        urlInfo.bodyParameters = root.bodyParameters;
        console.info('subscreens-active loadActive pathIndex ' + pathIndex + ' pathName ' + vm.pathName + ' urlInfo ' + JSON.stringify(urlInfo));
        root.loading++;
        moqui.loadComponent(urlInfo, function(comp) { vm.activeComponent = comp; root.loading--; });
        return true;
    }},
    mounted: function() { this.$root.addSubscreen(this); }
});
moqui.webrootVue = new Vue({
    el: '#apps-root',
    data: { basePath:"", linkBasePath:"", currentPathList:[], extraPathList:[], activeSubscreens:[], currentParameters:{}, bodyParameters:null,
        navMenuList:[], navHistoryList:[], navPlugins:[], notifyHistoryList:[], lastNavTime:Date.now(), loading:0, activeContainers:{},
        moquiSessionToken:"", appHost:"", appRootPath:"", userId:"", locale:"en", notificationClient:null },
    methods: {
        setUrl: function(url, bodyParameters) {
            // always set bodyParameters, setting to null when not specified to clear out previous
            this.bodyParameters = bodyParameters;
            // make sure any open modals are closed before setting current URL
            $('.modal.in').modal('hide');
            if (url.indexOf(this.basePath) === 0) url = url.replace(this.basePath, this.linkBasePath);
            // console.info('setting url ' + url + ', cur ' + this.currentLinkUrl);
            if (this.currentLinkUrl === url && url !== this.linkBasePath) {
                this.reloadSubscreens(); /* console.info('reloading, same url ' + url); */
            } else {
                var href = url;
                var ssIdx = href.indexOf('//');
                if (ssIdx >= 0) { var slIdx = href.indexOf('/', ssIdx + 1); if (slIdx === -1) { return; } href = href.slice(slIdx); }
                var splitHref = href.split("?");
                // clear out extra path, to be set from nav menu data if needed
                this.extraPathList = [];
                // set currentSearch before currentPath so that it is available when path updates
                if (splitHref.length > 1 && splitHref[1].length > 0) { this.currentSearch = splitHref[1]; } else { this.currentSearch = ""; }
                this.currentPath = splitHref[0];
                // with url cleaned up through setters now get current screen url for menu
                var srch = this.currentSearch;
                var screenUrl = this.currentPath + (srch.length > 0 ? '?' + srch : '');
                if (!screenUrl || screenUrl.length === 0) return;
                console.info("current URL changing to " + screenUrl);
                this.lastNavTime = Date.now();
                // TODO: somehow only clear out activeContainers that are in subscreens actually reloaded? may cause issues if any but last screen have dynamic-container
                this.activeContainers = {};
                // update menu, which triggers update of screen/subscreen components
                var vm = this;
                $.ajax({ type:"GET", url:"/menuData" + screenUrl, dataType:"text", error:moqui.handleAjaxError, success: function(outerListText) {
                    var outerList = null;
                    // console.log("menu response " + outerListText);
                    try { outerList = JSON.parse(outerListText); } catch (e) { console.info("Error parson menu list JSON: " + e); }
                    if (outerList && moqui.isArray(outerList)) { vm.navMenuList = outerList; /* console.info('navMenuList ' + JSON.stringify(outerList)); */ }
                }});

                // set the window URL
                window.history.pushState(null, this.ScreenTitle, url);
            }
        },
        setParameters: function(parmObj) {
            if (parmObj) { this.$root.currentParameters = $.extend({}, this.$root.currentParameters, parmObj); }
            this.$root.reloadSubscreens();
        },
        addSubscreen: function(saComp) {
            var pathIdx = this.activeSubscreens.length;
            // console.info('addSubscreen idx ' + pathIdx + ' pathName ' + this.currentPathList[pathIdx]);
            saComp.pathIndex = pathIdx;
            // setting pathName here handles initial load of subscreens-active; this may be undefined if we have more activeSubscreens than currentPathList items
            saComp.loadActive();
            this.activeSubscreens.push(saComp);
        },
        reloadSubscreens: function() {
            // console.info('reloadSubscreens currentParameters ' + JSON.stringify(this.currentParameters) + ' currentSearch ' + this.currentSearch);
            var fullPathList = this.currentPathList; var activeSubscreens = this.activeSubscreens;
            if (fullPathList.length === 0 && activeSubscreens.length > 0) { activeSubscreens.splice(1); activeSubscreens[0].loadActive(); return; }
            for (var i=0; i<activeSubscreens.length; i++) {
                if (i >= fullPathList.length) break;
                // always try loading the active subscreen and see if actually loaded
                var loaded = activeSubscreens[i].loadActive();
                // clear out remaining activeSubscreens, after first changed loads its placeholders will register and load
                if (loaded) activeSubscreens.splice(i+1);
            }
        },
        // all container components added with this must have reload() and load(url) methods
        addContainer: function(contId, comp) { this.activeContainers[contId] = comp; },
        reloadContainer: function(contId) { var contComp = this.activeContainers[contId];
            if (contComp) { contComp.reload(); } else { console.error("Container with ID " + contId + " not found, not reloading"); }},
        loadContainer: function(contId, url) { var contComp = this.activeContainers[contId];
            if (contComp) { contComp.load(url); } else { console.error("Container with ID " + contId + " not found, not loading url " + url); }},
        addNavPlugin: function(url) { var vm = this; moqui.loadComponent(url, function(comp) { vm.navPlugins.push(comp); }) },
        addNotify: function(message, type) {
            var histList = this.notifyHistoryList.slice(0);
            var nowDate = new Date();
            var nh = nowDate.getHours(); if (nh < 10) nh = '0' + nh;
            var nm = nowDate.getMinutes(); if (nm < 10) nm = '0' + nm;
            var ns = nowDate.getSeconds(); if (ns < 10) ns = '0' + ns;
            histList.unshift({message:message, type:type, time:(nh + ':' + nm + ':' + ns)});
            while (histList.length > 25) { histList.pop(); }
            this.notifyHistoryList = histList;
        },
        switchDarkLight: function() {
            var jqBody = $("body"); jqBody.toggleClass("bg-dark"); jqBody.toggleClass("bg-light");
            var currentStyle = jqBody.hasClass("bg-dark") ? "bg-dark" : "bg-light";
            $.ajax({ type:'POST', url:'/apps/setPreference', error:moqui.handleAjaxError,
                data:{ moquiSessionToken: this.moquiSessionToken, preferenceKey:'OUTER_STYLE', preferenceValue:currentStyle } });
        },
        showScreenDocDialog: function(docIndex) {
            $("#screen-document-dialog").modal("show");
            $("#screen-document-dialog-body").load(this.currentPath + '/screenDoc?docIndex=' + docIndex);
        },
        stopProp: function (e) { e.stopPropagation(); },
        getNavHref: function(navIndex) {
            if (!navIndex) navIndex = this.navMenuList.length - 1;
            var navMenu = this.navMenuList[navIndex];
            if (navMenu.extraPathList && navMenu.extraPathList.length) {
                var href = navMenu.path + '/' + navMenu.extraPathList.join('/');
                var questionIdx = navMenu.pathWithParams.indexOf("?");
                if (questionIdx > 0) { href += navMenu.pathWithParams.slice(questionIdx); }
                return href;
            } else {
                return navMenu.pathWithParams;
            }
        }
    },
    watch: {
        navMenuList: function(newList) { if (newList.length > 0) {
            var cur = newList[newList.length - 1];
            var par = newList.length > 1 ? newList[newList.length - 2] : null;
            // if there is an extraPathList set it now
            if (cur.extraPathList) this.extraPathList = cur.extraPathList;
            // make sure full currentPathList and activeSubscreens is populated (necessary for minimal path urls)
            var basePathSize = this.basePath.split('/').length;
            var fullPathList = cur.path.split('/').slice(basePathSize);
            console.info('nav updated fullPath ' + JSON.stringify(fullPathList) + ' currentPathList ' + JSON.stringify(this.currentPathList));
            this.currentPathList = fullPathList;
            this.reloadSubscreens();

            // update history and document.title
            var newTitle = (par ? par.title + ' - ' : '') + cur.title;
            var curUrl = cur.pathWithParams; var questIdx = curUrl.indexOf("?");
            if (questIdx > 0) {
                var parmList = curUrl.substring(questIdx+1).split("&");
                curUrl = curUrl.substring(0, questIdx);
                var dpCount = 0;
                var titleParms = "";
                for (var pi=0; pi<parmList.length; pi++) {
                    var parm = parmList[pi]; if (parm.indexOf("pageIndex=") === 0) continue;
                    if (curUrl.indexOf("?") === -1) { curUrl += "?"; } else { curUrl += "&"; }
                    curUrl += parm;
                    if (dpCount > 1) continue; // add up to 2 parms to the title
                    var eqIdx = parm.indexOf("=");
                    if (eqIdx > 0) {
                        var key = parm.substring(0, eqIdx);
                        if (key.indexOf("_op") > 0 || key.indexOf("_not") > 0 || key.indexOf("_ic") > 0 || key === "moquiSessionToken") continue;
                        if (titleParms.length > 0) titleParms += ", ";
                        titleParms += decodeURIComponent(parm.substring(eqIdx + 1));
                    }
                }
                if (titleParms.length > 0) {
                    if (titleParms.length > 70) titleParms = titleParms.substring(0, 70) + "...";
                    newTitle = newTitle + " (" + titleParms + ")";
                }
            }
            var navHistoryList = this.navHistoryList;
            for (var hi=0; hi<navHistoryList.length;) {
                if (navHistoryList[hi].pathWithParams === curUrl) { navHistoryList.splice(hi,1); } else { hi++; } }
            navHistoryList.unshift({ title:newTitle, pathWithParams:curUrl, image:cur.image, imageType:cur.imageType });
            while (navHistoryList.length > 25) { navHistoryList.pop(); }
            document.title = newTitle;
        }},
        currentPathList: function(newList) {
            // console.info('set currentPathList to ' + JSON.stringify(newList) + ' activeSubscreens.length ' + this.activeSubscreens.length);
            var lastPath = newList[newList.length - 1];
            if (lastPath) { $(this.$el).removeClass().addClass(lastPath); }
        }
    },
    computed: {
        currentPath: {
            get: function() { var curPath = this.currentPathList; var extraPath = this.extraPathList;
                return this.basePath + (curPath && curPath.length > 0 ? '/' + curPath.join('/') : '') +
                    (extraPath && extraPath.length > 0 ? '/' + extraPath.join('/') : ''); },
            set: function(newPath) {
                if (!newPath || newPath.length === 0) { this.currentPathList = []; return; }
                if (newPath.slice(newPath.length - 1) === '/') newPath = newPath.slice(0, newPath.length - 1);
                if (newPath.indexOf(this.linkBasePath) === 0) { newPath = newPath.slice(this.linkBasePath.length + 1); }
                else if (newPath.indexOf(this.basePath) === 0) { newPath = newPath.slice(this.basePath.length + 1); }
                this.currentPathList = newPath.split('/');
            }},
        currentLinkPath: function() { var curPath = this.currentPathList; var extraPath = this.extraPathList;
            return this.linkBasePath + (curPath && curPath.length > 0 ? '/' + curPath.join('/') : '') +
                (extraPath && extraPath.length > 0 ? '/' + extraPath.join('/') : ''); },
        currentSearch: {
            get: function() { return moqui.objToSearch(this.currentParameters); },
            set: function(newSearch) { this.currentParameters = moqui.searchToObj(newSearch); }
        },
        currentLinkUrl: function() { var srch = this.currentSearch; return this.currentLinkPath + (srch.length > 0 ? '?' + srch : ''); },
        ScreenTitle: function() { return this.navMenuList.length > 0 ? this.navMenuList[this.navMenuList.length - 1].title : ""; }
    },
    created: function() {
        this.moquiSessionToken = $("#confMoquiSessionToken").val();
        this.appHost = $("#confAppHost").val(); this.appRootPath = $("#confAppRootPath").val();
        this.basePath = $("#confBasePath").val(); this.linkBasePath = $("#confLinkBasePath").val();
        this.userId = $("#confUserId").val();
        this.locale = $("#confLocale").val(); if (moqui.localeMap[this.locale]) this.locale = moqui.localeMap[this.locale];
        var vm = this; $('.confNavPluginUrl').each(function(idx, el) { vm.addNavPlugin($(el).val()); });
        this.notificationClient = new moqui.NotificationClient((location.protocol === 'https:' ? 'wss://' : 'ws://') + this.appHost + this.appRootPath + "/notws");
    },
    mounted: function() {
        var jqEl = $(this.$el);
        jqEl.find('.navbar [data-toggle="tooltip"]').tooltip({ placement:'bottom', trigger:'hover' });
        jqEl.find('#history-menu-link').tooltip({ placement:'bottom', trigger:'hover' });
        jqEl.find('#notify-history-menu-link').tooltip({ placement:'bottom', trigger:'hover' });
        jqEl.find('#document-menu-link').tooltip({ placement:'bottom', trigger:'hover' });
        // load the current screen
        this.setUrl(window.location.pathname + window.location.search);
        // init the NotificationClient and register 'displayNotify' as the default listener
        this.notificationClient.registerListener("ALL");

        $("#screen-document-dialog").on("hidden.bs.modal", function () { var jqEl = $("#screen-document-dialog-body");
                jqEl.empty(); jqEl.append('<div class="spinner"><div>Loading…</div></div>'); });
    }
});
window.addEventListener('popstate', function() { moqui.webrootVue.setUrl(window.location.pathname + window.location.search); });
