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

<#macro attributeValue textValue>${Static["org.moqui.impl.StupidUtilities"].encodeForXmlAttribute(textValue, true)}</#macro>

<#macro @element><fo:block>=== Doing nothing for element ${.node?node_name}, not yet implemented. ===</fo:block></#macro>

<#macro screen>
    <#if !layoutMaster?has_content><#assign layoutMaster = "letter-portrait"></#if>
    <#-- calculate width in pixels for layout masters defined in Header.xsl-fo.ftl, based on 72dpi -->
    <#switch layoutMaster>
        <#case "letter-landscape"><#case "tabloid-portrait"><#assign layoutWidthPx = 10.5 * 72><#break>
        <#case "legal-landscape"><#assign layoutWidthPx = 13.5 * 72><#break>
        <#case "tabloid-landscape"><#assign layoutWidthPx = 16.5 * 72><#break>
        <#case "a4-portrait"><#assign layoutWidthPx = 7.8 * 72><#break>
        <#case "a4-landscape"><#case "a3-portrait"><#assign layoutWidthPx = 11.2 * 72><#break>
        <#case "a3-landscape"><#assign layoutWidthPx = 16 * 72><#break>
        <#-- default applies to letter-portrait, legal-portrait -->
        <#default><#assign layoutWidthPx = 8 * 72>
    </#switch>
    <#-- using a 9pt font 6px per character should be plenty (12cpi) - fits for Courier, Helvetica could be less on average (like 4.5) but make sure enough space -->
    <#assign pixelsPerChar = 6>
    <#assign lineCharactersNum = layoutWidthPx / pixelsPerChar>
    <#recurse>
</#macro>
<#macro widgets>
<#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
<#recurse>
<#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
</#macro>
<#macro "fail-widgets">
<#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
<#recurse>
<#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
</#macro>

<#-- ================ Subscreens ================ -->
<#macro "subscreens-menu"></#macro>
<#macro "subscreens-active">${sri.renderSubscreen()}</#macro>
<#macro "subscreens-panel">${sri.renderSubscreen()}</#macro>

<#-- ================ Section ================ -->
<#macro section>
    <#if sri.doBoundaryComments()><!-- BEGIN section[@name=${.node["@name"]}] --></#if>
    ${sri.renderSection(.node["@name"])}
    <#if sri.doBoundaryComments()><!-- END   section[@name=${.node["@name"]}] --></#if>
</#macro>
<#macro "section-iterate">
    <#if sri.doBoundaryComments()><!-- BEGIN section-iterate[@name=${.node["@name"]}] --></#if>
    ${sri.renderSection(.node["@name"])}
    <#if sri.doBoundaryComments()><!-- END   section-iterate[@name=${.node["@name"]}] --></#if>
</#macro>

<#-- ================ Containers ================ -->
<#macro container><#recurse></#macro>
<#macro "container-box">
    <#recurse .node["box-header"][0]>
    <#if .node["box-body"]?has_content><#recurse .node["box-body"][0]></#if>
    <#if .node["box-body-nopad"]?has_content><#recurse .node["box-body-nopad"][0]></#if>
</#macro>
<#macro "container-row">
    <#list .node["row-col"] as rowColNode><#recurse rowColNode></#list>
</#macro>

<#macro "container-panel">
    <#-- NOTE: consider putting header and footer in table spanning 3 columns -->
    <#if .node["panel-header"]?has_content>
    <fo:block><#recurse .node["panel-header"][0]>
    </fo:block>
    </#if>
    <fo:table border="solid black">
        <fo:table-body><fo:table-row>
            <#if .node["panel-left"]?has_content>
            <fo:table-cell padding="3pt"><fo:block><#recurse .node["panel-left"][0]>
            </fo:block></fo:table-cell></#if>
            <fo:table-cell padding="3pt"><fo:block><#recurse .node["panel-center"][0]>
            </fo:block></fo:table-cell>
            <#if .node["panel-right"]?has_content>
            <fo:table-cell padding="3pt"><fo:block><#recurse .node["panel-right"][0]>
            </fo:block></fo:table-cell></#if>
        </fo:table-row></fo:table-body>
    </fo:table>
    <#if .node["panel-footer"]?has_content>
    <fo:block><#recurse .node["panel-footer"][0]>
    </fo:block>
    </#if>
</#macro>
<#macro "container-dialog">
    <fo:block>
    <#recurse>
    </fo:block>
</#macro>

<#-- ==================== Includes ==================== -->
<#macro "include-screen">
<#if sri.doBoundaryComments()><!-- BEGIN include-screen[@location=${.node["@location"]}][@share-scope=${.node["@share-scope"]!}] --></#if>
${sri.renderIncludeScreen(.node["@location"], .node["@share-scope"]!)}
<#if sri.doBoundaryComments()><!-- END   include-screen[@location=${.node["@location"]}][@share-scope=${.node["@share-scope"]!}] --></#if>
</#macro>

<#-- ============== Tree ============== -->
<#-- TABLED, not to be part of 1.0:
<#macro tree>
</#macro>
<#macro "tree-node">
</#macro>
<#macro "tree-sub-node">
</#macro>
-->

<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode">
<#if .node["text"]?has_content>
    <#list .node["text"] as textNode>
        <#if textNode["@type"]?has_content && textNode["@type"] == sri.getRenderMode()><#assign textToUse = textNode/></#if>
    </#list>
    <#if !textToUse?has_content>
        <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#assign textToUse = textNode/></#if></#list>
    </#if>
    <#if textToUse??>
        <#if textToUse["@location"]?has_content>
<#if sri.doBoundaryComments() && !(textToUse["@no-boundary-comment"]! == "true")><!-- BEGIN render-mode.text[@location=${textToUse["@location"]}][@template=${textToUse["@template"]!"true"}] --></#if>
    <#-- NOTE: this still won't encode templates that are rendered to the writer -->
    <#lt><#if .node["@encode"]! == "true">${sri.renderText(textToUse["@location"], textToUse["@template"]!)?html}<#else>${sri.renderText(textToUse["@location"], textToUse["@template"]!)}</#if>
<#if sri.doBoundaryComments()><!-- END   render-mode.text[@location=${textToUse["@location"]}][@template=${textToUse["@template"]!"true"}] --></#if>
        </#if>
        <#assign inlineTemplateSource = textToUse?string/>
        <#if inlineTemplateSource?has_content>
<#if sri.doBoundaryComments() && !(textToUse["@no-boundary-comment"]! == "true")><!-- BEGIN render-mode.text[inline][@template=${textToUse["@template"]!"true"}] --></#if>
          <#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
            <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
            <#lt><@inlineTemplate/>
          <#else>
            <#lt><#if .node["@encode"]! == "true">${inlineTemplateSource?html}<#else>${inlineTemplateSource}</#if>
          </#if>
          <#if sri.doBoundaryComments()><!-- END   render-mode.text[inline][@template=${textToUse["@template"]!"true"}] --></#if>
        </#if>
    </#if>
</#if>
</#macro>

<#macro text><#-- do nothing, is used only through "render-mode" --></#macro>

<#-- ================== Standalone Fields ==================== -->
<#macro link>
    <fo:block><@linkFormLink .node/></fo:block>
</#macro>
<#macro linkFormLink linkNode>
    <#assign linkNode = .node>
    <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#if linkNode["@entity-name"]?has_content>
            <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
        <#else>
            <#assign textMap = "">
            <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
            <#if textMap?has_content>
                <#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
            <#else>
                <#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")>
            </#if>
        </#if>
        <#-- TODO: get external link working, always gets prefixed in a weird way, must be some FOP setting or something
        <#assign urlInstance = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
        <#if linkNode["@url-noparam"]! == "true"><#assign urlText = urlInstance.url/><#else><#assign urlText = urlInstance.urlWithParams/></#if>
        <fo:basic-link external-destination="url('${urlText?url("ISO-8859-1")}')" color="blue"><@attributeValue linkText/></fo:basic-link>
        -->
        <@attributeValue linkText/>
    </#if>
</#macro>

<#macro image>
    <#-- TODO: make real xsl-fo image -->
    <img src="${sri.makeUrlByType(.node["@url"],.node["@url-type"]!"content",null,"true")}" alt="${.node["@alt"]!"image"}"<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if><#if .node["@width"]?has_content> width="${.node["@width"]}"</#if><#if .node["@height"]?has_content> height="${.node["@height"]}"</#if>/>
</#macro>
<#macro label>
    <#-- TODO: handle label type somehow -->
    <#assign labelValue = ec.resource.expand(.node["@text"], "")/>
    <#if (labelValue?length < 255)><#assign labelValue = ec.l10n.localize(labelValue)/></#if>
    <fo:block><#if !.node["@encode"]?has_content || .node["@encode"] == "true">${labelValue?html?replace("\n", "<br>")}<#else>${labelValue}</#if></fo:block>
</#macro>
<#macro parameter><#-- do nothing, used directly in other elements --></#macro>

<#-- ====================================================== -->
<#-- ======================= Form ========================= -->
<#macro "form-single">
    <#if sri.doBoundaryComments()><!-- BEGIN form-single[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formInstance = sri.getFormInstance(.node["@name"])>
    <#assign formNode = formInstance.getFtlFormNode()>
    <#t>${sri.pushSingleFormMapContext(formNode)}
    <#if formNode["field-layout"]?has_content>
        <#recurse formNode["field-layout"][0]/>
    <#else>
        <#list formNode["field"] as fieldNode><@formSingleSubField fieldNode/></#list>
    </#if>
    <#t>${sri.popContext()}<#-- context was pushed for the form-single so pop here at the end -->
    <#if sri.doBoundaryComments()><!-- END   form-single[@name=${.node["@name"]}] --></#if>
</#macro>
<#macro "field-ref">
    <#assign fieldRef = .node["@name"]>
    <#assign fieldNode = formInstance.getFtlFieldNode(fieldRef)!>
    <#if fieldNode??>
        <@formSingleSubField fieldNode/>
    <#else>
    <fo:block>Error: could not find field with name ${fieldRef} referred to in a field-ref.@name attribute.</fo:block>
    </#if>
</#macro>
<#macro "fields-not-referenced">
    <#assign nonReferencedFieldList = formInstance.getFieldLayoutNonReferencedFieldList()>
    <#list nonReferencedFieldList as nonReferencedField>
        <@formSingleSubField nonReferencedField/></#list>
</#macro>
<#macro "field-row">
<fo:table><fo:table-body><fo:table-row>
    <#list .node?children as rowChildNode>
        <fo:table-cell wrap-option="wrap" padding="2pt" width="50%">
            <#visit rowChildNode/>
        </fo:table-cell>
    </#list>
</fo:table-row></fo:table-body></fo:table>
</#macro>
<#macro "field-row-big">
<fo:table><fo:table-body><fo:table-row>
    <#list .node?children as rowChildNode>
        <fo:table-cell wrap-option="wrap" padding="2pt">
            <#visit rowChildNode/>
        </fo:table-cell>
    </#list>
</fo:table-row></fo:table-body></fo:table>
</#macro>
<#macro "field-group">
    <fo:block font-size="10pt">${ec.getL10n().localize(.node["@title"]!("Fields"))}</fo:block>
    <#recurse .node/>
</#macro>
<#macro "field-accordion"><#recurse .node/></#macro>

<#macro formSingleSubField fieldNode>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.condition(fieldSubNode["@condition"], "")>
            <@formSingleWidget fieldSubNode/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <@formSingleWidget fieldNode["default-field"][0]/>
        <#return>
    </#if>
</#macro>
<#macro formSingleWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content && (fieldSubNode?parent["@hide"]! != "false")><#return></#if>
    <#if fieldSubNode["hidden"]?has_content && (fieldSubNode?parent["@hide"]! != "false")><#recurse fieldSubNode/><#return></#if>
    <#if fieldSubNode?parent["@hide"]! == "true"><#return></#if>
    <fo:block>
        <#if !fieldSubNode["submit"]?has_content><label class="form-title" for="${formNode["@name"]}_${fieldSubNode?parent["@name"]}"><@fieldTitle fieldSubNode/></label></#if>
        <#recurse fieldSubNode/>
    </fo:block>
</#macro>
<#macro set><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>

<#macro "form-list">
<#if sri.doBoundaryComments()><!-- BEGIN form-list[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formInstance = sri.getFormInstance(.node["@name"])>
    <#assign formNode = formInstance.getFtlFormNode()>
    <#assign isMulti = formNode["@multi"]! == "true">
    <#assign isMultiFinalRow = false>
    <#assign urlInfo = sri.makeUrlByType(formNode["@transition"], "transition", null, "false")>
    <#assign listName = formNode["@list"]>
    <#assign listObject = ec.resource.expression(listName, "")!>
    <#assign formListColumnList = formInstance.getFormListColumnInfo()>
    <#assign columnCharWidths = formInstance.getFormListColumnCharWidths(formListColumnList, lineCharactersNum)>

    <#if !(formNode["@paginate"]! == "false") && context[listName + "Count"]?? && (context[listName + "Count"]! > 0)>
        <fo:block>${context[listName + "PageRangeLow"]} - ${context[listName + "PageRangeHigh"]} / ${context[listName + "Count"]}</fo:block>
    </#if>
    <fo:table>
        <fo:table-header border-bottom="thin solid black">
            <fo:table-row>
                <#list formListColumnList as columnFieldList>
                    <#assign cellCharWidth = columnCharWidths.get(columnFieldList_index)>
                    <#if (cellCharWidth > 0)>
                        <#assign cellPixelWidth = cellCharWidth * pixelsPerChar>
                        <fo:table-cell wrap-option="wrap" padding="2pt" width="${cellPixelWidth}px">
                        <#list columnFieldList as fieldNode>
                            <fo:block text-align="${fieldNode["@align"]!"left"}" font-weight="bold"><@formListHeaderField fieldNode/></fo:block>
                        </#list>
                        </fo:table-cell>
                    </#if>
                </#list>
            </fo:table-row>
        </fo:table-header>
        <fo:table-body>
            <#list listObject as listEntry>
                <#assign listEntryIndex = listEntry_index>
                <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
                ${sri.startFormListRow(formInstance, listEntry, listEntry_index, listEntry_has_next)}
                <fo:table-row>
                    <#list formListColumnList as columnFieldList>
                        <#assign cellCharWidth = columnCharWidths.get(columnFieldList_index)>
                        <#if (cellCharWidth > 0)>
                            <fo:table-cell wrap-option="wrap" padding="2pt">
                            <#list columnFieldList as fieldNode>
                                <@formListSubField fieldNode/>
                            </#list>
                            </fo:table-cell>
                        </#if>
                    </#list>
                </fo:table-row>
                ${sri.endFormListRow()}
            </#list>
        </fo:table-body>
        ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
    </fo:table>
<#if sri.doBoundaryComments()><!-- END   form-list[@name=${.node["@name"]}] --></#if>
</#macro>
<#macro formListHeaderField fieldNode>
    <#if fieldNode["header-field"]?has_content>
        <#assign fieldSubNode = fieldNode["header-field"][0]>
    <#elseif fieldNode["default-field"]?has_content>
        <#assign fieldSubNode = fieldNode["default-field"][0]>
    <#else>
        <#-- this only makes sense for fields with a single conditional -->
        <#assign fieldSubNode = fieldNode["conditional-field"][0]>
    </#if>
    <@fieldTitle fieldSubNode/>
</#macro>
<#macro formListSubField fieldNode>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.condition(fieldSubNode["@condition"], "")>
            <@formListWidget fieldSubNode/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <@formListWidget fieldNode["default-field"][0]/>
        <#return>
    </#if>
</#macro>
<#macro formListWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content || fieldSubNode["hidden"]?has_content || fieldSubNode["submit"]?has_content ||
            fieldSubNode?parent["@hide"]! == "true"><#return></#if>

    <#local fieldNode = fieldSubNode?parent>
    <fo:block text-align="${fieldNode["@align"]!"left"}">
        <#list fieldSubNode?children as widgetNode>
            <#if widgetNode?node_name == "link">
                <#t><@linkFormLink widgetNode/>
            <#else>
                <#t><#visit widgetNode>
            </#if>
        </#list>
    </fo:block>
</#macro>
<#macro "row-actions"><#-- do nothing, these are run by the SRI --></#macro>

<#macro fieldName widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode["@name"]?html}<#if isMulti?? && isMulti && listEntryIndex??>_${listEntryIndex}</#if></#macro>
<#macro fieldId widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode?parent["@name"]}_${fieldNode["@name"]}<#if listEntryIndex??>_${listEntryIndex}</#if></#macro>
<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${fieldSubNode["@title"]}<#else><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.localize(titleValue)}</#macro>

<#macro field><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "conditional-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "default-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>

<#-- ================== Form Field Widgets ==================== -->

<#macro check>
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]!/></#if>
    <#t><#if currentValue?has_content>${options.get(currentValue)?default(currentValue)}</#if>
</#macro>

<#macro "date-find"></#macro>
<#macro "date-period"></#macro>
<#macro "date-time">
    <#assign javaFormat = .node["@format"]!>
    <#if !javaFormat?has_content>
        <#if .node["@type"]! == "time"><#assign javaFormat="HH:mm">
        <#elseif .node["@type"]! == "date"><#assign javaFormat="yyyy-MM-dd">
        <#else><#assign javaFormat="yyyy-MM-dd HH:mm"></#if>
    </#if>
    <#assign fieldValue = sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", javaFormat)>
    <#t><@attributeValue fieldValue/>
</#macro>

<#macro display>
    <#assign fieldValue = ""/>
    <#if .node["@text"]?has_content>
        <#assign fieldValue = ec.resource.expand(.node["@text"], "")>
        <#if .node["@currency-unit-field"]?has_content>
            <#assign fieldValue = ec.l10n.formatCurrency(fieldValue, ec.resource.expression(.node["@currency-unit-field"], ""))>
        </#if>
    <#elseif .node["@currency-unit-field"]?has_content>
        <#assign fieldValue = ec.l10n.formatCurrency(sri.getFieldValue(.node?parent?parent, ""), ec.resource.expression(.node["@currency-unit-field"], ""))>
    <#else>
        <#assign fieldValue = sri.getFieldValueString(.node)>
    </#if>
    <#t><@attributeValue fieldValue/>
</#macro>
<#macro "display-entity">
    <#assign fieldValue = ""/><#assign fieldValue = sri.getFieldEntityValue(.node)/>
    <#t><@attributeValue fieldValue/>
</#macro>

<#macro "drop-down">
    <#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]!></#if>
    <#t><@attributeValue (options.get(currentValue))!(currentValue)/>
</#macro>

<#macro file></#macro>
<#macro hidden></#macro>
<#macro ignored><#-- shouldn't ever be called as it is checked in the form-* macros --></#macro>
<#macro password></#macro>

<#macro radio>
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)/>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]!/></#if>
    <#t><#if currentValue?has_content>${options.get(currentValue)!(currentValue)}</#if>
</#macro>

<#macro "range-find"></#macro>
<#macro reset></#macro>

<#macro submit>
    <#assign fieldValue><@fieldTitle .node?parent/></#assign>
    <#t><@attributeValue fieldValue/>
</#macro>

<#macro "text-area">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@attributeValue fieldValue/>
</#macro>

<#macro "text-line">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@attributeValue fieldValue/>
</#macro>

<#macro "text-find">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@attributeValue fieldValue/>
</#macro>
