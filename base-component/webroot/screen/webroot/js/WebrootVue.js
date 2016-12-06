/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

/* TODO:
 - fix parameter passing window.location.target instead of pathname?
 - grey screen and/or add spinner overly when loading currentComponent (element always there with a bound class to show/hide)

 - use m-link for other links instead of a (or somehow intercept?)
 - do something with form submits to submit in background and refresh current html based component (new client rendered screens won't need this)
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

Vue.component('m-link', {
    template: '<a v-bind:href="href" v-on:click="go"><slot></slot></a>',
    props: { href: String, required: true },
    methods: {
        go: function(event) {
            event.preventDefault();
            this.$root.currentPath = this.href;
            window.history.pushState(null, this.$root.ScreenTitle, this.href);
        }
    }
});

var webrootVue = new Vue({
    el: '#apps-root',
    data: {
        currentPath: "",
        navMenuList: [],
        currentComponent: EmptyComponent
    },
    methods: {
        asyncSetMenu: function(outerList) { if (outerList) { this.navMenuList = outerList; } }
    },
    watch: {
        currentPath: function(path) {
            if (!path || path.length === 0) return;
            jQuery.ajax({ type:"GET", url:"/menuData" + path, dataType:"json", success:this.asyncSetMenu });

            var url = path + (path.includes('?') ? '&' : '?') + "lastStandalone=-2";
            jQuery.ajax({ type:"GET", url:url, success: function (screenText) {
                console.log("getScreenComponent " + path);
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
        ScreenTitle: function() { return this.navMenuList.length > 0 ? this.navMenuList[this.navMenuList.length - 1].title : ""; }
    },
    mounted: function() { this.currentPath = window.location.pathname; }
});

window.addEventListener('popstate', function() { webrootVue.currentPath = window.location.pathname; });
