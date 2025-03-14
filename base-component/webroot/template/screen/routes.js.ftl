moqui.routes = [
    {path: '/qapps', component: () => loadModule('./vue/MScreen.vue')},
    {path: '/qapps2', component: () => loadModule('./vue/MScreen.vue')},
<#--<#list pathList as path>-->
<#--    {-->
<#--    path: "${path.path}",-->
<#--    component: "${path.component}"-->
<#--    }<#if path_has_next>,</#if>-->
<#--</#list>-->
]

