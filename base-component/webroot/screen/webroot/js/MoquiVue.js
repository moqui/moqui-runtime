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
function ensureMenuList(path) {
    //
}

var contentVue = new Vue({
    el: '#content',
    data: {
        currentPath: window.location.pathname
    },
    // TODO: maybe move ViewComponent to methods instead of computed to it's not cached?
    computed: {
        ViewComponent: function () { return getScreenComponent(this.currentPath) || NotFound }
    },
    render: function (h) { return h(this.ViewComponent) }
});

var navBarVue = new Vue({
    el: '#header-menus',
    data: {
        menuList: []
    }
});

Vue.component('m-link', {
    // TOOD: replace 'active' with
    template: '<a v-bind:href="href" v-bind:class="{ active: isActive }" v-on:click="go"><slot></slot></a>',
    props: { href: String, required: true },
    computed: {
        isActive: function() {
            return this.href === contentVue.currentPath;
            // return this.href === this.$root.currentPath;
        }
    },
    methods: {
        go: function(event) {
            event.preventDefault();
            contentVue.currentPath = this.href;
            // this.$root.currentPath = this.href;
            window.history.pushState(null, getScreenComponent(this.href), this.href);

            // TODO update menu as well as current view; maybe have menu based on this.$root.currentPath (${vueInstance}.currentPath)?
        }
    }
});

window.addEventListener('popstate', function() { contentVue.currentPath = window.location.pathname; });
