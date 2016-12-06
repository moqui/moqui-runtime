/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

function getScreenComponent(path) {
    // TODO: supporting fetching JSON to create component independent of data; with that maybe add some local caching?
    var url = path + (path.includes('?') ? '&' : '?') + "lastStandalone=-2";
    var screenText = undefined;
    var request = new XMLHttpRequest();
    request.open('GET', url, false);
    request.send(null);
    if (request.status === 200) { screenText = request.responseText; }
    // jQuery.ajax({ type:"GET", url:url, async:false, success: function (text) { screenText = text; } });
    console.log("getScreenComponent " + path);
    // console.log(screenText);
    if (screenText) return Vue.extend({
        template: '<div id="current-page-root">' + screenText + '</div>'
    })
}

var NotFound = Vue.extend({
    template: '<h4>Screen not found at {{this.$root.currentPath}}</h4>'
});

Vue.component('m-link', {
    template: '<a v-bind:href="href" v-on:click="go"><slot></slot></a>',
    props: { href: String, required: true },
    methods: {
        go: function(event) {
            event.preventDefault();
            this.$root.currentPath = this.href;
            this.$root.updateMenu();
            window.history.pushState(null, this.$root.ScreenTitle, this.href);
        }
    }
});

var rootVue = new Vue({
    el: '#apps-root',
    data: {
        currentPath: window.location.pathname,
        navMenuList: []
    },
    methods: {
        updateMenu: function() { jQuery.ajax({ type:"GET", url:"/menuData" + this.currentPath, dataType:"json", success:this.asyncSetMenu }); },
        asyncSetMenu: function (outerList) { if (outerList) { this.navMenuList = outerList; } }
    },
    computed: {
        ScreenTitle: function() { return this.navMenuList.length > 0 ? this.navMenuList[this.navMenuList.length - 1].title : ""; }
    },
    components: {
        /* 'header-navbar': { props: ['navMenuList'] }, */
        'current-page': {
            computed: {
                // TODO: maybe move ViewComponent to methods instead of computed to it's not cached? or is the cache intelligent enough to limit size?
                ViewComponent: function () { return getScreenComponent(this.$root.currentPath) || NotFound }
            },
            render: function (h) { return h(this.ViewComponent) }
        }
    },
    mounted: function() { this.updateMenu(); }
});

window.addEventListener('popstate', function() { rootVue.currentPath = window.location.pathname; });
