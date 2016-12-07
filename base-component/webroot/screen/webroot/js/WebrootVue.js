/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

/* TODO:
 - grey screen and/or add spinner overly when loading currentComponent (element always there with a bound class to show/hide)

 - use m-link for other links instead of a (or somehow intercept?)
 - do something with form submits to submit in background and refresh current html based component (new client rendered screens won't need this)

 - fix inline scripts that don't work (select2, datetimepicker, typeahead, etc)
   - by default Vue filters out all script elements from templates
   - workaround (maybe best not to...): https://github.com/taoeffect/vue-script2/blob/master/dist/vue-script2.js
 - use vue-aware widgets or add vue component wrappers for them (like the select2 example on vuejs.org)
 - remove all html script elements...

 - change other header widgets to be dynamic
   - history
     - change to vue template based on vue component data
     - update along with currentPath change watch
   - notifications/messages/etc - update in background using function that runs on a timer?

 - big new feature for client rendered screens
   - on the server render to a Vue component object (as JSON)
   - make these completely static, not dependent on any inline data, so they can be cached
   - separate request to get data to populate

 */

var NotFound = Vue.extend({ template: '<div id="current-page-root"><h4>Screen not found at {{this.$root.currentPath}}</h4></div>' });
var EmptyComponent = Vue.extend({ template: '<div id="current-page-root"></div>' });

/* ========== inline components ========== */
Vue.component('m-link', {
    template: '<a v-bind:href="href" v-on:click="go"><slot></slot></a>',
    props: { href: String, required: true },
    methods: {
        go: function(event) {
            event.preventDefault();
            this.$root.CurrentUrl = this.href;
            window.history.pushState(null, this.$root.ScreenTitle, this.href);
        }
    }
});
Vue.component('drop-down', {
    props: ['options', 'value', 'combo', 'optionsUrl', 'labelField', 'valueField', 'dependsOn'],
    template: "<select><slot></slot></select>",
    methods: {
        populate: function() {
            // TODO
        }
    },
    mounted: function () {
        var vm = this;
        var opts = { minimumResultsForSearch:15, theme:'bootstrap', data: this.options };
        if (this.combo) { opts.tags = true; opts.tokenSeparators = [',',' ']; }
        if (this.value) { $(this.$el).val(this.value); }
        $(this.$el).select2(opts).on('change', function () { vm.$emit('input', this.value) })
                .on("select2:select", function () { $(vm.$el).select2("open").select2("close"); });
    },
    watch: {
        value: function (value) { $(this.$el).select2('val', value) },
        options: function (options) { $(this.$el).select2({ data: options }) }
    },
    destroyed: function () { $(this.$el).off().select2('destroy') }
});

/* ========== webrootVue - root Vue component with router ========== */
var webrootVue = new Vue({
    el: '#apps-root',
    data: {
        currentPath: "",
        currentSearch: "",
        navMenuList: [],
        currentComponent: EmptyComponent
    },
    methods: {
        asyncSetMenu: function(outerList) { if (outerList) { this.navMenuList = outerList; } }
    },
    watch: {
        // NOTE: this may eventually split to change the currentComponent only on currentPath change (for screens that support it)
        //     and if ever needed some sort of data refresh if currentSearch changes
        CurrentUrl: function(newUrl) {
            if (!newUrl || newUrl.length === 0) return;
            console.log("CurrentUrl changing to " + newUrl);
            // update menu
            jQuery.ajax({ type:"GET", url:"/menuData" + newUrl, dataType:"json", success:this.asyncSetMenu });
            // update currentComponent
            var url = newUrl + (newUrl.includes('?') ? '&' : '?') + "lastStandalone=-2";
            jQuery.ajax({ type:"GET", url:url, success: function (screenText) {
                // console.log(screenText);
                if (screenText) { webrootVue.currentComponent = Vue.extend({
                    template: '<div id="current-page-root">' + screenText + '</div>'
                }) } else {
                    webrootVue.currentComponent = NotFound
                }
            }});
        }
    },
    computed: {
        CurrentUrl: {
            get: function() { return this.currentPath + this.currentSearch; },
            set: function(href) {
                var splitHref = href.split("?");
                this.currentPath = splitHref[0];
                this.currentSearch = splitHref.length > 1 ? '?' + splitHref[1] : "";
            }
        },
        ScreenTitle: function() { return this.navMenuList.length > 0 ? this.navMenuList[this.navMenuList.length - 1].title : ""; }
    },
    mounted: function() { this.currentPath = window.location.pathname; this.currentSearch = window.location.search; }
});

window.addEventListener('popstate', function() { webrootVue.currentPath = window.location.pathname; webrootVue.currentSearch = window.location.search; });
