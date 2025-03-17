const { h, createApp, defineComponent } = Vue


moqui.routes = [
    {
        path:'/qapps2/:pathMatch(.*)*', component: Vue.markRaw(defineComponent({
    data() {
        return {
            component: null
        }
    },
    async created() {
        // Load the component from server
        this.screenPath = this.$route.path.replace('/qapps2', '/apps') + '.qvt2'
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
    <#--  {path: '${realPath}', component: defineComponent({
        template: `<div>
            <q-btn to="/qapps2/marble/dashboard" label="Go to Marble Dashboard" color="primary" />
        </div>`
    })},  -->
<#--<#list pathList as path>-->
<#--    {-->
<#--    path: "${path.path}",-->
<#--    component: "${path.component}"-->
<#--    }<#if path_has_next>,</#if>-->
<#--</#list>-->
]

const router = VueRouter.createRouter({
    history: VueRouter.createWebHistory(),
    routes: moqui.routes,
})