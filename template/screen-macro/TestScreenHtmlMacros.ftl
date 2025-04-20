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

<#include "DefaultScreenMacros.html.ftl"/>

<#macro container>
    <#assign contDivId><@nodeId .node/></#assign>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(.node["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <${ec.getResource().expand(.node["@type"]!"div", "")}<#if contDivId?has_content> id="${contDivId}"</#if><#if .node["@style"]?has_content> class="${ec.getResource().expandNoL10n(.node["@style"], "")}"</#if>>
        <#recurse>
        </${.node["@type"]!"div"}>
    </#if>
</#macro>
