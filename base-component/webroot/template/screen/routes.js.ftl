const { h, createApp, defineComponent } = Vue


moqui.routes = [
    {
        path:'/qapps2/:pathMatch(.*)*', component: defineComponent({
    data() {
        return {
            component: null
        }
    },
    async created() {
        // Load the component from server
        this.screenPath = this.$route.path.replace('/qapps2', '/apps') + '.qvt2'
        const response = await fetch(this.screenPath)
        const template = await response.text()
        
        // Create dynamic component
        this.component = defineComponent({
            template: template
        })
    },
    render() {
        if (!this.component) {
            return h('div', 'Loading...')
        }
        return h(this.component)
    }
})
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

<#--  router.beforeEach((to, from, next) => {
    if (!router.getRoutes().find(r => r.path === from.path) && from.path !== '/') {
        router.addRoute({
            path: from.path,
            component: defineComponent({
                template: `<div>
                    <q-btn to="/qapps2/marble/dashboard" label="Go to Marble Dashboard" color="primary" />
                </div>`
            })
        })
    } else {
        console.log('route already exists', to, from)
    }
    console.log('beforeEach', to, from)

    next()
})  -->