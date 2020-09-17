<#--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#-- for 'plain' rendering most elements ignored, meant to defer to render-mode.text sections for js, vue, etc that have zero widget rendering -->
<#macro @element></#macro>

<#macro screen><#recurse></#macro>
<#macro widgets><#recurse></#macro>
<#macro "fail-widgets"><#recurse></#macro>

<#-- ================ Subscreens ================ -->
<#macro "subscreens-menu"></#macro>
<#macro "subscreens-active">${sri.renderSubscreen()}</#macro>
<#macro "subscreens-panel">${sri.renderSubscreen()}</#macro>

<#-- ================ Section ================ -->
<#macro section>${sri.renderSection(.node["@name"])}</#macro>
<#macro "section-iterate">${sri.renderSection(.node["@name"])}</#macro>
<#macro "section-include">${sri.renderSection(.node["@name"])}</#macro>

<#-- ==================== Includes ==================== -->
<#macro "include-screen">${sri.renderIncludeScreen(.node["@location"], .node["@share-scope"]!)}</#macro>

<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode">
<#if .node["text"]?has_content>
    <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#local textToUse = textNode/></#if></#list>
    <#list .node["text"] as textNode><#if textNode["@type"]?has_content && textNode["@type"]?split(",")?seq_contains(sri.getRenderMode())><#local textToUse = textNode></#if></#list>
    <#if textToUse??>
        <#if textToUse["@location"]?has_content>
            <#-- NOTE: this still won't encode templates that are rendered to the writer -->
            <#t><#if .node["@encode"]! == "true">${sri.renderText(textToUse["@location"], textToUse["@template"]?if_exists)?html}<#else>${sri.renderText(textToUse["@location"], textToUse["@template"]?if_exists)}</#if>
        </#if>
        <#assign inlineTemplateSource = textToUse?string>
        <#if inlineTemplateSource?has_content>
            <#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
                <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
                <#t><@inlineTemplate/>
            <#else>
                <#if .node["@encode"]! == "true">${inlineTemplateSource?html}<#else>${inlineTemplateSource}</#if>
            </#if>
        </#if>
    </#if>
</#if>
</#macro>
<#macro text><#-- do nothing, is used only through "render-mode" --></#macro>
