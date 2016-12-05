/*
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
*/

function getScreenComponent(path) {
    // TODO: add some local caching?
    // TODO: fetch JSON and create component
    return Vue.extend({
        // extension options from JSON
    })
}

var NotFound = Vue.extend({
    // TODO
});

Vue.component('m-link', {
    template: '<a v-bind:href="href" v-on:click="go"><slot></slot></a>',
    props: { href: String, required: true },
    methods: {
        go: function(event) {
            event.preventDefault();
            this.$root.currentPath = this.href;
            window.history.pushState(null, this.$root.getScreenTitle, this.href);
            this.$root.updateMenu();

            // TODO update menu as well as current view; maybe have menu based on this.$root.currentPath (${vueInstance}.currentPath)?
        }
    }
});

var rootVue = new Vue({
    el: '#apps-root',
    data: {
        currentPath: window.location.pathname,
        navMenuList: [{ title:"Foo" }, {title:"bar"}]
    },
    methods: {
        updateMenu: function() {
            $.ajax({ type:"GET", url:"/menuData" + this.currentPath, dataType:"json" }).done(this.asyncSetMenu);
        },
        asyncSetMenu: function (outerList) {
            if (outerList) { console.log(outerList); this.navMenuList = outerList; }
        }
    },
    computed: {
        getScreenTitle: function() {
            // TODO: get title from nav menu data
            return ""
        }
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
