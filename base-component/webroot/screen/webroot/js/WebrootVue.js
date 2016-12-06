/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

var NotFound = Vue.extend({ template: '<div id="current-page-root"><h4>Screen not found at {{this.$root.currentPath}}</h4></div>' });
var EmptyComponent = Vue.extend({ template: '<div id="current-page-root"></div>' });
// TODO: make this much more fancy... add a spinner and all
// var LoadingComponent = Vue.extend({ template: '<div id="current-page-root"><h4>Page loading</h4></div>' });

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

            // TODO: supporting fetching JSON to create component independent of data; with that maybe add some local caching?
            var url = path + (path.includes('?') ? '&' : '?') + "lastStandalone=-2";
            // webrootVue.currentComponent = LoadingComponent;
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
