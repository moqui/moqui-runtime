<#--
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->

<#macro @element><p>=== Doing nothing for element ${.node?node_name}, not yet implemented. ===</p></#macro>

<#macro screen>
    <#recurse>
</#macro>
<#macro widgets><#t>
    <#t><#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
    <#t><#recurse>
    <#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
</#macro>
<#macro "fail-widgets"><#t>
    <#t><#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
    <#t><#recurse>
    <#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
</#macro>

<#-- ================ Subscreens ================ -->
<#macro "subscreens-menu">
    <#assign displayMenu = sri.activeInCurrentMenu!>
    <#assign menuId = .node["@id"]!"subscreensMenu">
    <#assign menuTitle = .node["@title"]!sri.getActiveScreenDef().getDefaultMenuName()!"Menu">
    <#if .node["@type"]! == "popup">
        <li id="${menuId}" class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">${ec.resource.expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
            <ul class="dropdown-menu">
                <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                    <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                    <#if urlInstance.isPermitted()>
                        <li class="<#if urlInstance.inCurrentScreenPath>active</#if>"><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>">
                            <#if urlInstance.sui.menuImage?has_content>
                                <#if urlInstance.sui.menuImageType == "icon">
                                    <i class="${urlInstance.sui.menuImage}" style="padding-right: 8px;"></i>
                                <#elseif urlInstance.sui.menuImageType == "url-plain">
                                    <img src="${urlInstance.sui.menuImage}" width="18" style="padding-right: 4px;"/>
                                <#else>
                                    <img src="${sri.buildUrl(urlInstance.sui.menuImage).url}" height="18" style="padding-right: 4px;"/>
                                </#if>
                            <#else>
                                <i class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                            </#if>
                            ${ec.resource.expand(subscreensItem.menuTitle, "")}
                        </a></li>
                    </#if>
                </#list>
            </ul>
        </li>
        <#-- NOTE: not putting this script at the end of the document so that it doesn't appear unstyled for as long -->
        <#-- move the menu to the header-menus container -->
        <script>$("#${.node["@header-menus-id"]!"header-menus"}").append($("#${menuId}"));</script>
    <#elseif .node["@type"]! == "popup-tree">
    <#else>
        <#-- default to type=tab -->
        <#if displayMenu!>
            <ul<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if> class="nav nav-tabs" role="tablist">
                <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                    <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                    <#if urlInstance.isPermitted()>
                        <li class="<#if urlInstance.inCurrentScreenPath>active</#if><#if urlInstance.disableLink> disabled</#if>"><#if urlInstance.disableLink>${ec.resource.expand(subscreensItem.menuTitle, "")}<#else><a href="${urlInstance.minimalPathUrlWithParams}">${ec.l10n.localize(subscreensItem.menuTitle)}</a></#if></li>
                    </#if>
                </#list>
            </ul>
        </#if>
        <#-- add to navbar bread crumbs too -->
        <div id="${menuId}-crumb" class="navbar-text">${ec.resource.expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></div>
        <script>$("#navbar-menu-crumbs").append($("#${menuId}-crumb"));</script>
    </#if>
</#macro>

<#macro "subscreens-active">
    ${sri.renderSubscreen()}
</#macro>

<#macro "subscreens-panel">
    <#assign dynamic = .node["@dynamic"]! == "true" && .node["@id"]?has_content>
    <#assign dynamicActive = 0>
    <#assign displayMenu = sri.activeInCurrentMenu!>
    <#assign menuId><#if .node["@id"]?has_content>${.node["@id"]}-menu<#else>subscreensPanelMenu</#if></#assign>
    <#assign menuTitle = .node["@title"]!sri.getActiveScreenDef().getDefaultMenuName()!"Menu">
    <#if .node["@type"]! == "popup">
        <li id="${menuId}" class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">${ec.resource.expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
            <ul class="dropdown-menu">
                <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                    <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                    <#if urlInstance.isPermitted()>
                        <li class="<#if urlInstance.inCurrentScreenPath>active</#if>"><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>">
                            <#if urlInstance.sui.menuImage?has_content>
                                <#if urlInstance.sui.menuImageType == "icon">
                                    <i class="${urlInstance.sui.menuImage}" style="padding-right: 8px;"></i>
                                <#elseif urlInstance.sui.menuImageType == "url-plain">
                                    <img src="${urlInstance.sui.menuImage}" width="18" style="padding-right: 4px;"/>
                                <#else>
                                    <img src="${sri.buildUrl(urlInstance.sui.menuImage).url}" height="18" style="padding-right: 4px;"/>
                                </#if>
                            <#else>
                                <i class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                            </#if>
                            ${ec.resource.expand(subscreensItem.menuTitle, "")}
                        </a></li>
                    </#if>
                </#list>
            </ul>
        </li>
        <#-- NOTE: not putting this script at the end of the document so that it doesn't appear unstyled for as long -->
        <#-- move the menu to the header menus section -->
        <script>$("#${.node["@header-menus-id"]!"header-menus"}").append($("#${menuId}"));</script>

        ${sri.renderSubscreen()}
    <#elseif .node["@type"]! == "stack">
        <h1>LATER stack type subscreens-panel not yet supported.</h1>
    <#elseif .node["@type"]! == "wizard">
        <h1>LATER wizard type subscreens-panel not yet supported.</h1>
    <#else>
        <#-- default to type=tab -->
        <div<#if .node["@id"]?has_content> id="${.node["@id"]}-menu"</#if>>
        <#if displayMenu!>
            <ul<#if .node["@id"]?has_content> id="${.node["@id"]}-menu"</#if> class="nav nav-tabs" role="tablist">
            <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                <#if urlInstance.isPermitted()>
                    <#if dynamic>
                        <#assign urlInstance = urlInstance.addParameter("lastStandalone", "true")>
                        <#if urlInstance.inCurrentScreenPath>
                            <#assign dynamicActive = subscreensItem_index>
                            <#assign urlInstance = urlInstance.addParameters(ec.web.requestParameters)>
                        </#if>
                    </#if>
                    <li class="<#if urlInstance.disableLink>disabled<#elseif urlInstance.inCurrentScreenPath>active</#if>"><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>">${ec.resource.expand(subscreensItem.menuTitle, "")}</a></li>
                </#if>
            </#list>
            </ul>
        </#if>
        <#-- add to navbar bread crumbs too -->
        <div id="${menuId}-crumb" class="navbar-text">${ec.resource.expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></div>
        <script>$("#navbar-menu-crumbs").append($("#${menuId}-crumb"));</script>

        <#if !dynamic || !displayMenu>
        <#-- these make it more similar to the HTML produced when dynamic, but not needed: <div<#if .node["@id"]?has_content> id="${.node["@id"]}-active"</#if> class="ui-tabs-panel"> -->
        ${sri.renderSubscreen()}
        <#-- </div> -->
        </#if>
        </div>
        <#if dynamic && displayMenu!>
            <#assign afterScreenScript>
                $("#${.node["@id"]}").tabs({ collapsible: true, selected: ${dynamicActive},
                    spinner: '<span class="ui-loading">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>',
                    ajaxOptions: { error: function(xhr, status, index, anchor) { $(anchor.hash).html("Error loading screen..."); } },
                    load: function(event, ui) { <#-- activateAllButtons(); --> }
                });
            </#assign>
            <#t>${sri.appendToScriptWriter(afterScreenScript)}
        </#if>
    </#if>
</#macro>

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
<#macro "section-include">
    <#if sri.doBoundaryComments()><!-- BEGIN section-include[@name=${.node["@name"]}] --></#if>
${sri.renderSection(.node["@name"])}
    <#if sri.doBoundaryComments()><!-- END   section-include[@name=${.node["@name"]}] --></#if>
</#macro>

<#-- ================ Containers ================ -->
<#macro nodeId widgetNode><#if .node["@id"]?has_content>${ec.resource.expand(widgetNode["@id"], "")}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#if></#macro>

<#macro container>
    <#assign divId><@nodeId .node/></#assign>
    <${.node["@type"]!"div"}<#if divId??> id="${divId}"</#if><#if .node["@style"]?has_content> class="${ec.resource.expand(.node["@style"], "")}"</#if>><#recurse>
    </${.node["@type"]!"div"}>
</#macro>

<#macro "container-box">
    <#assign divId><@nodeId .node/></#assign>
    <div class="panel panel-default"<#if divId??> id="${divId}"</#if>>
        <div class="panel-heading">
            <#recurse .node["box-header"][0]>

            <#if .node["box-toolbar"]?has_content>
                <div class="panel-toolbar">
                    <#recurse .node["box-toolbar"][0]>
                </div>
            </#if>
        </div>
        <div class="panel-body">
            <#recurse .node["box-body"][0]>
        </div>
    </div>
</#macro>

<#macro "container-row">
    <#assign divId><@nodeId .node/></#assign>
    <div class="row<#if .node["@style"]?has_content> ${ec.resource.expand(.node["@style"], "")}</#if>"<#if divId?has_content> id="${divId}"</#if>>
        <#list .node["row-col"] as rowColNode>
            <div class="<#if rowColNode["@lg"]?has_content> col-lg-${rowColNode["@lg"]}</#if><#if rowColNode["@md"]?has_content> col-md-${rowColNode["@md"]}</#if><#if rowColNode["@sm"]?has_content> col-sm-${rowColNode["@sm"]}</#if><#if rowColNode["@xs"]?has_content> col-xs-${rowColNode["@xs"]}</#if><#if rowColNode["@style"]?has_content> ${ec.resource.expand(rowColNode["@style"], "")}</#if>">
                <#recurse rowColNode>
            </div>
        </#list>
    </div>
</#macro>

<#macro "container-panel">
    <#assign panelId><@nodeId .node/></#assign>
    <#-- DEJ 24 Jan 2014: disabling dynamic panels for now, need to research with new Metis admin theme:
    <#if .node["@dynamic"]! == "true">
        <#assign afterScreenScript>
        $("#${panelId}").layout({
        defaults: { closable: true, resizable: true, slidable: false, livePaneResizing: true, spacing_open: 5 },
        <#if .node["panel-header"]?has_content><#assign panelNode = .node["panel-header"][0]>north: { showOverflowOnHover: true, closable: ${panelNode["@closable"]!"true"}, resizable: ${panelNode["@resizable"]!"false"}, spacing_open: ${panelNode["@spacing"]!"5"}, size: "${panelNode["@size"]!"auto"}"<#if panelNode["@size-min"]?has_content>, minSize: ${panelNode["@size-min"]}</#if><#if panelNode["@size-min"]?has_content>, maxSize: ${panelNode["@size-max"]}</#if> },</#if>
        <#if .node["panel-footer"]?has_content><#assign panelNode = .node["panel-footer"][0]>south: { showOverflowOnHover: true, closable: ${panelNode["@closable"]!"true"}, resizable: ${panelNode["@resizable"]!"false"}, spacing_open: ${panelNode["@spacing"]!"5"}, size: "${panelNode["@size"]!"auto"}"<#if panelNode["@size-min"]?has_content>, minSize: ${panelNode["@size-min"]}</#if><#if panelNode["@size-min"]?has_content>, maxSize: ${panelNode["@size-max"]}</#if> },</#if>
        <#if .node["panel-left"]?has_content><#assign panelNode = .node["panel-left"][0]>west: { closable: ${panelNode["@closable"]!"true"}, resizable: ${panelNode["@resizable"]!"true"}, spacing_open: ${panelNode["@spacing"]!"5"}, size: "${panelNode["@size"]!"180"}"<#if panelNode["@size-min"]?has_content>, minSize: ${panelNode["@size-min"]}</#if><#if panelNode["@size-min"]?has_content>, maxSize: ${panelNode["@size-max"]}</#if> },</#if>
        <#if .node["panel-right"]?has_content><#assign panelNode = .node["panel-right"][0]>east: { closable: ${panelNode["@closable"]!"true"}, resizable: ${panelNode["@resizable"]!"true"}, spacing_open: ${panelNode["@spacing"]!"5"}, size: "${panelNode["@size"]!"180"}"<#if panelNode["@size-min"]?has_content>, minSize: ${panelNode["@size-min"]}</#if><#if panelNode["@size-min"]?has_content>, maxSize: ${panelNode["@size-max"]}</#if> },</#if>
        center: { minWidth: 200 }
        });
        </#assign>
        <#t>${sri.appendToScriptWriter(afterScreenScript)}
        <div<#if panelId?has_content> id="${panelId}"</#if>>
            <#if .node["panel-header"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-header"</#if> class="ui-layout-north ui-helper-clearfix"><#recurse .node["panel-header"][0]>
                </div></#if>
            <#if .node["panel-left"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-left"</#if> class="ui-layout-west"><#recurse .node["panel-left"][0]>
                </div>
            </#if>
            <div<#if panelId?has_content> id="${panelId}-center"</#if> class="ui-layout-center"><#recurse .node["panel-center"][0]>
            </div>
            <#if .node["panel-right"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-right"</#if> class="ui-layout-east"><#recurse .node["panel-right"][0]>
                </div>
            </#if>
            <#if .node["panel-footer"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-footer"</#if> class="ui-layout-south"><#recurse .node["panel-footer"][0]>
                </div></#if>
        </div>
    <#else>
    -->
        <div<#if panelId?has_content> id="${panelId}"</#if> class="container-panel-outer">
            <#if .node["panel-header"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-header"</#if> class="container-panel-header"><#recurse .node["panel-header"][0]>
                </div>
            </#if>
            <div class="container-panel-middle">
                <#if .node["panel-left"]?has_content>
                    <div<#if panelId?has_content> id="${panelId}-left"</#if> class="container-panel-left" style="width: ${.node["panel-left"][0]["@size"]!"180"}px;"><#recurse .node["panel-left"][0]>
                    </div>
                </#if>
                <#assign centerClass><#if .node["panel-left"]?has_content><#if .node["panel-right"]?has_content>container-panel-center-both<#else>container-panel-center-left</#if><#else><#if .node["panel-right"]?has_content>container-panel-center-right<#else>container-panel-center-only</#if></#if></#assign>
                <div<#if panelId?has_content> id="${panelId}-center"</#if> class="${centerClass}"><#recurse .node["panel-center"][0]>
            </div>
            <#if .node["panel-right"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-right"</#if> class="container-panel-right" style="width: ${.node["panel-right"][0]["@size"]!"180"}px;"><#recurse .node["panel-right"][0]>
                </div>
            </#if>
            </div>
            <#if .node["panel-footer"]?has_content>
                <div<#if panelId?has_content> id="${panelId}-footer"</#if> class="container-panel-footer"><#recurse .node["panel-footer"][0]>
                </div>
            </#if>
        </div>
    <#-- </#if> -->
</#macro>

<#macro "container-dialog">
    <#assign buttonText = ec.resource.expand(.node["@button-text"], "")>
    <#assign buttonIcon = ec.resource.expand(.node["@button-icon"], "")>
    <#assign divId><@nodeId .node/></#assign>
    <button id="${divId}-button" type="button" data-toggle="modal" data-target="#${divId}" data-original-title="${buttonText}" data-placement="bottom" class="btn btn-primary btn-sm"><i class="<#if buttonIcon?? && buttonIcon != "">${buttonIcon}<#else>glyphicon glyphicon-share</#if>"></i> ${buttonText}</button>
    <#if _openDialog! == divId><#assign afterScreenScript>$('#${divId}').modal('show'); </#assign><#t>${sri.appendToScriptWriter(afterScreenScript)}</#if>
    <div id="${divId}" class="modal fade container-dialog" aria-hidden="true" style="display: none;">
        <div class="modal-dialog" style="width: ${.node["@width"]!"600"}px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${buttonText}</h4>
                </div>
                <div class="modal-body">
                    <#recurse>
                </div>
                <#-- <div class="modal-footer"><button type="button" class="btn btn-primary" data-dismiss="modal">Close</button></div> -->
            </div>
        </div>
    </div>
</#macro>

<#macro "dynamic-container">
    <#assign divId><@nodeId .node/></#assign>
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true").addParameter("_dynamic_container_id", divId)>
    <div id="${divId}"><img src="/images/wait_anim_16x16.gif" alt="Loading..."></div>
    <#assign afterScreenScript>
        function load${divId}() { $("#${divId}").load("${urlInstance.passThroughSpecialParameters().urlWithParams}", function() { <#-- activateAllButtons() --> }) }
        load${divId}();
    </#assign>
    <#t>${sri.appendToScriptWriter(afterScreenScript)}
</#macro>

<#macro "dynamic-dialog">
    <#assign buttonText = ec.resource.expand(.node["@button-text"], "")>
    <#assign buttonIcon = ec.resource.expand(.node["@button-icon"], "")>
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
    <#assign divId><@nodeId .node/></#assign>

    <button id="${divId}-button" type="button" data-toggle="modal" data-target="#${divId}" data-original-title="${buttonText}" data-placement="bottom" class="btn btn-primary btn-sm"><i class="<#if buttonIcon?? && buttonIcon != "">${buttonIcon}<#else>glyphicon glyphicon-share</#if>"></i> ${buttonText}</button>
    <div id="${divId}" class="modal fade dynamic-dialog" aria-hidden="true" style="display: none;">
        <div class="modal-dialog" style="width: ${.node["@width"]!"600"}px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${buttonText}</h4>
                </div>
                <div class="modal-body" id="${divId}-body">
                    <img src="/images/wait_anim_16x16.gif" alt="Loading...">
                </div>
                <#-- <div class="modal-footer"><button type="button" class="btn btn-primary" data-dismiss="modal">Close</button></div> -->
            </div>
        </div>
    </div>
    <script>$("#${divId}").on("show.bs.modal", function (e) { $("#${divId}-body").load('${urlInstance.urlWithParams}'); }); $("#${divId}").on("hidden.bs.modal", function (e) { $("#${divId}-body").empty(); $("#${divId}-body").append('<img src="/images/wait_anim_16x16.gif" alt="Loading...">'); });</script>
    <#if _openDialog! == divId><#assign afterScreenScript>$('#${divId}').modal('show')</#assign><#t>${sri.appendToScriptWriter(afterScreenScript)}</#if>
</#macro>

<#-- ==================== Includes ==================== -->
<#macro "include-screen">
<#if sri.doBoundaryComments()><!-- BEGIN include-screen[@location=${.node["@location"]}][@share-scope=${.node["@share-scope"]!}] --></#if>
${sri.renderIncludeScreen(.node["@location"], .node["@share-scope"]!)}
<#if sri.doBoundaryComments()><!-- END   include-screen[@location=${.node["@location"]}][@share-scope=${.node["@share-scope"]!}] --></#if>
</#macro>

<#-- ============== Tree ============== -->
<#macro tree>
    <#assign ajaxUrlInfo = sri.makeUrlByType(.node["@transition"]!"getTreeSubNodes", "transition", .node, "true")>
    <#assign ajaxParms = ajaxUrlInfo.getParameterMap()>

    <div id="${.node["@name"]}"></div>
    <script>
    $("#${.node["@name"]}").bind('select_node.jstree', function(e,data) {window.location.href = data.node.a_attr.href;}).jstree({
        "core" : { "themes" : { "url" : false, "dots" : true, "icons" : false }, "multiple" : false,
            'data' : {
                dataType: 'json', type: 'POST',
                url: function (node) { return '${ajaxUrlInfo.url}'; },
                data: function (node) { return { treeNodeId: node.id,
                    treeNodeName: (node.li_attr && node.li_attr.treeNodeName ? node.li_attr.treeNodeName : ''),
                    moquiSessionToken: "${(ec.web.sessionToken)!}"
                    <#if .node["@open-path"]??>, treeOpenPath: "${ec.resource.expand(.node["@open-path"], "")}"</#if>
                    <#list ajaxParms.keySet() as pKey>, "${pKey}": "${ajaxParms.get(pKey)!""}"</#list> }; }
            }
        }
    });
    </script>
</#macro>
<#macro "tree-node"><#-- shouldn't be called directly, but just in case --></#macro>
<#macro "tree-sub-node"><#-- shouldn't be called directly, but just in case --></#macro>

<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode"><#t>
<#if .node["text"]?has_content>
    <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#assign textToUse = textNode/></#if></#list>
    <#list .node["text"] as textNode><#if textNode["@type"]?has_content && textNode["@type"] == sri.getRenderMode()><#assign textToUse = textNode></#if></#list>
    <#if textToUse?exists>
        <#if textToUse["@location"]?has_content>
          <#assign textLocation = ec.resource.expand(textToUse["@location"], "")>
          <#t><#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]?if_exists != "true"><!-- BEGIN render-mode.text[@location=${textLocation}][@template=${textToUse["@template"]?default("true")}] --></#if>
          <#t><#-- NOTE: this still won't encode templates that are rendered to the writer -->
          <#t><#if .node["@encode"]!"false" == "true">${sri.renderText(textLocation, textToUse["@template"]!)?html}<#else>${sri.renderText(textLocation, textToUse["@template"]!)}</#if>
          <#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]?if_exists != "true"><!-- END   render-mode.text[@location=${textLocation}][@template=${textToUse["@template"]?default("true")}] --></#if>
        </#if>
        <#assign inlineTemplateSource = textToUse.@@text!/>
        <#if inlineTemplateSource?has_content>
          <#t><#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]?if_exists != "true"><!-- BEGIN render-mode.text[inline][@template=${textToUse["@template"]?default("true")}] --></#if>
          <#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
            <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
            <@inlineTemplate/>
          <#else>
            <#if .node["@encode"]!"false" == "true">${inlineTemplateSource?html}<#else>${inlineTemplateSource}</#if>
          </#if>
          <#t><#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]?if_exists != "true"><!-- END   render-mode.text[inline][@template=${textToUse["@template"]?default("true")}] --></#if>
        </#if>
    </#if>
</#if>
</#macro>

<#macro text><#-- do nothing, is used only through "render-mode" --></#macro>

<#-- ================== Standalone Fields ==================== -->
<#macro link>
    <#assign linkNode = .node>
    <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.resource.condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#if linkNode["@entity-name"]?has_content>
            <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
        <#else>
            <#assign textMap = "">
            <#if linkNode["@text-map"]?has_content><#assign textMap = ec.resource.expression(linkNode["@text-map"], "")!></#if>
            <#if textMap?has_content>
                <#assign linkText = ec.resource.expand(linkNode["@text"], "", textMap)>
            <#else>
                <#assign linkText = ec.resource.expand(linkNode["@text"]!"", "")>
            </#if>
        </#if>
        <#if !linkNode["@encode"]?has_content || linkNode["@encode"] == "true"><#assign linkText = linkText?html></#if>
        <#assign urlInstance = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
        <#assign divId><@nodeId .node/></#assign>
        <@linkFormForm linkNode divId linkText urlInstance/>
        <@linkFormLink linkNode divId linkText urlInstance/>
    </#if>
</#macro>
<#macro linkFormLink linkNode linkFormId linkText urlInstance>
    <#assign iconClass = linkNode["@icon"]!>
    <#if !iconClass?has_content && linkNode["@text"]?has_content><#assign iconClass = sri.getThemeIconClass(linkNode["@text"])!></#if>
    <#if urlInstance.disableLink>
        <a href="#"<#if linkFormId?has_content> id="${linkFormId}"</#if>class="disabled text-muted <#if linkNode["@link-type"]! != "anchor" && linkNode["@link-type"]! != "hidden-form-link">btn btn-primary btn-sm</#if><#if .node["@style"]?has_content> ${ec.resource.expand(.node["@style"], "")}</#if>"><#if iconClass?has_content><i class="${iconClass}"></i></#if><#if linkNode["image"]?has_content><#visit linkNode["image"][0]><#else>${linkText}</#if></a>
    <#else>
        <#assign confirmationMessage = ec.resource.expand(linkNode["@confirmation"]!, "")/>
        <#if (linkNode["@link-type"]! == "anchor" || linkNode["@link-type"]! == "anchor-button") ||
            ((!linkNode["@link-type"]?has_content || linkNode["@link-type"] == "auto") &&
             ((linkNode["@url-type"]?has_content && linkNode["@url-type"] != "transition") || (!urlInstance.hasActions)))>
            <#if linkNode["@dynamic-load-id"]?has_content>
                <#-- NOTE: the void(0) is needed for Firefox and other browsers that render the result of the JS expression -->
                <#assign urlText>javascript:{$('#${linkNode["@dynamic-load-id"]}').load('${urlInstance.urlWithParams}'); void(0);}</#assign>
            <#else>
                <#if linkNode["@url-noparam"]! == "true">
                    <#assign urlText = urlInstance.url/>
                <#else>
                    <#assign urlText = urlInstance.urlWithParams/>
                </#if>
            </#if>
            <a href="${urlText}"<#if linkFormId?has_content> id="${linkFormId}"</#if><#if linkNode["@target-window"]?has_content> target="${linkNode["@target-window"]}"</#if><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if> class="<#if linkNode["@link-type"]! != "anchor">btn btn-primary btn-sm</#if><#if linkNode["@style"]?has_content> ${ec.resource.expand(linkNode["@style"], "")}</#if>"<#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(linkNode["@tooltip"], "")}"</#if>><#if iconClass?has_content><i class="${iconClass}"></i></#if>
            <#t><#if linkNode["image"]?has_content><#visit linkNode["image"][0]><#else>${linkText}</#if>
            <#t></a>
        <#else>
            <#if linkFormId?has_content>
            <button type="submit" form="${linkFormId}"<#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if> class="btn btn-primary btn-sm<#if linkNode["@style"]?has_content> ${ec.resource.expand(linkNode["@style"], "")}</#if>"<#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(linkNode["@tooltip"], "")}"</#if>><#if iconClass?has_content><i class="${iconClass}"></i> </#if>
                <#if linkNode["image"]?has_content>
                    <#t><img src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if>/>
                <#else>
                    <#t>${linkText}
                </#if>
            </button>
            </#if>
        </#if>
    </#if>
</#macro>
<#macro linkFormForm linkNode linkFormId linkText urlInstance>
    <#if urlInstance.disableLink>
        <#-- do nothing -->
    <#else>
        <#if (linkNode["@link-type"]! == "anchor" || linkNode["@link-type"]! == "anchor-button") ||
            ((!linkNode["@link-type"]?has_content || linkNode["@link-type"] == "auto") &&
             ((linkNode["@url-type"]?has_content && linkNode["@url-type"] != "transition") || (!urlInstance.hasActions)))>
            <#-- do nothing -->
        <#else>
            <form method="post" action="${urlInstance.url}" name="${linkFormId!""}"<#if linkFormId?has_content> id="${linkFormId}"</#if><#if linkNode["@target-window"]?has_content> target="${linkNode["@target-window"]}"</#if>>
                <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
                <#assign targetParameters = urlInstance.getParameterMap()>
                <#-- NOTE: using .keySet() here instead of ?keys because ?keys was returning all method names with the other keys, not sure why -->
                <#if targetParameters?has_content><#list targetParameters.keySet() as pKey>
                    <input type="hidden" name="${pKey?html}" value="${targetParameters.get(pKey)?default("")?html}"/>
                </#list></#if>
                <#if !linkFormId?has_content>
                    <#assign confirmationMessage = ec.resource.expand(linkNode["@confirmation"]!, "")/>
                    <#if linkNode["image"]?has_content><#assign imageNode = linkNode["image"][0]/>
                        <input type="image" src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if>>
                    <#else>
                        <#assign iconClass = linkNode["@icon"]!>
                        <#if !iconClass?has_content && linkNode["@text"]?has_content><#assign iconClass = sri.getThemeIconClass(linkNode["@text"])!></#if>
                        <button type="submit"<#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if> class="<#if linkNode["@link-type"]! == "hidden-form-link">button-plain<#else>btn btn-primary btn-sm</#if><#if .node["@style"]?has_content> ${ec.resource.expand(.node["@style"], "")}</#if>"<#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(linkNode["@tooltip"], "")}"</#if>><#if iconClass?has_content><i class="${iconClass}"></i> </#if>${linkText}</button>
                    </#if>
                </#if>
            </form>
        </#if>
    </#if>
</#macro>

<#macro image>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.resource.condition(.node["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult><img src="${sri.makeUrlByType(.node["@url"], .node["@url-type"]!"content", .node, "true").getUrlWithParams()}" alt="${.node["@alt"]!"image"}"<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if><#if .node["@width"]?has_content> width="${.node["@width"]}"</#if><#if .node["@height"]?has_content> height="${.node["@height"]}"</#if><#if .node["@style"]?has_content> class="${ec.resource.expand(.node["@style"], "")}"</#if>/></#if>
</#macro>
<#macro label>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.resource.condition(.node["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#assign labelType = .node["@type"]?default("span")/>
        <#assign textMap = "">
        <#if .node["@text-map"]?has_content><#assign textMap = ec.resource.expression(.node["@text-map"], "")!></#if>
        <#if textMap?has_content>
            <#assign labelValue = ec.resource.expand(.node["@text"], "", textMap)>
        <#else>
            <#assign labelValue = ec.resource.expand(.node["@text"], "")/>
        </#if>
        <#assign divId><@nodeId .node/></#assign>
        <#if labelValue?trim?has_content>
        <${labelType}<#if divId?has_content> id="${divId}"</#if><#if .node["@style"]?has_content> class="${ec.resource.expand(.node["@style"], "")}"</#if>><#if !.node["@encode"]?has_content || .node["@encode"] == "true">${labelValue?html?replace("\n", "<br>")}<#else>${labelValue}</#if></${labelType}>
        </#if>
    </#if>
</#macro>
<#macro editable>
    <#-- for docs on JS usage see: http://www.appelsiini.net/projects/jeditable -->
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
    <#assign urlParms = urlInstance.getParameterMap()>
    <#assign divId><@nodeId .node/></#assign>
    <#assign labelType = .node["@type"]?default("span")>
    <#assign labelValue = ec.resource.expand(.node["@text"], "")>
    <#assign parameterName = .node["@parameter-name"]!"value">
    <#if labelValue?trim?has_content>
        <${labelType} id="${divId}" class="editable-label"><#if .node["@encode"]! == "true">${labelValue?html?replace("\n", "<br>")}<#else>${labelValue}</#if></${labelType}>
        <#assign afterScreenScript>
        $("#${divId}").editable("${urlInstance.url}", { indicator:"${ec.l10n.localize("Saving")}",
            tooltip:"${ec.l10n.localize("Click to edit")}", cancel:"${ec.l10n.localize("Cancel")}",
            submit:"${ec.l10n.localize("Save")}", name:"${parameterName}",
            type:"${.node["@widget-type"]!"textarea"}", cssclass:"editable-form",
            submitdata:{<#list urlParms.keySet() as parameterKey>${parameterKey}:"${urlParms[parameterKey]}", </#list>parameterName:"${parameterName}", moquiSessionToken:"${(ec.web.sessionToken)!}"}
            <#if .node["editable-load"]?has_content>
                <#assign loadNode = .node["editable-load"][0]>
                <#assign loadUrlInfo = sri.makeUrlByType(loadNode["@transition"], "transition", loadNode, "true")>
                <#assign loadUrlParms = loadUrlInfo.getParameterMap()>
            , loadurl:"${loadUrlInfo.url}", loadtype:"POST", loaddata:function(value, settings) { return {<#list loadUrlParms.keySet() as parameterKey>${parameterKey}:"${loadUrlParms[parameterKey]}", </#list>currentValue:value, moquiSessionToken:"${(ec.web.sessionToken)!}"}; }
            </#if>});
        </#assign>
        <#t>${sri.appendToScriptWriter(afterScreenScript)}
    </#if>
</#macro>
<#macro parameter><#-- do nothing, used directly in other elements --></#macro>

<#-- ====================================================== -->
<#-- ======================= Form ========================= -->
<#macro "form-single">
<#if sri.doBoundaryComments()><!-- BEGIN form-single[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formNode = sri.getFtlFormNode(.node["@name"])>
    ${sri.pushSingleFormMapContext(formNode)}
    <#assign skipStart = (formNode["@skip-start"]! == "true")>
    <#assign skipEnd = (formNode["@skip-end"]! == "true")>
    <#assign urlInstance = sri.makeUrlByType(formNode["@transition"], "transition", null, "true")>
    <#assign formId>${ec.resource.expand(formNode["@name"], "")}<#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#assign>
    <#assign inFieldRow = false>
    <#assign bigRow = false>
    <#if !skipStart>
    <form name="${formId}" id="${formId}" class="validation-engine-init" method="post" action="${urlInstance.url}"<#if sri.isFormUpload(formNode["@name"])> enctype="multipart/form-data"</#if>>
        <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
        <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
    </#if>
        <fieldset class="form-horizontal"><#-- was form-single-outer -->
    <#if formNode["field-layout"]?has_content>
        <#assign fieldLayout = formNode["field-layout"][0]>
            <#assign accordionId = fieldLayout["@id"]?default(formId + "-accordion")>
            <#assign collapsible = (fieldLayout["@collapsible"]! == "true")>
            <#assign active = fieldLayout["@active"]!>
            <#assign collapsibleOpened = false>
            <#list formNode["field-layout"][0]?children as layoutNode>
                <#if layoutNode?node_name == "field-ref">
                  <#if collapsibleOpened>
                    <#assign collapsibleOpened = false>
                    </div><!-- /collapsible accordionId ${accordionId} -->
                    <#assign afterFormScript>
                        $("#${accordionId}").accordion({ collapsible: true,<#if active?has_content> active: ${active},</#if> heightStyle: "content" });
                    </#assign>
                    <#t>${sri.appendToScriptWriter(afterFormScript)}
                    <#assign accordionId = accordionId + "_A"><#-- set this just in case another accordion is opened -->
                  </#if>
                    <#assign fieldRef = layoutNode["@name"]>
                    <#assign fieldNode = "invalid">
                    <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
                    <#if fieldNode == "invalid">
                        <div>Error: could not find field with name [${fieldRef}] referred to in a field-ref.@name attribute.</div>
                    <#else>
                        <@formSingleSubField fieldNode/>
                    </#if>
                <#elseif layoutNode?node_name == "fields-not-referenced">
                    <#assign nonReferencedFieldList = sri.getFtlFormFieldLayoutNonReferencedFieldList(.node["@name"])>
                    <#list nonReferencedFieldList as nonReferencedField><@formSingleSubField nonReferencedField/></#list>
                <#elseif layoutNode?node_name == "field-row">
                  <#if collapsibleOpened>
                    <#assign collapsibleOpened = false>
                    </div><!-- /collapsible accordionId ${accordionId} -->
                    <#assign afterFormScript>
                        $("#${accordionId}").accordion({ collapsible: true,<#if active?has_content> active: ${active},</#if> heightStyle: "content" });
                    </#assign>
                    <#t>${sri.appendToScriptWriter(afterFormScript)}
                    <#assign accordionId = accordionId + "_A"><#-- set this just in case another accordion is opened -->
                  </#if>
                    <div class="row">
                    <#assign inFieldRow = true>
                    <#list layoutNode?children as rowChildNode>
                        <#if rowChildNode?node_name == "field-ref">
                            <div class="col-md-6">
                                <#assign fieldRef = rowChildNode["@name"]>
                                <#assign fieldNode = "invalid">
                                <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
                                <#if fieldNode == "invalid">
                                    <div>Error: could not find field with name [${fieldRef}] referred to in a field-ref.@name attribute.</div>
                                <#else>
                                    <@formSingleSubField fieldNode/>
                                </#if>
                            </div><!-- /col-md-6 not bigRow -->
                        <#elseif rowChildNode?node_name == "fields-not-referenced">
                            <#assign nonReferencedFieldList = sri.getFtlFormFieldLayoutNonReferencedFieldList(.node["@name"])>
                            <#list nonReferencedFieldList as nonReferencedField><@formSingleSubField nonReferencedField/></#list>
                        </#if>
                    </#list>
                    <#assign inFieldRow = false>
                    </div><#-- /row -->
                <#elseif layoutNode?node_name == "field-row-big">
                    <#if collapsibleOpened>
                        <#assign collapsibleOpened = false>
                    </div><!-- /collapsible accordionId ${accordionId} -->
                        <#assign afterFormScript>
                            $("#${accordionId}").accordion({ collapsible: true,<#if active?has_content> active: ${active},</#if> heightStyle: "content" });
                        </#assign>
                        <#t>${sri.appendToScriptWriter(afterFormScript)}
                        <#assign accordionId = accordionId + "_A"><#-- set this just in case another accordion is opened -->
                    </#if>
                    <#assign inFieldRow = true>
                    <#assign bigRow = true>
                    <#-- funny assign here to not render row if there is no content -->
                    <#assign rowContent>
                        <#list layoutNode?children as rowChildNode>
                            <#if rowChildNode?node_name == "field-ref">
                                <#assign fieldRef = rowChildNode["@name"]>
                                <#assign fieldNode = "invalid">
                                <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
                                <#if fieldNode == "invalid">
                                    <div>Error: could not find field with name [${fieldRef}] referred to in a field-ref.@name attribute.</div>
                                <#else>
                                    <@formSingleSubField fieldNode/>
                                </#if>
                            <#elseif rowChildNode?node_name == "fields-not-referenced">
                                <#assign nonReferencedFieldList = sri.getFtlFormFieldLayoutNonReferencedFieldList(.node["@name"])>
                                <#list nonReferencedFieldList as nonReferencedField><@formSingleSubField nonReferencedField/></#list>
                            </#if>
                        </#list>
                    </#assign>
                    <#assign rowContent = rowContent?trim>
                    <#if rowContent?has_content>
                    <div class="form-group">
                        <#if layoutNode["@title"]?has_content>
                        <label class="control-label col-md-2">${ec.resource.expand(layoutNode["@title"], "")}</label>
                        <div class="col-md-10">
                        <#else>
                        <div class="col-md-12">
                        </#if>
                            ${rowContent}
                        </div><#-- /col-md-12 bigRow -->
                    </div><#-- /row -->
                    </#if>
                    <#assign bigRow = false>
                    <#assign inFieldRow = false>
                <#elseif layoutNode?node_name == "field-group">
                  <#if collapsible && !collapsibleOpened><#assign collapsibleOpened = true>
                    <div id="${accordionId}">
                  </#if>
                    <h3><a href="#">${ec.l10n.localize(layoutNode["@title"]?default("Section " + layoutNode_index))}</a></h3>
                    <div<#if layoutNode["@style"]?has_content> class="${layoutNode["@style"]}"</#if>>
                        <#list layoutNode?children as groupNode>
                            <#if groupNode?node_name == "field-ref">
                                <#assign fieldRef = groupNode["@name"]>
                                <#assign fieldNode = "invalid">
                                <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
                                <#if fieldNode == "invalid">
                                    <div>Error: could not find field with name [${fieldRef}] referred to in a field-ref.@name attribute.</div>
                                <#else>
                                    <@formSingleSubField fieldNode/>
                                </#if>
                            <#elseif groupNode?node_name == "fields-not-referenced">
                                <#assign nonReferencedFieldList = sri.getFtlFormFieldLayoutNonReferencedFieldList(.node["@name"])>
                                <#list nonReferencedFieldList as nonReferencedField><@formSingleSubField nonReferencedField/></#list>
                            <#elseif groupNode?node_name == "field-row">
                                <div class="row">
                                <#assign inFieldRow = true>
                                <#list groupNode?children as rowChildNode>
                                    <#if rowChildNode?node_name == "field-ref">
                                        <div class="col-md-6">
                                            <#assign fieldRef = rowChildNode["@name"]>
                                            <#assign fieldNode = "invalid">
                                            <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
                                            <#if fieldNode == "invalid">
                                                <div>Error: could not find field with name [${fieldRef}] referred to in a field-ref.@name attribute.</div>
                                            <#else>
                                                <@formSingleSubField fieldNode/>
                                            </#if>
                                        </div><#-- /col-md-6 not bigRow -->
                                    <#elseif rowChildNode?node_name == "fields-not-referenced">
                                        <#assign nonReferencedFieldList = sri.getFtlFormFieldLayoutNonReferencedFieldList(.node["@name"])>
                                        <#list nonReferencedFieldList as nonReferencedField><@formSingleSubField nonReferencedField/></#list>
                                    </#if>
                                </#list>
                                <#assign inFieldRow = false>
                                </div><#-- /row -->
                            </#if>
                        </#list>
                    </div><#-- /layoutNode -->
                </#if>
            </#list>
            <#if collapsibleOpened>
                </div><!-- /accordion id ${accordionId} -->
                <#assign afterFormScript>
                    $("#${accordionId}").accordion({ collapsible: true,<#if active?has_content> active: ${active},</#if> heightStyle: "content" });
                </#assign>
                <#t>${sri.appendToScriptWriter(afterFormScript)}
            </#if>
    <#else>
        <#list formNode["field"] as fieldNode><@formSingleSubField fieldNode/></#list>
    </#if>
        </fieldset>
    <#if !skipEnd></form></#if>
    <#if !skipStart>
        <#assign afterFormScript>
            $("#${formId}").validate({ errorClass: 'help-block', errorElement: 'span',
                highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
            });
            <#-- TODO init tooltips
            $(document).tooltip();
            -->

            <#-- if background-submit=true init ajaxForm; for examples see http://www.malsup.com/jquery/form/#ajaxForm -->
            <#if formNode["@background-submit"]! == "true">
            function backgroundSuccess${formId}(responseText, statusText, xhr, $form) {
                <#if formNode["@background-reload-id"]?has_content>
                    load${formNode["@background-reload-id"]}();
                </#if>
                <#if formNode["@background-message"]?has_content>
                <#-- TODO: do something much fancier than a dumb alert box -->
                    alert("${formNode["@background-message"]}");
                </#if>
                <#if formNode["@background-hide-id"]?has_content>
                    $('#${formNode["@background-hide-id"]}').modal('hide');
                </#if>
            }
            $("#${formId}").ajaxForm({ success: backgroundSuccess${formId}, resetForm: false });
            </#if>
        </#assign>
        <#t>${sri.appendToScriptWriter(afterFormScript)}
    </#if>
    <#if formNode["@focus-field"]?has_content>
        <#assign afterFormScript>
            $("#${formId}_${formNode["@focus-field"]}").focus();
        </#assign>
        <#t>${sri.appendToScriptWriter(afterFormScript)}
    </#if>
    <#t>${sri.popContext()}<#-- context was pushed for the form-single so pop here at the end -->
    <#if sri.doBoundaryComments()><!-- END   form-single[@name=${.node["@name"]}] --></#if>
</#macro>
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
    <#assign fieldSubParent = fieldSubNode?parent>
    <#if fieldSubNode["ignored"]?has_content><#return></#if>
    <#if ec.resource.condition(fieldSubParent["@hide"]!, "")><#return></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return></#if>
    <#assign containerStyle = ec.resource.expand(fieldSubNode["@container-style"]!, "")>
    <#assign curFieldTitle><@fieldTitle fieldSubNode/></#assign>
    <#if bigRow>
        <div class="big-row-item">
            <div class="form-group">
                <#if curFieldTitle?has_content && !fieldSubNode["submit"]?has_content>
                    <label class="control-label" for="${formId}_${fieldSubParent["@name"]}">${curFieldTitle}</label><#-- was form-title -->
                </#if>
    <#else>
        <#if fieldSubNode["submit"]?has_content>
        <div class="form-group"><#-- was single-form-field -->
            <div class="<#if inFieldRow>col-md-4<#else>col-md-2</#if>"> </div>
            <div class="<#if inFieldRow>col-md-8<#else>col-md-10</#if><#if containerStyle?has_content> ${containerStyle}</#if>">
        <#elseif !(inFieldRow! && !curFieldTitle?has_content)>
        <div class="form-group"><#-- was single-form-field -->
            <label class="control-label <#if inFieldRow>col-md-4<#else>col-md-2</#if>" for="${formId}_${fieldSubParent["@name"]}">${curFieldTitle}</label><#-- was form-title -->
            <div class="<#if inFieldRow>col-md-8<#else>col-md-10</#if><#if containerStyle?has_content> ${containerStyle}</#if>">
        </#if>
    </#if>
    <#-- NOTE: this style is only good for 2 fields in a field-row! in field-row cols are double size because are inside a col-md-6 element -->
    ${sri.pushContext()}
    <#list fieldSubNode?children as widgetNode><#if widgetNode?node_name == "set">${sri.setInContext(widgetNode)}</#if></#list>
    <#list fieldSubNode?children as widgetNode>
        <#if widgetNode?node_name == "link">
            <#assign linkNode = widgetNode>
            <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.resource.condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
            <#if conditionResult>
                <#if linkNode["@entity-name"]?has_content>
                    <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
                <#else>
                    <#assign textMap = "">
                    <#if linkNode["@text-map"]?has_content><#assign textMap = ec.resource.expression(linkNode["@text-map"], "")!></#if>
                    <#if textMap?has_content>
                        <#assign linkText = ec.resource.expand(linkNode["@text"], "", textMap)>
                    <#else>
                        <#assign linkText = ec.resource.expand(linkNode["@text"]!"", "")>
                    </#if>
                </#if>
                <#if !linkNode["@encode"]?has_content || linkNode["@encode"] == "true"><#assign linkText = linkText?html></#if>
                <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
                <#assign linkFormId><@fieldId linkNode/></#assign>
                <#assign afterFormText><@linkFormForm linkNode linkFormId linkText linkUrlInfo/></#assign>
                <#t>${sri.appendToAfterScreenWriter(afterFormText)}
                <#t><@linkFormLink linkNode linkFormId linkText linkUrlInfo/>
            </#if>
        <#elseif widgetNode?node_name == "set"><#-- do nothing, handled above -->
        <#else><#t><#visit widgetNode>
        </#if>
    </#list>
    ${sri.popContext()}
    <#if bigRow>
        <#if curFieldTitle?has_content>
        </#if>
            </div><!-- /form-group -->
        </div><!-- /field-row-item -->
    <#else>
        <#if fieldSubNode["submit"]?has_content>
            </div><!-- /col -->
        </div><!-- /form-group -->
        <#elseif !(inFieldRow! && !curFieldTitle?has_content)>
            </div><!-- /col -->
        </div><!-- /form-group -->
        </#if>
    </#if>
</#macro>

<#macro "form-list">
<#if sri.doBoundaryComments()><!-- BEGIN form-list[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formNode = sri.getFtlFormNode(.node["@name"])>
    <#assign formId>${ec.resource.expand(formNode["@name"], "")}<#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#assign>
    <#assign isMulti = formNode["@multi"]! == "true">
    <#assign isMultiFinalRow = false>
    <#assign skipStart = (formNode["@skip-start"]! == "true")>
    <#assign skipEnd = (formNode["@skip-end"]! == "true")>
    <#assign skipForm = (formNode["@skip-form"]! == "true")>
    <#assign skipHeader = (formNode["@skip-header"]! == "true")>
    <#assign formListUrlInfo = sri.makeUrlByType(formNode["@transition"], "transition", null, "false")>
    <#assign listName = formNode["@list"]>
    <#assign listObject = ec.resource.expression(listName, "")!>
    <#assign formListColumnList = formNode["form-list-column"]!>
    <#if !(formNode["@paginate"]! == "false") && context[listName + "Count"]?exists &&
            (context[listName + "Count"]! > 0) &&
            (!formNode["@paginate-always-show"]?has_content || formNode["@paginate-always-show"]! == "true" || (context[listName + "PageMaxIndex"] > 0))>
        <#assign curPageIndex = context[listName + "PageIndex"]>
        <#assign curPageMaxIndex = context[listName + "PageMaxIndex"]>
        <#assign prevPageIndexMin = curPageIndex - 3><#if (prevPageIndexMin < 0)><#assign prevPageIndexMin = 0></#if>
        <#assign prevPageIndexMax = curPageIndex - 1>
        <#assign nextPageIndexMin = curPageIndex + 1>
        <#assign nextPageIndexMax = curPageIndex + 3><#if (nextPageIndexMax > curPageMaxIndex)><#assign nextPageIndexMax = curPageMaxIndex></#if>
        <nav>
            <ul class="pagination">
            <#if (curPageIndex > 0)>
                <#assign firstUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", 0)>
                <#assign previousUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", (curPageIndex - 1))>
                <li><a href="${firstUrlInfo.getUrlWithParams()}"><i class="glyphicon glyphicon-fast-backward"></i></a></li>
                <li><a href="${previousUrlInfo.getUrlWithParams()}"><i class="glyphicon glyphicon-backward"></i></a></li>
            <#else>
                <li><span><i class="glyphicon glyphicon-fast-backward"></i></span></li>
                <li><span><i class="glyphicon glyphicon-backward"></i></span></li>
            </#if>

            <#if (prevPageIndexMax >= 0)><#list prevPageIndexMin..prevPageIndexMax as pageLinkIndex>
                <#assign pageLinkUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", pageLinkIndex)>
                <li><a href="${pageLinkUrlInfo.getUrlWithParams()}">${pageLinkIndex + 1}</a></li>
            </#list></#if>
            <#assign paginationTemplate = ec.l10n.localize("PaginationTemplate")?interpret>
            <li><a href="${sri.getScreenUrlInstance().getUrlWithParams()}"><@paginationTemplate /></a></li>

            <#if (nextPageIndexMin <= curPageMaxIndex)><#list nextPageIndexMin..nextPageIndexMax as pageLinkIndex>
                <#assign pageLinkUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", pageLinkIndex)>
                <li><a href="${pageLinkUrlInfo.getUrlWithParams()}">${pageLinkIndex + 1}</a></li>
            </#list></#if>

            <#if (curPageIndex < curPageMaxIndex)>
                <#assign lastUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", curPageMaxIndex)>
                <#assign nextUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageIndex", curPageIndex + 1)>
                <li><a href="${nextUrlInfo.getUrlWithParams()}"><i class="glyphicon glyphicon-forward"></i></a></li>
                <li><a href="${lastUrlInfo.getUrlWithParams()}"><i class="glyphicon glyphicon-fast-forward"></i></a></li>
            <#else>
                <li><span><i class="glyphicon glyphicon-forward"></i></span></li>
                <li><span><i class="glyphicon glyphicon-fast-forward"></i></span></li>
            </#if>
            </ul>
            <#if (curPageMaxIndex > 4)>
                <form class="form-inline" id="${formId}_GoPage" target="${sri.getScreenUrlInstance().cloneUrlInstance().removeParameter("pageIndex").getUrlWithParams()}">
                    <div class="form-group">
                        <label class="sr-only" for="${formId}_GoPage_pageIndex">Page number</label>
                        <input type="text" class="form-control" size="4" name="pageIndex" id="${formId}_GoPage_pageIndex" placeholder="${ec.l10n.localize("Page #")}">
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">${ec.l10n.localize("Go##Page")}</button>
                </form>
                <script>
                    $("#${formId}_GoPage").validate({ errorClass: 'help-block', errorElement: 'span',
                        rules: { pageIndex: { required:true, min:1, max:${curPageMaxIndex + 1} } },
                        highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                        unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); },
                        <#-- show 1-based index to user but server expects 0-based index -->
                        submitHandler: function(form) { $("#${formId}_GoPage_pageIndex").val($("#${formId}_GoPage_pageIndex").val() - 1); form.submit(); }
                    });
                </script>
            </#if>
        </nav>
    </#if>
    <#if formListColumnList?? && (formListColumnList?size > 0)>
        <#if !skipStart>
        <table class="table table-striped table-hover table-condensed" id="${formId}-table">
            <#if !skipHeader>
            <thead>
                <#assign needHeaderForm = sri.isFormHeaderForm(formNode["@name"])>
                <#if needHeaderForm>
                    <#assign curUrlInstance = sri.getCurrentScreenUrl()>
                    <#assign headerFormId>${formId}-header</#assign>
                <tr>
                <form name="${headerFormId}" id="${headerFormId}" method="post" action="${curUrlInstance.url}">
                    <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
                    <#if orderByField?has_content><input type="hidden" name="orderByField" value="${orderByField}"></#if>
                    <#assign nonReferencedFieldList = sri.getFtlFormListColumnNonReferencedHiddenFieldList(.node["@name"])>
                    <#list nonReferencedFieldList as nonReferencedField><#if nonReferencedField["header-field"]?has_content><#recurse nonReferencedField["header-field"][0]/></#if></#list>
                <#else>
                <tr>
                </#if>
                    <#list formListColumnList as fieldListColumn>
                        <th<#if fieldListColumn["@style"]?has_content> class="${fieldListColumn["@style"]}"</#if>>
                        <#list fieldListColumn["field-ref"] as fieldRef>
                            <#assign fieldRefName = fieldRef["@name"]>
                            <#assign fieldNode = "invalid">
                            <#list formNode["field"] as fn><#if fn["@name"] == fieldRefName><#assign fieldNode = fn><#break></#if></#list>
                            <#if fieldNode == "invalid">
                                <div>Error: could not find field with name [${fieldRefName}] referred to in a form-list-column.field-ref.@name attribute.</div>
                            <#else>
                                <#if !(ec.resource.condition(fieldNode["@hide"]!, "") ||
                                        ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                        (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
                                    <div><@formListHeaderField fieldNode/></div>
                                </#if>
                            </#if>
                        </#list>
                        </th>
                    </#list>
                <#if needHeaderForm>
                </form>
                </tr>
                    <#if _dynamic_container_id?has_content>
                        <#-- if we have an _dynamic_container_id this was loaded in a dynamic-container so init ajaxForm; for examples see http://www.malsup.com/jquery/form/#ajaxForm -->
                        <#assign afterFormScript>
                            $("#${headerFormId}").ajaxForm({ target: '#${_dynamic_container_id}', <#-- success: activateAllButtons, --> resetForm: false });
                        </#assign>
                        <#t>${sri.appendToScriptWriter(afterFormScript)}
                    </#if>
                <#else>
                </tr>
                </#if>
            </thead>
            </#if>
            <#if isMulti && !skipForm>
                <tbody>
                <form name="${formId}" id="${formId}" method="post" action="${formListUrlInfo.url}">
                    <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
                    <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
                    <input type="hidden" name="_isMulti" value="true">
            <#else>
                <tbody>
            </#if>
        </#if>
        <#list listObject! as listEntry>
            <#assign listEntryIndex = listEntry_index>
            <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
            ${sri.startFormListRow(formNode["@name"], listEntry, listEntry_index, listEntry_has_next)}
            <#if isMulti || skipForm>
            <tr>
            <#else>
            <tr>
            <form name="${formId}_${listEntryIndex}" id="${formId}_${listEntryIndex}" method="post" action="${formListUrlInfo.url}">
                <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
            </#if>
            <#assign nonReferencedFieldList = sri.getFtlFormListColumnNonReferencedHiddenFieldList(.node["@name"])>
            <#list nonReferencedFieldList as nonReferencedField><@formListSubField nonReferencedField/></#list>
            <#list formListColumnList as fieldListColumn>
                <td<#if fieldListColumn["@style"]?has_content> class="${fieldListColumn["@style"]}"</#if>>
                <#list fieldListColumn["field-ref"] as fieldRef>
                    <#assign fieldRefName = fieldRef["@name"]>
                    <#assign fieldNode = "invalid">
                    <#list formNode["field"] as fn><#if fn["@name"] == fieldRefName><#assign fieldNode = fn><#break></#if></#list>
                    <#if fieldNode == "invalid">
                        <td><div>Error: could not find field with name [${fieldRefName}] referred to in a form-list-column.field-ref.@name attribute.</div></td>
                    <#else>
                        <@formListSubField fieldNode true/>
                    </#if>
                </#list>
                </td>
            </#list>
            <#if isMulti || skipForm>
            </tr>
            <#else>
                <#assign afterFormScript>
                    $("#${formId}_${listEntryIndex}").validate();
                </#assign>
                <#t>${sri.appendToScriptWriter(afterFormScript)}
            </form>
            </tr>
            </#if>
            ${sri.endFormListRow()}
        </#list>
        <#assign listEntryIndex = "">
        ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
        <#if !skipEnd>
            <#if isMulti && !skipForm>
                <tr><td colspan="${formListColumnList?size}">
                    <#assign isMultiFinalRow = true>
                    <#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
                </td></tr>
                </form>
                </tbody>
            <#else>
                </tbody>
            </#if>
            </table>
        </#if>
        <#if isMulti && !skipStart && !skipForm>
            <#assign afterFormScript>
                $("#${formId}").validate();
                <#-- TODO $(document).tooltip(); -->
            </#assign>
            <#t>${sri.appendToScriptWriter(afterFormScript)}
        </#if>
    <#else>
        <#assign fieldNodeList = formNode["field"]>
        <#if !skipStart>
        <table class="table table-striped table-hover table-condensed" id="${formId}-table">
            <#if !skipHeader>
            <thead>
                <#assign needHeaderForm = sri.isFormHeaderForm(formNode["@name"])>
                <#if needHeaderForm && !skipStart>
                    <#assign curUrlInfo = sri.getCurrentScreenUrl()>
                    <tr>
                    <form name="${formId}-header" id="${formId}-header" class="form-header-row" method="post" action="${curUrlInfo.url}">
                        <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
                        <#if orderByField?has_content><input type="hidden" name="orderByField" value="${orderByField}"></#if>
                <#else>
                    <tr>
                </#if>
                    <#list fieldNodeList as fieldNode>
                        <#assign allHidden = true>
                        <#assign hasSubmit = false>
                        <#list fieldNode?children as fieldSubNode>
                            <#if !(fieldSubNode["hidden"]?has_content || fieldSubNode["ignored"]?has_content)><#assign allHidden = false></#if>
                            <#if fieldSubNode?node_name != "header-field" && fieldSubNode["submit"]?has_content><#assign hasSubmit = true></#if>
                        </#list>
                        <#if !(ec.resource.condition(fieldNode["@hide"]!, "") || allHidden ||
                                ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                (fieldNode["header-field"][0]?if_exists["hidden"]?has_content || fieldNode["header-field"][0]?if_exists["ignored"]?has_content))) &&
                                !(isMulti && hasSubmit)>
                            <th>
                                <@formListHeaderField fieldNode/>
                            </th>
                        <#elseif fieldNode["header-field"][0]?if_exists["hidden"]?has_content>
                            <#recurse fieldNode["header-field"][0]/>
                        </#if>
                    </#list>
                <#if needHeaderForm && !skipStart>
                    </form>
                    </tr>
                <#else>
                    </tr>
                </#if>
            </thead>
            </#if>
            <#if isMulti && !skipForm>
                <tbody>
                <form name="${formId}" id="${formId}" class="form-body" method="post" action="${formListUrlInfo.url}">
                    <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
                    <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
                    <input type="hidden" name="_isMulti" value="true">
            <#else>
                <tbody>
            </#if>
        </#if>
        <#list listObject! as listEntry>
            <#assign listEntryIndex = listEntry_index>
            <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
            ${sri.startFormListRow(formNode["@name"], listEntry, listEntry_index, listEntry_has_next)}
            <#if isMulti || skipForm>
                <tr>
            <#else>
                <tr>
                <form name="${formId}_${listEntryIndex}" id="${formId}_${listEntryIndex}" method="post" action="${formListUrlInfo.url}">
                    <input type="hidden" name="moquiSessionToken" value="${(ec.web.sessionToken)!}">
            </#if>
                <#list fieldNodeList as fieldNode><@formListSubField fieldNode/></#list>
            <#if isMulti || skipForm>
                </tr>
            <#else>
                <#assign afterFormScript>
                    $("#${formId}_${listEntryIndex}").validate();
                </#assign>
                <#t>${sri.appendToScriptWriter(afterFormScript)}
                </form>
                </tr>
            </#if>
            ${sri.endFormListRow()}
        </#list>
        <#assign listEntryIndex = "">
        ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
        <#if !skipEnd>
            <#if isMulti && !skipForm>
                <tr><td colspan="${fieldNodeList?size}">
                    <#assign isMultiFinalRow = true>
                    <#list fieldNodeList as fieldNode><@formListSubField fieldNode/></#list>
                </td></tr>
                </form>
                </tbody>
            <#else>
                </tbody>
            </#if>
            </table>
        </#if>
        <#if isMulti && !skipStart && !skipForm>
            <#assign afterFormScript>
                $("#${formId}").validate();
                <#-- TODO $(document).tooltip(); -->
            </#assign>
            <#t>${sri.appendToScriptWriter(afterFormScript)}
        </#if>
    </#if>
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
    <#assign headerFieldNode = fieldNode["header-field"][0]!>
    <#assign defaultFieldNode = fieldNode["default-field"][0]!>
    <#assign containerStyle = ec.resource.expand(headerFieldNode["@container-style"]!, "")>
    <div class="form-title<#if containerStyle?has_content> ${containerStyle}</#if>">
        <#if fieldSubNode["submit"]?has_content>&nbsp;<#else><#if headerFieldNode["@title"]?has_content><@fieldTitle headerFieldNode/><#elseif defaultFieldNode["@title"]?has_content><@fieldTitle defaultFieldNode/><#else><@fieldTitle fieldSubNode/></#if></#if>
        <#if fieldSubNode["@show-order-by"]! == "true" || fieldSubNode["@show-order-by"]! == "case-insensitive">
            <#assign caseInsensitive = fieldSubNode["@show-order-by"]! == "case-insensitive">
            <#assign orderByField = ec.context.orderByField!>
            <#if orderByField?has_content && orderByField?contains(",")>
                <#list (orderByField?split(","))! as orderByFieldCandidate>
                    <#if orderByFieldCandidate?has_content && orderByFieldCandidate?contains(fieldNode["@name"])>
                        <#assign orderByField = orderByFieldCandidate>
                        <#break>
                    </#if>
                </#list>
            </#if>
            <#assign ascActive = orderByField?has_content && orderByField?contains(fieldNode["@name"]) && !orderByField?starts_with("-")>
            <#assign descActive = orderByField?has_content && orderByField?contains(fieldNode["@name"]) && orderByField?starts_with("-")>
            <#assign ascOrderByUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("orderByField", "+" + caseInsensitive?string("^","") + fieldNode["@name"])>
            <#assign descOrderByUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("orderByField", "-" + caseInsensitive?string("^","") + fieldNode["@name"])>
            <#if ascActive><#assign ascOrderByUrlInfo = descOrderByUrlInfo></#if>
            <#if descActive><#assign descOrderByUrlInfo = ascOrderByUrlInfo></#if>
            <span class="form-order-by">
                <a href="${ascOrderByUrlInfo.getUrlWithParams()}"<#if ascActive> class="active"</#if>><i class="glyphicon glyphicon-triangle-top"></i></a>
                <a href="${descOrderByUrlInfo.getUrlWithParams()}"<#if descActive> class="active"</#if>><i class="glyphicon glyphicon-triangle-bottom"></i></a>
            </span>
        </#if>
    </div>
    <#if fieldNode["header-field"]?has_content && fieldNode["header-field"][0]?children?has_content>
    <div class="form-header-field<#if containerStyle?has_content> ${containerStyle}</#if>">
        <@formListWidget fieldNode["header-field"][0] true true/>
        <#-- <#recurse fieldNode["header-field"][0]/> -->
    </div>
    </#if>
</#macro>
<#macro formListSubField fieldNode skipCell=false>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.condition(fieldSubNode["@condition"], "")>
            <@formListWidget fieldSubNode skipCell/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <#assign isHeaderField=false>
        <@formListWidget fieldNode["default-field"][0] skipCell/>
        <#return>
    </#if>
</#macro>
<#macro formListWidget fieldSubNode skipCell=false isHeaderField=false>
    <#if fieldSubNode["ignored"]?has_content><#return/></#if>
    <#assign fieldSubParent = fieldSubNode?parent>
    <#if ec.resource.condition(fieldSubParent["@hide"]!, "")><#return></#if>
    <#-- don't do a column for submit fields, they'll go in their own row at the bottom -->
    <#t><#if !isHeaderField && isMulti && !isMultiFinalRow && fieldSubNode["submit"]?has_content><#return/></#if>
    <#t><#if !isHeaderField && isMulti && isMultiFinalRow && !fieldSubNode["submit"]?has_content><#return/></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return/></#if>
    <#assign containerStyle = ec.resource.expand(fieldSubNode["@container-style"]!, "")>
    <#if !isMultiFinalRow && !isHeaderField><#if skipCell><div<#if containerStyle?has_content>class="${containerStyle}"</#if>><#else><td<#if containerStyle?has_content> class="${containerStyle}"</#if>></#if></#if>
        ${sri.pushContext()}
        <#list fieldSubNode?children as widgetNode><#if widgetNode?node_name == "set">${sri.setInContext(widgetNode)}</#if></#list>
        <#list fieldSubNode?children as widgetNode>
            <#if widgetNode?node_name == "link">
                <#assign linkNode = widgetNode>
                <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.resource.condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
                <#if conditionResult>
                    <#if linkNode["@entity-name"]?has_content>
                        <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
                    <#else>
                        <#assign textMap = "">
                        <#if linkNode["@text-map"]?has_content><#assign textMap = ec.resource.expression(linkNode["@text-map"], "")!></#if>
                        <#if textMap?has_content>
                            <#assign linkText = ec.resource.expand(linkNode["@text"], "", textMap)>
                        <#else>
                            <#assign linkText = ec.resource.expand(linkNode["@text"]!"", "")>
                        </#if>
                    </#if>
                    <#if !linkNode["@encode"]?has_content || linkNode["@encode"] == "true"><#assign linkText = linkText?html></#if>
                    <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
                    <#assign linkFormId><@fieldId linkNode/>_${linkNode["@url"]?replace(".", "_")}</#assign>
                    <#assign afterFormText><@linkFormForm linkNode linkFormId linkText linkUrlInfo/></#assign>
                    <#t>${sri.appendToAfterScreenWriter(afterFormText)}
                    <#t><@linkFormLink linkNode linkFormId linkText linkUrlInfo/>
                </#if>
            <#elseif widgetNode?node_name == "set"><#-- do nothing, handled above -->
            <#else><#t><#visit widgetNode></#if>
        </#list>
        ${sri.popContext()}
    <#if !isMultiFinalRow && !isHeaderField><#if skipCell></div><#else></td></#if></#if>
</#macro>
<#macro "row-actions"><#-- do nothing, these are run by the SRI --></#macro>

<#macro fieldName widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode["@name"]?html}<#if isMulti?exists && isMulti && listEntryIndex?has_content>_${listEntryIndex}</#if></#macro>
<#macro fieldId widgetNode><#assign fieldNode=widgetNode?parent?parent/>${ec.resource.expand(fieldNode?parent["@name"], "")}_${fieldNode["@name"]}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#macro>
<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${ec.resource.expand(fieldSubNode["@title"], "")}<#else><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.localize(titleValue)}</#macro>
<#macro fieldIdByName fieldName><#assign formName = ec.resource.expand(formNode["@name"], "")>${formName}_${fieldName}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#macro>

<#macro field><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "conditional-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "default-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro set><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>

<#-- ================== Form Field Widgets ==================== -->

<#macro check>
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node?parent?parent, "", null)>
    <#if !currentValue?has_content><#assign currentValue = ec.resource.expand(.node["@no-current-selected-key"]!, "")/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
    <#list (options.keySet())! as key>
        <#assign allChecked = ec.resource.expand(.node["@all-checked"]!, "")>
        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked! == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>${options.get(key)?default("")}</span>
    </#list>
</#macro>

<#macro "date-find">
    <#if .node["@type"]! == "time"><#assign size=9><#assign maxlength=13><#assign defaultFormat="HH:mm">
    <#elseif .node["@type"]! == "date"><#assign size=10><#assign maxlength=10><#assign defaultFormat="yyyy-MM-dd">
    <#else><#assign size=16><#assign maxlength=23><#assign defaultFormat="yyyy-MM-dd HH:mm">
    </#if>
    <#assign datepickerFormat><@getBootstrapDateFormat .node["@format"]!defaultFormat/></#assign>

    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign fieldValueFrom = ec.l10n.format(ec.context.get(curFieldName + "_from")!?default(.node["@default-value-from"]!""), defaultFormat)>
    <#assign fieldValueThru = ec.l10n.format(ec.context.get(curFieldName + "_thru")!?default(.node["@default-value-thru"]!""), defaultFormat)>
    <#assign id><@fieldId .node/></#assign>

    <span class="form-date-find">
      <span>${ec.l10n.localize("From")}&nbsp;</span>
    <#if .node["@type"]! != "time">
        <div class="input-group date" id="${id}_from">
            <input type="text" class="form-control" name="${curFieldName}_from" value="${fieldValueFrom?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
            <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
        </div>
        <script>$('#${id}_from').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate:'${fieldValueFrom?html}', format:'${datepickerFormat}', stepping:5, locale:"${ec.user.locale.toLanguageTag()}"});</script>
    <#else>
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$"
               name="${curFieldName}_from" value="${fieldValueFrom?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
    </#if>
    </span>

    <span class="form-date-find">
      <span>${ec.l10n.localize("Thru")}&nbsp;</span>
    <#if .node["@type"]! != "time">
        <div class="input-group date" id="${id}_thru">
            <input type="text" class="form-control" name="${curFieldName}_thru" value="${fieldValueThru?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
            <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
        </div>
        <script>$('#${id}_thru').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate:'${fieldValueThru?html}', format:'${datepickerFormat}', stepping:5, locale:"${ec.user.locale.toLanguageTag()}"});</script>
    <#else>
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$"
               name="${curFieldName}_thru" value="${fieldValueThru?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
    </#if>
    </span>
</#macro>

<#macro "date-period">
    <#assign id><@fieldId .node/></#assign>
    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign fvOffset = ec.context.get(curFieldName + "_poffset")!>
    <#assign fvPeriod = ec.context.get(curFieldName + "_period")!?lower_case>
    <#assign allowEmpty = .node["@allow-empty"]!"true">
    <div class="date-period">
        <select name="${curFieldName}_poffset" id="${id}_poffset"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
            <#if (allowEmpty! != "false")>
                <option value="">&nbsp;</option>
            </#if>
            <option value="0"<#if fvOffset == "0"> selected="selected"</#if>>${ec.l10n.localize("This")}</option>
            <option value="-1"<#if fvOffset == "-1"> selected="selected"</#if>>${ec.l10n.localize("Last")}</option>
            <option value="-2"<#if fvOffset == "-2"> selected="selected"</#if>>-2</option>
            <option value="-3"<#if fvOffset == "-3"> selected="selected"</#if>>-3</option>
            <option value="-4"<#if fvOffset == "-4"> selected="selected"</#if>>-4</option>
            <option value="1"<#if fvOffset == "1"> selected="selected"</#if>>${ec.l10n.localize("Next")}</option>
            <option value="2"<#if fvOffset == "2"> selected="selected"</#if>>+2</option>
            <option value="3"<#if fvOffset == "3"> selected="selected"</#if>>+3</option>
            <option value="4"<#if fvOffset == "4"> selected="selected"</#if>>+4</option>
        </select>
        <select name="${curFieldName}_period" id="${id}_period"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
            <#if (allowEmpty! != "false")>
            <option value="">&nbsp;</option>
            </#if>
            <option<#if fvPeriod == "day"> selected="selected"</#if>>${ec.l10n.localize("Day")}</option>
            <option<#if fvPeriod == "week"> selected="selected"</#if>>${ec.l10n.localize("Week")}</option>
            <option<#if fvPeriod == "month"> selected="selected"</#if>>${ec.l10n.localize("Month")}</option>
            <option<#if fvPeriod == "year"> selected="selected"</#if>>${ec.l10n.localize("Year")}</option>
        </select>
        <script>
            $("#${id}_poffset").select2({ minimumResultsForSearch:20, theme:'bootstrap' });
            $("#${id}_period").select2({ minimumResultsForSearch:20, theme:'bootstrap' });
        </script>
    </div>
</#macro>

<#--
eonasdan/bootstrap-datetimepicker uses Moment for time parsing/etc
For Moment format refer to http://momentjs.com/docs/#/displaying/format/
For Java simple date format refer to http://docs.oracle.com/javase/6/docs/api/java/text/SimpleDateFormat.html
Java	Moment  	Description
-	    a	        am/pm
a	    A	        AM/PM
s	    s	        seconds without leading zeros
ss	    ss	        seconds, 2 digits with leading zeros
m	    m	        minutes without leading zeros
mm	    mm	        minutes, 2 digits with leading zeros
H	    H	        hour without leading zeros - 24-hour format
HH	    HH	        hour, 2 digits with leading zeros - 24-hour format
h	    h	        hour without leading zeros - 12-hour format
hh	    hh	        hour, 2 digits with leading zeros - 12-hour format
d	    D	        day of the month without leading zeros
dd	    DD	        day of the month, 2 digits with leading zeros (NOTE: moment uses lower case d for day of week!)
M	    M	        numeric representation of month without leading zeros
MM	    MM	        numeric representation of the month, 2 digits with leading zeros
MMM	    MMM	        short textual representation of a month, three letters
MMMM	MMMM	    full textual representation of a month, such as January or March
yy	    YY	        two digit representation of a year
yyyy	YYYY	    full numeric representation of a year, 4 digits

Summary of changes needed:
a => A, d => D, y => Y
-->
<#macro getBootstrapDateFormat dateFormat>${dateFormat?replace("a","A")?replace("d","D")?replace("y","Y")}</#macro>

<#macro "date-time">
    <#assign javaFormat = .node["@format"]!>
    <#if !javaFormat?has_content>
        <#if .node["@type"]! == "time"><#assign javaFormat="HH:mm">
        <#elseif .node["@type"]! == "date"><#assign javaFormat="yyyy-MM-dd">
        <#else><#assign javaFormat="yyyy-MM-dd HH:mm"></#if>
    </#if>
    <#assign datepickerFormat><@getBootstrapDateFormat javaFormat/></#assign>
    <#assign fieldValue = sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", javaFormat)>

    <#assign id><@fieldId .node/></#assign>

    <#if .node["@type"]! == "time"><#assign size=9><#assign maxlength=13>
        <#elseif .node["@type"]! == "date"><#assign size=10><#assign maxlength=10>
        <#else><#assign size=16><#assign maxlength=23></#if>
    <#assign size = .node["@size"]!size>
    <#assign maxlength = .node["@max-length"]!maxlength>

    <#if .node["@type"]! != "time">
        <div class="input-group date" id="${id}">
            <input type="text" class="form-control" name="<@fieldName .node/>" value="${fieldValue?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
        </div>
        <script>$('#${id}').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate:'${fieldValue?html}', format:'${datepickerFormat}', stepping:5, locale:"${ec.user.locale.toLanguageTag()}"});</script>
    <#else>
        <#-- datetimepicker does not support time only, even with plain HH:mm format; use a regex to validate time format -->
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$" name="<@fieldName .node/>" value="${fieldValue?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
    </#if>
</#macro>

<#macro display>
    <#assign fieldValue = ""/>
    <#if .node["@text"]?has_content>
        <#assign textMap = "">
        <#if .node["@text-map"]?has_content><#assign textMap = ec.resource.expression(.node["@text-map"], "")!></#if>
        <#if textMap?has_content>
            <#assign fieldValue = ec.resource.expand(.node["@text"], "", textMap)>
        <#else>
            <#assign fieldValue = ec.resource.expand(.node["@text"], "")>
        </#if>
        <#if .node["@currency-unit-field"]?has_content>
            <#assign fieldValue = ec.l10n.formatCurrency(fieldValue, ec.resource.expression(.node["@currency-unit-field"], ""), 2)>
        </#if>
    <#elseif .node["@currency-unit-field"]?has_content>
        <#assign fieldValue = ec.l10n.formatCurrency(sri.getFieldValue(.node?parent?parent, ""), ec.resource.expression(.node["@currency-unit-field"], ""), 2)>
    <#else>
        <#assign fieldValue = sri.getFieldValueString(.node?parent?parent, "", .node["@format"]!)>
    </#if>
    <#t><p id="<@fieldId .node/>_display" class="form-control-static ${sri.getFieldValueClass(.node?parent?parent)}<#if .node["@currency-unit-field"]?has_content> currency</#if>"><#if fieldValue?has_content><#if .node["@encode"]! == "false">${fieldValue}<#else>${fieldValue?html?replace("\n", "<br>")}</#if><#else>&nbsp;</#if></p>
    <#t><#if !.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true">
        <#-- use getFieldValuePlainString() and not getFieldValueString() so we don't do timezone conversions, etc -->
        <#-- don't default to fieldValue for the hidden input value, will only be different from the entry value if @text is used, and we don't want that in the hidden value -->
        <input type="hidden" id="<@fieldId .node/>" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(.node?parent?parent, "")?html}">
    </#if>
</#macro>
<#macro "display-entity">
    <#assign fieldValue = ""/><#assign fieldValue = sri.getFieldEntityValue(.node)!/>
    <#t><p id="<@fieldId .node/>_display" class="form-control-static"><#if fieldValue?has_content><#if .node["@encode"]!"true" == "false">${fieldValue!"&nbsp;"}<#else>${(fieldValue!" ")?html?replace("\n", "<br>")}</#if><#else>&nbsp;</#if></p>
    <#-- don't default to fieldValue for the hidden input value, will only be different from the entry value if @text is used, and we don't want that in the hidden value -->
    <#t><#if !.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true"><input type="hidden" id="<@fieldId .node/>" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(.node?parent?parent, "")?html}"></#if>
</#macro>

<#macro "drop-down">
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)/>
    <#assign currentValue = sri.getFieldValueString(.node?parent?parent, "", null)/>
    <#if !currentValue?has_content><#assign currentValue = ec.resource.expand(.node["@no-current-selected-key"]!, "")/></#if>
    <#if currentValue?starts_with("[")><#assign currentValue = currentValue?substring(1, currentValue?length - 1)?replace(" ", "")></#if>
    <#assign currentValueList = (currentValue?split(","))!>

    <#assign currentDescription = (options.get(currentValue))!>
    <#if !currentDescription?has_content && .node["@current-description"]?has_content>
        <#assign currentDescription = ec.resource.expand(.node["@current-description"], "")/>
    </#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign allowMultiple = ec.resource.expand(.node["@allow-multiple"]!, "") == "true"/>
    <#assign isDynamicOptions = .node["dynamic-options"]?has_content>
    <#assign name><@fieldName .node/></#assign>
    <select name="${name}" class="<#if isDynamicOptions>dynamic-options</#if><#if .node["@style"]?has_content> ${ec.resource.expand(.node["@style"], "")}</#if>" id="${id}"<#if allowMultiple> multiple="multiple"</#if><#if .node["@size"]?has_content> size="${.node["@size"]}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
    <#if currentValue?has_content && (.node["@current"]! == "first-in-list") && !(allowMultiple)>
        <option selected="selected" value="${currentValue}"><#if currentDescription?has_content>${currentDescription}<#else>${currentValue}</#if></option><#rt/>
        <option value="${currentValue}">---</option><#rt/>
    </#if>
    <#assign allowEmpty = ec.resource.expand(.node["@allow-empty"]!, "")/>
    <#if (allowEmpty! == "true") || !(options?has_content)>
        <option value="">&nbsp;</option>
    </#if>

    <#if !isDynamicOptions>
        <#list (options.keySet())! as key>
            <#assign isSelected = currentValue?has_content && currentValue == key>
            <#if allowMultiple && currentValueList?has_content><#list currentValueList as curValue>
                <#if curValue == key><#assign isSelected = true></#if>
            </#list></#if>
            <option<#if isSelected> selected="selected"</#if> value="${key}">${options.get(key)}</option>
        </#list>
    </#if>
    </select>
    <#-- <span>[${currentValue}]; <#list currentValueList as curValue>[${curValue!''}], </#list></span> -->
    <#if allowMultiple><input type="hidden" id="${id}_op" name="${name}_op" value="in"></#if>

    <#assign select2DefaultOptions = "minimumResultsForSearch:10, theme:'bootstrap'">
    <#if .node["@combo-box"]! == "true">
        <script>$("#${id}").select2({ tags: true, tokenSeparators:[',',' '], theme:'bootstrap' });</script>
    <#elseif .node["@search"]! != "false">
        <script>$("#${id}").select2({ ${select2DefaultOptions} });</script>
    </#if>

    <#if isDynamicOptions>
        <#assign doNode = .node["dynamic-options"][0]>
        <#assign depNodeList = doNode["depends-on"]>
        <#assign doUrlInfo = sri.makeUrlByType(doNode["@transition"], "transition", .node, "false")>
        <#assign doUrlParameterMap = doUrlInfo.getParameterMap()>
        <script>
            function populate_${id}() {
                var hasAllParms = true;
                <#list depNodeList as depNode>if (!$('#<@fieldIdByName depNode["@field"]/>').val()) { hasAllParms = false; } </#list>
                if (!hasAllParms) { $("#${id}").select2("destroy"); $('#${id}').html(""); $("#${id}").select2({ ${select2DefaultOptions} }); <#-- alert("not has all parms"); --> return; }
                $.ajax({ type:'POST', url:'${doUrlInfo.url}', data:{ moquiSessionToken: "${(ec.web.sessionToken)!}"<#list depNodeList as depNode>, '${depNode["@field"]}': $('#<@fieldIdByName depNode["@field"]/>').val()</#list><#list doUrlParameterMap?keys as parameterKey><#if doUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${doUrlParameterMap.get(parameterKey)}"</#if></#list> }, dataType:'json' }).done(
                    function(list) {
                        if (list) {
                            $("#${id}").select2("destroy");
                            $('#${id}').html(""); /* clear out the drop-down */
                            <#if allowEmpty! == "true">
                            $('#${id}').append('<option value="">&nbsp;</option>');
                            </#if>
                            $.each(list, function(key, value) {
                                var optionValue = value["${doNode["@value-field"]!"value"}"];
                                if (optionValue == "${currentValue}") {
                                    $('#${id}').append("<option selected='selected' value='" + optionValue + "'>" + value["${doNode["@label-field"]!"label"}"] + "</option>");
                                } else {
                                    $('#${id}').append("<option value='" + optionValue + "'>" + value["${doNode["@label-field"]!"label"}"] + "</option>");
                                }
                            });
                            $("#${id}").select2({ ${select2DefaultOptions} });
                        }
                    }
                );
            }
            <#list depNodeList as depNode>
            $("#<@fieldIdByName depNode["@field"]/>").on('change', function() { populate_${id}(); });
            </#list>
            populate_${id}();
        </script>
    </#if>
</#macro>

<#macro file><input type="file" class="form-control" name="<@fieldName .node/>" value="${sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", null)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>></#macro>

<#macro hidden>
    <#-- use getFieldValuePlainString() and not getFieldValueString() so we don't do timezone conversions, etc -->
    <#assign id><@fieldId .node/></#assign>
    <input type="hidden" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(.node?parent?parent, .node["@default-value"]!"")?html}" id="${id}">
</#macro>

<#macro ignored><#-- shouldn't ever be called as it is checked in the form-* macros --></#macro>

<#-- TABLED, not to be part of 1.0:
<#macro "lookup">
    <#assign curFieldName = .node?parent?parent["@name"]?html/>
    <#assign curFormName = .node?parent?parent?parent["@name"]?html/>
    <#assign id><@fieldId .node/></#assign>
    <input type="text" name="${curFieldName}" value="${sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", null)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if ec.resource.condition(.node.@disabled!"false", "")> disabled="disabled"</#if> id="${id}">
    <#assign ajaxUrl = ""/><#- - LATER once the JSON service stuff is in place put something real here - ->
    <#- - LATER get lookup code in place, or not... - ->
    <script>
        $(document).ready(function() {
            new ConstructLookup("${.node["@target-screen"]}", "${id}", document.${curFormName}.${curFieldName},
            <#if .node["@secondary-field"]?has_content>document.${curFormName}.${.node["@secondary-field"]}<#else>null</#if>,
            "${curFormName}", "${width!""}", "${height!""}", "${position!"topcenter"}", "${fadeBackground!"true"}", "${ajaxUrl!""}", "${showDescription!""}", ''); });
    </script>
</#macro>
-->

<#macro password>
    <#assign validationClasses = sri.getFormFieldValidationClasses(.node?parent?parent?parent["@name"], .node?parent?parent["@name"])>
    <input type="password" name="<@fieldName .node/>" id="<@fieldId .node/>" class="form-control<#if validationClasses?has_content> ${validationClasses}</#if>" size="${.node.@size!"25"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if><#if validationClasses?contains("required")> required</#if>>
</#macro>

<#macro radio>
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)/>
    <#assign currentValue = sri.getFieldValueString(.node?parent?parent, "", null)/>
    <#if !currentValue?has_content><#assign currentValue = ec.resource.expand(.node["@no-current-selected-key"]!, "")/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
    <#list (options.keySet())! as key>
        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="radio" name="${curName}" value="${key?html}"<#if currentValue?has_content && currentValue==key> checked="checked"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>&nbsp;${options.get(key)?default("")}</span>
    </#list>
</#macro>

<#macro "range-find">
    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign id><@fieldId .node/></#assign>
<span class="form-range-find">
    <span>${ec.l10n.localize("From")}&nbsp;</span><input type="text" class="form-control" name="${curFieldName}_from" value="${ec.web.parameters.get(curFieldName + "_from")!?default(.node["@default-value-from"]!"")?html}" size="${.node.@size!"10"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="${id}_from"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
</span>
<span class="form-range-find">
    <span>${ec.l10n.localize("Thru")}&nbsp;</span><input type="text" class="form-control" name="${curFieldName}_thru" value="${ec.web.parameters.get(curFieldName + "_thru")!?default(.node["@default-value-thru"]!"")?html}" size="${.node.@size!"10"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="${id}_thru"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
</span>
</#macro>

<#macro reset><input type="reset" name="<@fieldName .node/>" value="<@fieldTitle .node?parent/>" id="<@fieldId .node/>"<#if .node["@icon"]?has_content> iconcls="ui-icon-${.node["@icon"]}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>></#macro>

<#macro submit>
    <#assign confirmationMessage = ec.resource.expand(.node["@confirmation"]!, "")/>
    <#assign buttonText><@fieldTitle .node?parent/></#assign>
    <#assign iconClass = .node["@icon"]!>
    <#if !iconClass?has_content && .node?parent["@title"]?has_content><#assign iconClass = sri.getThemeIconClass(.node?parent["@title"])!></#if>
    <button type="submit" name="<@fieldName .node/>" value="<@fieldName .node/>" id="<@fieldId .node/>"<#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}');"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if> class="btn btn-primary btn-sm"><#if iconClass?has_content><i class="${iconClass}"></i> </#if>
    <#if .node["image"]?has_content><#assign imageNode = .node["image"][0]>
        <img src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}" alt="<#if imageNode["@alt"]?has_content>${imageNode["@alt"]}<#else><@fieldTitle .node?parent/></#if>"<#if imageNode["@width"]?has_content> width="${imageNode["@width"]}"</#if><#if imageNode["@height"]?has_content> height="${imageNode["@height"]}"</#if>>
    <#else>
        <#t>${buttonText}
    </#if>
    </button>
</#macro>

<#macro "text-area"><textarea class="form-control" name="<@fieldName .node/>" cols="${.node["@cols"]!"60"}" rows="${.node["@rows"]!"3"}"<#if .node["@read-only"]!"false" == "true"> readonly="readonly"</#if><#if .node["@maxlength"]?has_content> maxlength="${.node["@maxlength"]}"</#if> id="<@fieldId .node/>"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>${sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", null)?html}</textarea></#macro>

<#macro "text-line">
    <#assign id><@fieldId .node/></#assign>
    <#assign name><@fieldName .node/></#assign>
    <#assign fieldValue = sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", .node["@format"]!)>
    <#assign validationClasses = sri.getFormFieldValidationClasses(.node?parent?parent?parent["@name"], .node?parent?parent["@name"])>
    <#assign regexpInfo = sri.getFormFieldValidationRegexpInfo(.node?parent?parent?parent["@name"], .node?parent?parent["@name"])!>
    <#assign isAutoComplete = .node["@ac-transition"]?has_content>
    <#-- NOTE: removed number type (<#elseif validationClasses?contains("number")>number) because on Safari, maybe others, ignores size and behaves funny for decimal values -->
    <#if isAutoComplete>
        <#assign acUrlInfo = sri.makeUrlByType(.node["@ac-transition"], "transition", .node, "false")>
        <#assign acUrlParameterMap = acUrlInfo.getParameterMap()>
        <#assign acShowValue = .node["@ac-show-value"]! == "true">
        <#assign acUseActual = .node["@ac-use-actual"]! == "true">
        <#if .node["@ac-initial-text"]?has_content><#assign valueText = ec.resource.expand(.node["@ac-initial-text"]!, "")>
            <#else><#assign valueText = fieldValue></#if>
        <input id="${id}_ac" type="<#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if>" name="${name}_ac" value="${valueText?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if ec.resource.condition(.node.@disabled!"false", "")> disabled="disabled"</#if> class="form-control<#if validationClasses?has_content> ${validationClasses}</#if>"<#if validationClasses?has_content> data-vv-validations="${validationClasses}"</#if><#if validationClasses?contains("required")> required</#if><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if> autocomplete="off">
        <input id="${id}" type="hidden" name="${name}" value="${fieldValue?html}">
        <#if acShowValue><span id="${id}_value" class="form-autocomplete-value"><#if valueText?has_content>${valueText?html}<#else>&nbsp;</#if></span></#if>
        <#assign depNodeList = .node["depends-on"]>
        <script>

            $("#${id}_ac").autocomplete({
                source: function(request, response) { $.ajax({
                    url: "${acUrlInfo.url}", type: "POST", dataType: "json", data: { term: request.term, moquiSessionToken: "${(ec.web.sessionToken)!}"<#list depNodeList as depNode>, '${depNode["@field"]}': $('#<@fieldIdByName depNode["@field"]/>').val()</#list><#list acUrlParameterMap?keys as parameterKey><#if acUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${acUrlParameterMap.get(parameterKey)}"</#if></#list> },
                    success: function(data) { response($.map(data, function(item) { return { label: item.label, value: item.value } })); }
                }); }, <#if .node["@ac-delay"]?has_content>delay: ${.node["@ac-delay"]},</#if><#if .node["@ac-min-length"]?has_content>minLength: ${.node["@ac-min-length"]},</#if>
                focus: function(event, ui) { $("#${id}").val(ui.item.value); $("#${id}").trigger("change"); $("#${id}_ac").val(ui.item.label); return false; },
                select: function(event, ui) { if (ui.item) { this.value = ui.item.value; $("#${id}").val(ui.item.value); $("#${id}").trigger("change"); $("#${id}_ac").val(ui.item.label);<#if acShowValue> if (ui.item.label) { $("#${id}_value").html(ui.item.label); }</#if> return false; } }
            });
            $("#${id}_ac").change(function() { if (!$("#${id}_ac").val()) { $("#${id}").val(""); $("#${id}").trigger("change"); }<#if acUseActual> else { $("#${id}").val($("#${id}_ac").val()); $("#${id}").trigger("change"); }</#if> });
            <#list depNodeList as depNode>
                $("#<@fieldIdByName depNode["@field"]/>").change(function() { $("#${id}").val(""); $("#${id}_ac").val(""); });
            </#list>
            <#if !.node["@ac-initial-text"]?has_content>
            /* load the initial value if there is one */
            if ($("#${id}").val()) {
                $.ajax({ url: "${acUrlInfo.url}", type: "POST", dataType: "json", data: { term: $("#${id}").val(), moquiSessionToken: "${(ec.web.sessionToken)!}"<#list acUrlParameterMap?keys as parameterKey><#if acUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${acUrlParameterMap.get(parameterKey)}"</#if></#list> },
                    success: function(data) {
                        var curValue = $("#${id}").val();
                        for (var i = 0; i < data.length; i++) { if (data[i].value == curValue) { $("#${id}_ac").val(data[i].label); <#if acShowValue>$("#${id}_value").html(data[i].label);</#if> break; } }
                        <#-- don't do this by default if we haven't found a valid one: if (data && data[0].label) { $("#${id}_ac").val(data[0].label); <#if acShowValue>$("#${id}_value").html(data[0].label);</#if> } -->
                    }
                });
            }
            </#if>

        </script>
    <#else>
        <input id="${id}" type="<#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if>" name="${name}" value="${fieldValue?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if ec.resource.condition(.node.@disabled!"false", "")> disabled="disabled"</#if> class="form-control<#if validationClasses?has_content> ${validationClasses}</#if>"<#if validationClasses?has_content> data-vv-validations="${validationClasses}"</#if><#if validationClasses?contains("required")> required</#if><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>
    </#if>
</#macro>

<#macro "text-find">
<span class="form-text-find">
    <#assign defaultOperator = .node["@default-operator"]?default("contains")>
    <#assign curFieldName><@fieldName .node/></#assign>
    <#if .node["@hide-options"]! == "true" || .node["@hide-options"]! == "operator">
        <input type="hidden" name="${curFieldName}_op" value="${defaultOperator}">
    <#else>
        <span><input type="checkbox" class="form-control" name="${curFieldName}_not" value="Y"<#if ec.web.parameters.get(curFieldName + "_not")! == "Y"> checked="checked"</#if>>&nbsp;${ec.l10n.localize("Not")}</span>
        <select name="${curFieldName}_op" class="form-control">
            <option value="equals"<#if defaultOperator == "equals"> selected="selected"</#if>>${ec.l10n.localize("Equals")}</option>
            <option value="like"<#if defaultOperator == "like"> selected="selected"</#if>>${ec.l10n.localize("Like")}</option>
            <option value="contains"<#if defaultOperator == "contains"> selected="selected"</#if>>${ec.l10n.localize("Contains")}</option>
            <option value="begins"<#if defaultOperator == "begins"> selected="selected"</#if>>${ec.l10n.localize("Begins With")}</option>
            <option value="empty"<#rt/><#if defaultOperator == "empty"> selected="selected"</#if>>${ec.l10n.localize("Empty")}</option>
        </select>
    </#if>

    <input type="text" class="form-control" name="${curFieldName}" value="${sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", null)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="<@fieldId .node/>"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.resource.expand(.node?parent["@tooltip"], "")}"</#if>>

    <#assign ignoreCase = (ec.web.parameters.get(curFieldName + "_ic")! == "Y") || !(.node["@ignore-case"]?has_content) || (.node["ignore-case"] == "true")>
    <#if .node["@hide-options"]! == "true" || .node["@hide-options"]! == "ignore-case">
        <input type="hidden" name="${curFieldName}_ic" value="Y"<#if ignoreCase> checked="checked"</#if>>
    <#else>
        <span><input type="checkbox" class="form-control" name="${curFieldName}_ic" value="Y"<#if ignoreCase> checked="checked"</#if>>&nbsp;${ec.l10n.localize("Ignore Case")}</span>
    </#if>
</span>
</#macro>
