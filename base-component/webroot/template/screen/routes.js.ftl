const { h, createApp, defineComponent } = Vue

const screenPathRoot = $("#confBasePath").val() || '/apps'
const urlPathRoot = $("#linkBasePath").val() || '${urlPathRoot}'
        console.log('urlPathRoot', urlPathRoot)
        console.log('screenPathRoot', screenPathRoot)

moqui.routes = [
    {
        path:urlPathRoot + '/:pathMatch(.*)*', component: Vue.markRaw(defineComponent({
    data() {
        return {
            component: null
        }
    },
    async created() {
        // Load the component from server
        this.screenPath = this.$route.path.replace(urlPathRoot, screenPathRoot) + '.qvt2'
        console.log('Loading screen', this.screenPath)
        const response = await fetch(this.screenPath)
        const template = await response.text()
        
        // Create dynamic component and mark as raw to avoid reactivity
        console.log('Creating dynamic component', template)
        this.component = Vue.markRaw(defineComponent({
            template: template
        }))
    },
    render() {
        if (!this.component) {
            return h('div', 'Loading...')
        }
        return h(this.component)
    }
}))
    },
]

const router = VueRouter.createRouter({
    history: VueRouter.createWebHistory(),
    routes: moqui.routes,
})