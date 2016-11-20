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

<#-- set here because used in drop-down, container-dialog and dynamic-dialog -->
<#assign select2DefaultOptions = "minimumResultsForSearch:15, theme:'bootstrap'">

<#macro @element><p>=== Doing nothing for element ${.node?node_name}, not yet implemented. ===</p></#macro>

<#macro screen>
    <#recurse>
</#macro>
<#macro widgets><#t>
    <#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
    <#recurse>
    <#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].widgets --></#if>
</#macro>
<#macro "fail-widgets"><#t>
    <#if sri.doBoundaryComments()><!-- BEGIN screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
    <#recurse>
    <#if sri.doBoundaryComments()><!-- END   screen[@location=${sri.getActiveScreenDef().location}].fail-widgets --></#if>
</#macro>

<#-- ================ Subscreens ================ -->
<#macro "subscreens-menu"><#if hideNav! != "true">
    <#assign displayMenu = sri.activeInCurrentMenu!>
    <#assign menuId = .node["@id"]!"subscreensMenu">
    <#assign menuTitle = .node["@title"]!sri.getActiveScreenDef().getDefaultMenuName()!"Menu">
    <#if .node["@type"]! == "popup">
        <li id="${menuId}" class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">${ec.getResource().expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
            <ul class="dropdown-menu">
                <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                    <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                    <#if urlInstance.isPermitted()>
                        <li<#if urlInstance.inCurrentScreenPath> class="active"</#if>><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>"><#rt>
                            <#assign expandedMenuTitle = ec.getResource().expand(subscreensItem.menuTitle, "")>
                            <#if urlInstance.sui.menuImage?has_content>
                                <#if urlInstance.sui.menuImageType == "icon">
                                    <#t><i class="${urlInstance.sui.menuImage}" style="padding-right: 8px;"></i>
                                <#elseif urlInstance.sui.menuImageType == "url-plain">
                                    <#t><img src="${urlInstance.sui.menuImage}" alt="${expandedMenuTitle}" width="18" style="padding-right: 4px;"/>
                                <#else><#rt>
                                    <#t><img src="${sri.buildUrl(urlInstance.sui.menuImage).url}" alt="${expandedMenuTitle}" height="18" style="padding-right: 4px;"/>
                                </#if><#rt>
                            <#else><#rt>
                                <#t><i class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                            </#if><#rt>
                            <#t>${expandedMenuTitle}
                        <#lt></a></li>
                    </#if>
                </#list>
            </ul>
        </li>
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
                        <li class="<#if urlInstance.inCurrentScreenPath>active</#if><#if urlInstance.disableLink> disabled</#if>"><#if urlInstance.disableLink>${ec.getResource().expand(subscreensItem.menuTitle, "")}<#else><a href="${urlInstance.minimalPathUrlWithParams}">${ec.getL10n().localize(subscreensItem.menuTitle)}</a></#if></li>
                    </#if>
                </#list>
            </ul>
        </#if>
        <#-- add to navbar bread crumbs too -->
        <a id="${menuId}-crumb" class="navbar-text" href="${sri.buildUrl(".")}">${ec.getResource().expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
        <script>$("#navbar-menu-crumbs").append($("#${menuId}-crumb"));</script>
    </#if>
</#if></#macro>

<#macro "subscreens-active">
    ${sri.renderSubscreen()}
</#macro>

<#macro "subscreens-panel">
    <#assign dynamic = .node["@dynamic"]! == "true" && .node["@id"]?has_content>
    <#assign dynamicActive = 0>
    <#assign displayMenu = sri.activeInCurrentMenu!true && hideNav! != "true">
    <#assign menuId><#if .node["@id"]?has_content>${.node["@id"]}-menu<#else>subscreensPanelMenu</#if></#assign>
    <#assign menuTitle = .node["@title"]!sri.getActiveScreenDef().getDefaultMenuName()!"Menu">
    <#if .node["@type"]! == "popup">
        <#if hideNav! != "true">
        <li id="${menuId}" class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">${ec.getResource().expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
            <ul class="dropdown-menu">
                <#list sri.getActiveScreenDef().getMenuSubscreensItems() as subscreensItem>
                    <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                    <#if urlInstance.isPermitted()>
                        <li<#if urlInstance.inCurrentScreenPath> class="active"</#if>><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>"><#rt>
                            <#assign expandedMenuTitle = ec.getResource().expand(subscreensItem.menuTitle, "")>
                            <#if urlInstance.sui.menuImage?has_content>
                                <#if urlInstance.sui.menuImageType == "icon">
                                    <#t><i class="${urlInstance.sui.menuImage}" style="padding-right: 8px;"></i>
                                <#elseif urlInstance.sui.menuImageType == "url-plain">
                                    <#t><img src="${urlInstance.sui.menuImage}" alt="${expandedMenuTitle}" width="18" style="padding-right: 4px;"/>
                                <#else><#rt>
                                    <#t><img src="${sri.buildUrl(urlInstance.sui.menuImage).url}" alt="${expandedMenuTitle}" height="18" style="padding-right: 4px;"/>
                                </#if><#rt>
                            <#else><#rt>
                                <#t><i class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                            </#if><#rt>
                            <#t>${expandedMenuTitle}
                        <#lt></a></li>
                    </#if>
                </#list>
            </ul>
        </li>
        <#-- move the menu to the header menus section -->
        <script>$("#${.node["@header-menus-id"]!"header-menus"}").append($("#${menuId}"));</script>
        </#if>
        ${sri.renderSubscreen()}
    <#elseif .node["@type"]! == "stack">
        <h1>LATER stack type subscreens-panel not yet supported.</h1>
    <#elseif .node["@type"]! == "wizard">
        <h1>LATER wizard type subscreens-panel not yet supported.</h1>
    <#else>
        <#-- default to type=tab -->
        <div<#if .node["@id"]?has_content> id="${.node["@id"]}-tabpanel"</#if>>
            <#assign menuSubscreensItems=sri.getActiveScreenDef().getMenuSubscreensItems()>
            <#if menuSubscreensItems?has_content && (menuSubscreensItems?size > 1)>
                <#if displayMenu>
                    <ul<#if .node["@id"]?has_content> id="${.node["@id"]}-menu"</#if> class="nav nav-tabs" role="tablist">
                    <#list menuSubscreensItems as subscreensItem>
                        <#assign urlInstance = sri.buildUrl(subscreensItem.name)>
                        <#if urlInstance.isPermitted()>
                            <#if dynamic>
                                <#assign urlInstance = urlInstance.addParameter("lastStandalone", "true")>
                                <#if urlInstance.inCurrentScreenPath>
                                    <#assign dynamicActive = subscreensItem_index>
                                    <#assign urlInstance = urlInstance.addParameters(ec.getWeb().requestParameters)>
                                </#if>
                            </#if>
                            <li class="<#if urlInstance.disableLink>disabled<#elseif urlInstance.inCurrentScreenPath>active</#if>"><a href="<#if urlInstance.disableLink>#<#else>${urlInstance.minimalPathUrlWithParams}</#if>">${ec.getResource().expand(subscreensItem.menuTitle, "")}</a></li>
                        </#if>
                    </#list>
                    </ul>
                </#if>
            </#if>
            <#if hideNav! != "true">
                <#-- add to navbar bread crumbs too -->
                <a id="${menuId}-crumb" class="navbar-text" href="${sri.buildUrl(".")}">${ec.getResource().expand(menuTitle, "")} <i class="glyphicon glyphicon-chevron-right"></i></a>
                <script>$("#navbar-menu-crumbs").append($("#${menuId}-crumb"));</script>
            </#if>
            <#if !dynamic || !displayMenu>
            <#-- these make it more similar to the HTML produced when dynamic, but not needed: <div<#if .node["@id"]?has_content> id="${.node["@id"]}-active"</#if> class="ui-tabs-panel"> -->
            ${sri.renderSubscreen()}
            <#-- </div> -->
            </#if>
        </div>
        <#if dynamic && displayMenu>
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
<#macro nodeId widgetNode><#if .node["@id"]?has_content>${ec.getResource().expandNoL10n(widgetNode["@id"], "")}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#if></#macro>

<#macro container>
    <#assign contDivId><@nodeId .node/></#assign>
    <${.node["@type"]!"div"}<#if contDivId?has_content> id="${contDivId}"</#if><#if .node["@style"]?has_content> class="${ec.getResource().expandNoL10n(.node["@style"], "")}"</#if>>
    <#recurse>
    </${.node["@type"]!"div"}>
</#macro>

<#macro "container-box">
    <#assign contBoxDivId><@nodeId .node/></#assign>
    <div class="panel panel-default"<#if contBoxDivId?has_content> id="${contBoxDivId}"</#if>>
        <div class="panel-heading">
            <#recurse .node["box-header"][0]>
            <#if .node["box-toolbar"]?has_content>
                <div class="panel-toolbar">
                    <#recurse .node["box-toolbar"][0]>
                </div>
            </#if>
        </div>
        <#if .node["box-body"]?has_content>
            <div class="panel-body">
                <#recurse .node["box-body"][0]>
            </div>
        </#if>
        <#if .node["box-body-nopad"]?has_content>
            <#recurse .node["box-body-nopad"][0]>
        </#if>
    </div>
</#macro>

<#macro "container-row">
    <#assign contRowDivId><@nodeId .node/></#assign>
    <div class="row<#if .node["@style"]?has_content> ${ec.getResource().expandNoL10n(.node["@style"], "")}</#if>"<#if contRowDivId?has_content> id="${contRowDivId}"</#if>>
        <#list .node["row-col"] as rowColNode>
            <div class="<#if rowColNode["@lg"]?has_content> col-lg-${rowColNode["@lg"]}</#if><#if rowColNode["@md"]?has_content> col-md-${rowColNode["@md"]}</#if><#if rowColNode["@sm"]?has_content> col-sm-${rowColNode["@sm"]}</#if><#if rowColNode["@xs"]?has_content> col-xs-${rowColNode["@xs"]}</#if><#if rowColNode["@style"]?has_content> ${ec.getResource().expandNoL10n(rowColNode["@style"], "")}</#if>">
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
    <#assign buttonText = ec.getResource().expand(.node["@button-text"], "")>
    <#assign cdDivId><@nodeId .node/></#assign>
    <button id="${cdDivId}-button" type="button" data-toggle="modal" data-target="#${cdDivId}" data-original-title="${buttonText}" data-placement="bottom" class="btn btn-primary btn-sm"><i class="glyphicon glyphicon-share"></i> ${buttonText}</button>
    <#if _openDialog! == cdDivId><#assign afterScreenScript>$('#${cdDivId}').modal('show'); </#assign><#t>${sri.appendToScriptWriter(afterScreenScript)}</#if>
    <div id="${cdDivId}" class="modal container-dialog" aria-hidden="true" style="display: none;" tabindex="-1">
        <div class="modal-dialog" style="width: ${.node["@width"]!"760"}px;">
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
    <script>$('#${cdDivId}').on('shown.bs.modal', function() {
        $("#${cdDivId} select").select2({ ${select2DefaultOptions} });
        $("#${cdDivId} .default-focus").focus();
    });</script>
</#macro>

<#macro "dynamic-container">
    <#assign dcDivId><@nodeId .node/></#assign>
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true").addParameter("_dynamic_container_id", dcDivId)>
    <div id="${dcDivId}"><img src="/images/wait_anim_16x16.gif" alt="Loading..."></div>
    <script>
        function load${dcDivId}() { $("#${dcDivId}").load("${urlInstance.passThroughSpecialParameters().urlWithParams}", function() { <#-- activateAllButtons() --> }); }
        load${dcDivId}();
    </script>
</#macro>

<#macro "dynamic-dialog">
    <#assign buttonText = ec.getResource().expand(.node["@button-text"], "")>
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
    <#assign ddDivId><@nodeId .node/></#assign>

    <button id="${ddDivId}-button" type="button" data-toggle="modal" data-target="#${ddDivId}" data-original-title="${buttonText}" data-placement="bottom" class="btn btn-primary btn-sm"><i class="glyphicon glyphicon-share"></i> ${buttonText}</button>
    <#assign afterFormText>
    <div id="${ddDivId}" class="modal dynamic-dialog" aria-hidden="true" style="display: none;" tabindex="-1">
        <div class="modal-dialog" style="width: ${.node["@width"]!"760"}px;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${buttonText}</h4>
                </div>
                <div class="modal-body" id="${ddDivId}-body">
                    <img src="/images/wait_anim_16x16.gif" alt="Loading...">
                </div>
                <#-- <div class="modal-footer"><button type="button" class="btn btn-primary" data-dismiss="modal">Close</button></div> -->
            </div>
        </div>
    </div>
    <script>
        $("#${ddDivId}").on("show.bs.modal", function (e) { $("#${ddDivId}-body").load('${urlInstance.urlWithParams}'); });
        $("#${ddDivId}").on("hidden.bs.modal", function (e) { $("#${ddDivId}-body").empty(); $("#${ddDivId}-body").append('<img src="/images/wait_anim_16x16.gif" alt="Loading...">'); });
        $('#${ddDivId}').on('shown.bs.modal', function() {$("#${ddDivId} select").select2({ ${select2DefaultOptions} });});
        <#if _openDialog! == ddDivId>$('#${ddDivId}').modal('show');</#if>
    </script>
    </#assign>
    <#t>${sri.appendToAfterScreenWriter(afterFormText)}
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
                    moquiSessionToken: "${(ec.getWeb().sessionToken)!}"
                    <#if .node["@open-path"]??>, treeOpenPath: "${ec.getResource().expandNoL10n(.node["@open-path"], "")}"</#if>
                    <#list ajaxParms.keySet() as pKey>, "${pKey}": "${ajaxParms.get(pKey)!""}"</#list> }; }
            }
        }
    });
    </script>
</#macro>
<#macro "tree-node"><#-- shouldn't be called directly, but just in case --></#macro>
<#macro "tree-sub-node"><#-- shouldn't be called directly, but just in case --></#macro>

<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode">
<#if .node["text"]?has_content>
    <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#assign textToUse = textNode/></#if></#list>
    <#list .node["text"] as textNode><#if textNode["@type"]?has_content && textNode["@type"] == sri.getRenderMode()><#assign textToUse = textNode></#if></#list>
    <#if textToUse??>
        <#if textToUse["@location"]?has_content>
          <#assign textLocation = ec.getResource().expandNoL10n(textToUse["@location"], "")>
          <#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]! != "true"><!-- BEGIN render-mode.text[@location=${textLocation}][@template=${textToUse["@template"]!"true"}] --></#if>
          <#-- NOTE: this still won't encode templates that are rendered to the writer -->
          <#if .node["@encode"]! == "true">${sri.renderText(textLocation, textToUse["@template"]!)?html}<#else>${sri.renderText(textLocation, textToUse["@template"]!)}</#if>
          <#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]! != "true"><!-- END   render-mode.text[@location=${textLocation}][@template=${textToUse["@template"]!"true"}] --></#if>
        </#if>
        <#assign inlineTemplateSource = textToUse.@@text!>
        <#if inlineTemplateSource?has_content>
          <#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]! != "true"><!-- BEGIN render-mode.text[inline][@template=${textToUse["@template"]!"true"}] --></#if>
          <#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
            <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
            <@inlineTemplate/>
          <#else>
            <#if .node["@encode"]! == "true">${inlineTemplateSource?html}<#else>${inlineTemplateSource}</#if>
          </#if>
          <#if sri.doBoundaryComments() && textToUse["@no-boundary-comment"]! != "true"><!-- END   render-mode.text[inline][@template=${textToUse["@template"]!"true"}] --></#if>
        </#if>
    </#if>
</#if>
</#macro>

<#macro text><#-- do nothing, is used only through "render-mode" --></#macro>

<#-- ================== Standalone Fields ==================== -->
<#macro link>
    <#assign linkNode = .node>
    <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#if linkNode["@entity-name"]?has_content>
            <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
        <#else>
            <#assign textMap = "">
            <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
            <#if textMap?has_content><#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
                <#else><#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")></#if>
        </#if>
        <#if linkText == "null"><#assign linkText = ""></#if>
        <#if linkText?has_content || linkNode["image"]?has_content || linkNode["@icon"]?has_content>
            <#if linkNode["@encode"]! != "false"><#assign linkText = linkText?html></#if>
            <#assign urlInstance = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
            <#assign linkDivId><@nodeId .node/></#assign>
            <@linkFormForm linkNode linkDivId linkText urlInstance/>
            <@linkFormLink linkNode linkDivId linkText urlInstance/>
        </#if>
    </#if>
</#macro>
<#macro linkFormLink linkNode linkFormId linkText urlInstance>
    <#assign iconClass = linkNode["@icon"]!>
    <#if !iconClass?has_content && linkNode["@text"]?has_content><#assign iconClass = sri.getThemeIconClass(linkNode["@text"])!></#if>
    <#if urlInstance.disableLink>
        <a href="#"<#if linkFormId?has_content> id="${linkFormId}"</#if> class="disabled text-muted <#if linkNode["@link-type"]! != "anchor" && linkNode["@link-type"]! != "hidden-form-link">btn btn-primary btn-sm</#if><#if .node["@style"]?has_content> ${ec.getResource().expandNoL10n(.node["@style"], "")}</#if>"><#if iconClass?has_content><i class="${iconClass}"></i></#if><#if linkNode["image"]?has_content><#visit linkNode["image"][0]><#else>${linkText}</#if></a>
    <#else>
        <#assign confirmationMessage = ec.getResource().expand(linkNode["@confirmation"]!, "")/>
        <#if (linkNode["@link-type"]! == "anchor" || linkNode["@link-type"]! == "anchor-button") ||
            ((!linkNode["@link-type"]?has_content || linkNode["@link-type"] == "auto") &&
             ((linkNode["@url-type"]?has_content && linkNode["@url-type"] != "transition") || (!urlInstance.hasActions)))>
            <#if linkNode["@dynamic-load-id"]?has_content>
                <#-- NOTE: the void(0) is needed for Firefox and other browsers that render the result of the JS expression -->
                <#assign urlText>javascript:{$('#${linkNode["@dynamic-load-id"]}').load('${urlInstance.urlWithParams}'); void(0);}</#assign>
            <#else>
                <#if linkNode["@url-noparam"]! == "true"><#assign urlText = urlInstance.url/>
                    <#else><#assign urlText = urlInstance.urlWithParams/></#if>
            </#if>
            <#rt><a href="${urlText}"<#if linkFormId?has_content> id="${linkFormId}"</#if><#if linkNode["@target-window"]?has_content> target="${linkNode["@target-window"]}"</#if><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if> class="<#if linkNode["@link-type"]! != "anchor">btn btn-primary btn-sm</#if><#if linkNode["@style"]?has_content> ${ec.getResource().expandNoL10n(linkNode["@style"], "")}</#if>"<#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(linkNode["@tooltip"], "")}"</#if>><#if iconClass?has_content><i class="${iconClass}"></i></#if>
            <#t><#if linkNode["image"]?has_content><#visit linkNode["image"][0]><#else>${linkText}</#if>
            <#t></a>
        <#else>
            <#if linkFormId?has_content>
            <#rt><button type="submit" form="${linkFormId}" id="${linkFormId}_button" class="btn btn-primary btn-sm<#if linkNode["@style"]?has_content> ${ec.getResource().expandNoL10n(linkNode["@style"], "")}</#if>"
                    <#t><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if>
                    <#t><#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(linkNode["@tooltip"], "")}"</#if>>
                <#t><#if iconClass?has_content><i class="${iconClass}"></i> </#if>
                <#if linkNode["image"]?has_content>
                    <#t><img src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if>/>
                <#else>
                    <#t>${linkText}
                </#if>
            <#t></button>
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
                <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                <#assign targetParameters = urlInstance.getParameterMap()>
                <#-- NOTE: using .keySet() here instead of ?keys because ?keys was returning all method names with the other keys, not sure why -->
                <#if targetParameters?has_content><#list targetParameters.keySet() as pKey>
                    <input type="hidden" name="${pKey?html}" value="${targetParameters.get(pKey)?default("")?html}"/>
                </#list></#if>
                <#if !linkFormId?has_content>
                    <#assign confirmationMessage = ec.getResource().expand(linkNode["@confirmation"]!, "")/>
                    <#if linkNode["image"]?has_content><#assign imageNode = linkNode["image"][0]/>
                        <input type="image" src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if>>
                    <#else>
                        <#assign iconClass = linkNode["@icon"]!>
                        <#if !iconClass?has_content && linkNode["@text"]?has_content><#assign iconClass = sri.getThemeIconClass(linkNode["@text"])!></#if>
                        <#rt><button type="submit" class="<#if linkNode["@link-type"]! == "hidden-form-link">button-plain<#else>btn btn-primary btn-sm</#if><#if .node["@style"]?has_content> ${ec.getResource().expandNoL10n(.node["@style"], "")}</#if>"
                            <#t><#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}')"</#if>
                            <#t><#if linkNode["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(linkNode["@tooltip"], "")}"</#if>>
                            <#t><#if iconClass?has_content><i class="${iconClass}"></i> </#if>${linkText}</button>
                    </#if>
                </#if>
            </form>
        </#if>
    </#if>
</#macro>

<#macro image>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(.node["@condition"], "")>
        <#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#if .node["@hover"]! == "true"><span class="hover-image-container"></#if>
        <img src="${sri.makeUrlByType(.node["@url"], .node["@url-type"]!"content", .node, "true").getUrlWithParams()}" alt="${.node["@alt"]!"image"}"<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if><#if .node["@width"]?has_content> width="${.node["@width"]}"</#if><#if .node["@height"]?has_content>height="${.node["@height"]}"</#if><#if .node["@style"]?has_content> class="${ec.getResource().expandNoL10n(.node["@style"], "")}"</#if>/>
        <#if .node["@hover"]! == "true"><img src="${sri.makeUrlByType(.node["@url"], .node["@url-type"]!"content", .node, "true").getUrlWithParams()}" class="hover-image" alt="${.node["@alt"]!"image"}"/></span></#if>
    </#if>
</#macro>
<#macro label>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(.node["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#assign labelType = .node["@type"]!"span">
        <#assign textMap = "">
        <#if .node["@text-map"]?has_content><#assign textMap = ec.getResource().expression(.node["@text-map"], "")!></#if>
        <#if textMap?has_content>
            <#assign labelValue = ec.getResource().expand(.node["@text"], "", textMap)>
        <#else>
            <#assign labelValue = ec.getResource().expand(.node["@text"], "")/>
        </#if>
        <#assign labelDivId><@nodeId .node/></#assign>
        <#if labelValue?trim?has_content || .node["@condition"]?has_content>
        <${labelType}<#if labelDivId?has_content> id="${labelDivId}"</#if><#if .node["@style"]?has_content> class="${ec.getResource().expandNoL10n(.node["@style"], "")}"</#if><#if .node["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node["@tooltip"], "")}"</#if>><#if !.node["@encode"]?has_content || .node["@encode"] == "true">${labelValue?html?replace("\n", "<br>")}<#else>${labelValue}</#if></${labelType}>
        </#if>
    </#if>
</#macro>
<#macro editable>
    <#-- for docs on JS usage see: http://www.appelsiini.net/projects/jeditable -->
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
    <#assign urlParms = urlInstance.getParameterMap()>
    <#assign editableDivId><@nodeId .node/></#assign>
    <#assign labelType = .node["@type"]?default("span")>
    <#assign labelValue = ec.getResource().expand(.node["@text"], "")>
    <#assign parameterName = .node["@parameter-name"]!"value">
    <#if labelValue?trim?has_content>
        <${labelType} id="${editableDivId}" class="editable-label"><#if .node["@encode"]! == "true">${labelValue?html?replace("\n", "<br>")}<#else>${labelValue}</#if></${labelType}>
        <script>
        $("#${editableDivId}").editable("${urlInstance.url}", { indicator:"${ec.getL10n().localize("Saving")}",
            tooltip:"${ec.getL10n().localize("Click to edit")}", cancel:"${ec.getL10n().localize("Cancel")}",
            submit:"${ec.getL10n().localize("Save")}", name:"${parameterName}",
            type:"${.node["@widget-type"]!"textarea"}", cssclass:"editable-form",
            submitdata:{<#list urlParms.keySet() as parameterKey>${parameterKey}:"${urlParms[parameterKey]}", </#list>parameterName:"${parameterName}", moquiSessionToken:"${(ec.getWeb().sessionToken)!}"}
            <#if .node["editable-load"]?has_content>
                <#assign loadNode = .node["editable-load"][0]>
                <#assign loadUrlInfo = sri.makeUrlByType(loadNode["@transition"], "transition", loadNode, "true")>
                <#assign loadUrlParms = loadUrlInfo.getParameterMap()>
            , loadurl:"${loadUrlInfo.url}", loadtype:"POST", loaddata:function(value, settings) { return {<#list loadUrlParms.keySet() as parameterKey>${parameterKey}:"${loadUrlParms[parameterKey]}", </#list>currentValue:value, moquiSessionToken:"${(ec.getWeb().sessionToken)!}"}; }
            </#if>});
        </script>
    </#if>
</#macro>
<#macro parameter><#-- do nothing, used directly in other elements --></#macro>

<#-- ============================================================= -->
<#-- ======================= Form Single ========================= -->
<#-- ============================================================= -->

<#macro "form-single">
    <#if sri.doBoundaryComments()><!-- BEGIN form-single[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formInstance = sri.getFormInstance(.node["@name"])>
    <#assign formNode = formInstance.getFormNode()>
    <#t>${sri.pushSingleFormMapContext(formNode)}
    <#assign skipStart = formNode["@skip-start"]! == "true">
    <#assign skipEnd = formNode["@skip-end"]! == "true">
    <#assign ownerForm = formNode["@owner-form"]!>
    <#if ownerForm?has_content><#assign skipStart = true><#assign skipEnd = true></#if>
    <#assign urlInstance = sri.makeUrlByType(formNode["@transition"], "transition", null, "true")>
    <#assign formId>${ec.getResource().expandNoL10n(formNode["@name"], "")}<#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#assign>
    <#if !skipStart>
    <form name="${formId}" id="${formId}" class="validation-engine-init" method="post" action="${urlInstance.url}"<#if formInstance.isUpload()> enctype="multipart/form-data"</#if>>
        <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
        <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
    </#if>
        <fieldset class="form-horizontal"><#-- was form-single-outer -->
        <#if formNode["field-layout"]?has_content>
            <#recurse formNode["field-layout"][0]/>
        <#else>
            <#list formNode["field"] as fieldNode><@formSingleSubField fieldNode formId/></#list>
        </#if>
        </fieldset>
    <#if !skipEnd></form></#if>
    <#if !skipStart>
        <script>
            $("#${formId}").validate({ errorClass: 'help-block', errorElement: 'span',
                highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
            });
            $('#${formId} [data-toggle="tooltip"]').tooltip();

            <#-- if background-submit=true init ajaxForm; for examples see http://www.malsup.com/jquery/form/#ajaxForm -->
            <#if formNode["@background-submit"]! == "true">
            function backgroundSuccess${formId}(responseText, statusText, xhr, $form) {
                <#if formNode["@background-reload-id"]?has_content>
                    load${formNode["@background-reload-id"]}();
                </#if>
                <#if formNode["@background-message"]?has_content>
                    alert("${formNode["@background-message"]}");
                </#if>
                <#if formNode["@background-hide-id"]?has_content>
                    $('#${formNode["@background-hide-id"]}').modal('hide');
                </#if>
            }
            $("#${formId}").ajaxForm({ success: backgroundSuccess${formId}, resetForm: false });
            </#if>
        </script>
    </#if>
    <#if formNode["@focus-field"]?has_content>
        <script>$("#${formId}_${formNode["@focus-field"]}").addClass('default-focus').focus();</script>
    </#if>
    <#t>${sri.popContext()}<#-- context was pushed for the form-single so pop here at the end -->
    <#if sri.doBoundaryComments()><!-- END   form-single[@name=${.node["@name"]}] --></#if>
    <#assign ownerForm = ""><#-- clear ownerForm so later form fields don't pick it up -->
</#macro>
<#macro "field-ref">
    <#assign fieldRef = .node["@name"]>
    <#assign fieldNode = formInstance.getFieldNode(fieldRef)!>
    <#if fieldNode?has_content>
        <@formSingleSubField fieldNode formId/>
    <#else>
        <div>Error: could not find field with name ${fieldRef} referred to in a field-ref.@name attribute.</div>
    </#if>
</#macro>
<#macro "fields-not-referenced">
    <#assign nonReferencedFieldList = formInstance.getFieldLayoutNonReferencedFieldList()>
    <#list nonReferencedFieldList as nonReferencedField>
        <@formSingleSubField nonReferencedField formId/></#list>
</#macro>
<#macro "field-row">
    <#assign fsFieldRow = true>
    <div class="row">
        <#list .node?children as rowChildNode>
            <div class="col-sm-6">
                <#visit rowChildNode/>
            </div><!-- /col-sm-6 not bigRow -->
        </#list>
    </div><#-- /row -->
    <#assign fsFieldRow = false>
</#macro>
<#macro "field-row-big">
    <#-- funny assign here to not render row if there is no content -->
    <#assign fsFieldRow = true><#assign fsBigRow = true>
    <#assign rowContent>
        <#recurse .node/>
    </#assign>
    <#assign rowContent = rowContent?trim>
    <#assign fsFieldRow = false><#assign fsBigRow = false>
    <#if rowContent?has_content>
    <div class="form-group">
    <#if .node["@title"]?has_content>
        <label class="control-label col-sm-2">${ec.getResource().expand(.node["@title"], "")}</label>
        <div class="col-sm-10">
    <#else>
        <div class="col-sm-12">
    </#if>
            ${rowContent}
        </div><#-- /col-sm-12 bigRow -->
    </div><#-- /row -->
    </#if>
</#macro>
<#macro "field-group">
    <#assign fgTitle = ec.getL10n().localize(.node["@title"]!)!>
    <#if isAccordion!false>
        <h3><a href="#">${fgTitle!"Fields"}</a></h3>
        <div<#if .node["@style"]?has_content> class="${.node["@style"]}"</#if>>
            <#recurse .node/>
        </div>
    <#else>
        <div class="form-single-field-group<#if .node["@style"]?has_content> ${.node["@style"]}</#if>">
            <#if fgTitle?has_content><h5>${fgTitle}</h5></#if>
            <#recurse .node/>
        </div>
    </#if>
</#macro>
<#macro "field-accordion">
    <#assign isAccordion = true>
    <#assign accordionId = .node["@id"]!(formId + "_accordion")>
    <#assign collapsible = .node["@collapsible"]! == "true">
    <#assign active = .node["@active"]!>
    <div id="${accordionId}">
        <#recurse .node/>
    </div><!-- /collapsible accordionId ${accordionId} -->
    <script>$("#${accordionId}").accordion({ collapsible: <#if collapsible>true<#else>false</#if>,<#if active?has_content> active: ${active},</#if> heightStyle: "content" });</script>
    <#assign isAccordion = false>
</#macro>

<#macro formSingleSubField fieldNode formId>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.getResource().condition(fieldSubNode["@condition"], "")>
            <@formSingleWidget fieldSubNode formId "col-sm" fsFieldRow!false fsBigRow!false/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <@formSingleWidget fieldNode["default-field"][0] formId "col-sm" fsFieldRow!false fsBigRow!false/>
        <#return>
    </#if>
</#macro>
<#macro formSingleWidget fieldSubNode formId colPrefix inFieldRow bigRow>
    <#assign fieldSubParent = fieldSubNode?parent>
    <#if fieldSubNode["ignored"]?has_content><#return></#if>
    <#if ec.getResource().condition(fieldSubParent["@hide"]!, "")><#return></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return></#if>
    <#assign containerStyle = ec.getResource().expandNoL10n(fieldSubNode["@container-style"]!, "")>
    <#assign curFieldTitle><@fieldTitle fieldSubNode/></#assign>
    <#if bigRow>
        <div class="big-row-item">
            <div class="form-group">
                <#if curFieldTitle?has_content && !fieldSubNode["submit"]?has_content>
                    <label class="control-label" for="${formId}_${fieldSubParent["@name"]}">${curFieldTitle}</label><#-- was form-title -->
                </#if>
    <#else>
        <#if fieldSubNode["submit"]?has_content>
        <div class="form-group">
            <div class="<#if inFieldRow>${colPrefix}-4<#else>${colPrefix}-2</#if>"> </div>
            <div class="<#if inFieldRow>${colPrefix}-8<#else>${colPrefix}-10</#if><#if containerStyle?has_content> ${containerStyle}</#if>">
        <#elseif !(inFieldRow! && !curFieldTitle?has_content)>
        <div class="form-group">
            <label class="control-label <#if inFieldRow>${colPrefix}-4<#else>${colPrefix}-2</#if>" for="${formId}_${fieldSubParent["@name"]}">${curFieldTitle}</label><#-- was form-title -->
            <div class="<#if inFieldRow>${colPrefix}-8<#else>${colPrefix}-10</#if><#if containerStyle?has_content> ${containerStyle}</#if>">
        </#if>
    </#if>
    <#-- NOTE: this style is only good for 2 fields in a field-row! in field-row cols are double size because are inside a ${colPrefix}-6 element -->
    <#t>${sri.pushContext()}
    <#assign fieldFormId = formId><#-- set this globally so fieldId macro picks up the proper formId, clear after -->
    <#list fieldSubNode?children as widgetNode><#if widgetNode?node_name == "set">${sri.setInContext(widgetNode)}</#if></#list>
    <#list fieldSubNode?children as widgetNode>
        <#if widgetNode?node_name == "link">
            <#assign linkNode = widgetNode>
            <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
            <#if conditionResult>
                <#if linkNode["@entity-name"]?has_content>
                    <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
                <#else>
                    <#assign textMap = "">
                    <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
                    <#if textMap?has_content><#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
                        <#else><#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")></#if>
                </#if>
                <#if linkText == "null"><#assign linkText = ""></#if>
                <#if linkText?has_content || linkNode["image"]?has_content || linkNode["@icon"]?has_content>
                    <#if linkNode["@encode"]! != "false"><#assign linkText = linkText?html></#if>
                    <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
                    <#assign linkFormId><@fieldId linkNode/></#assign>
                    <#assign afterFormText><@linkFormForm linkNode linkFormId linkText linkUrlInfo/></#assign>
                    <#t>${sri.appendToAfterScreenWriter(afterFormText)}
                    <#t><@linkFormLink linkNode linkFormId linkText linkUrlInfo/>
                </#if>
            </#if>
        <#elseif widgetNode?node_name == "set"><#-- do nothing, handled above -->
        <#else><#t><#visit widgetNode>
        </#if>
    </#list>
    <#assign fieldFormId = ""><#-- clear after field so nothing else picks it up -->
    <#t>${sri.popContext()}
    <#if bigRow>
        <#-- <#if curFieldTitle?has_content></#if> -->
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

<#-- =========================================================== -->
<#-- ======================= Form List ========================= -->
<#-- =========================================================== -->

<#macro paginationHeaderModals formListInfo formId isHeaderDialog>
    <#assign formNode = formListInfo.getFormNode()>
    <#assign allColInfoList = formListInfo.getAllColInfo()>
    <#assign isSavedFinds = formNode["@saved-finds"]! == "true">
    <#assign isSelectColumns = formNode["@select-columns"]! == "true">
    <#assign currentFindUrl = sri.getScreenUrlInstance().cloneUrlInstance().removeParameter("pageIndex").removeParameter("moquiFormName").removeParameter("moquiSessionToken").removeParameter("formListFindId")>
    <#assign currentFindUrlParms = currentFindUrl.getParameterMap()>
    <#if isSavedFinds || isHeaderDialog>
        <#assign headerFormDialogId = formId + "_hdialog">
        <#assign headerFormId = formId + "_header">
        <#assign headerFormButtonText = ec.getL10n().localize("Find Options")>
        <div id="${headerFormDialogId}" class="modal" aria-hidden="true" style="display: none;" tabindex="-1">
            <div class="modal-dialog" style="width: 800px;"><div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${headerFormButtonText}</h4>
                </div>
                <div class="modal-body">
                <#-- Saved Finds -->
                <#if isSavedFinds && isHeaderDialog><h4 style="margin-top: 0;">${ec.getL10n().localize("Saved Finds")}</h4></#if>
                <#if isSavedFinds>
                    <#assign activeFormListFind = formListInfo.getFormInstance().getActiveFormListFind(ec)!>
                    <#assign formSaveFindUrl = sri.buildUrl("formSaveFind").url>
                    <#assign descLabel = ec.getL10n().localize("Description")>
                    <#if activeFormListFind?has_content>
                        <h5>Active Saved Find: ${activeFormListFind.description?html}</h5>
                    </#if>
                    <#if currentFindUrlParms?has_content>
                        <div><form class="form-inline" id="${formId}_NewFind" method="post" action="${formSaveFindUrl}">
                            <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                            <input type="hidden" name="formLocation" value="${formInstance.getFormLocation()}">
                            <#list currentFindUrlParms.keySet() as parmName>
                                <input type="hidden" name="${parmName}" value="${currentFindUrlParms.get(parmName)!?html}">
                            </#list>
                            <div class="form-group">
                                <label class="sr-only" for="${formId}_NewFind_description">${descLabel}</label>
                                <input type="text" class="form-control" size="40" name="description" id="${formId}_NewFind_description" placeholder="${descLabel}">
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm">${ec.getL10n().localize("Save New Find")}</button>
                        </form></div>
                    <#else>
                        <p>${ec.getL10n().localize("No find parameters, choose some to save a new find or update existing")}</p>
                    </#if>
                    <#assign userFindInfoList = formListInfo.getUserFormListFinds(ec)>
                    <#list userFindInfoList as userFindInfo>
                        <#assign formListFind = userFindInfo.formListFind>
                        <#assign findParameters = userFindInfo.findParameters>
                        <#assign doFindUrl = sri.getScreenUrlInstance().cloneUrlInstance().addParameters(findParameters).removeParameter("pageIndex").removeParameter("moquiFormName").removeParameter("moquiSessionToken")>
                        <#assign saveFindFormId = formId + "_SaveFind" + userFindInfo_index>
                        <div>
                        <#if currentFindUrlParms?has_content>
                            <form class="form-inline" id="${saveFindFormId}" method="post" action="${formSaveFindUrl}">
                                <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                                <input type="hidden" name="formLocation" value="${formListInfo.getFormLocation()}">
                                <input type="hidden" name="formListFindId" value="${formListFind.formListFindId}">
                                <#list currentFindUrlParms.keySet() as parmName>
                                    <input type="hidden" name="${parmName}" value="${currentFindUrlParms.get(parmName)!?html}">
                                </#list>
                                <div class="form-group">
                                    <label class="sr-only" for="${saveFindFormId}_description">${descLabel}</label>
                                    <input type="text" class="form-control" size="40" name="description" id="${saveFindFormId}_description" value="${formListFind.description?html}">
                                </div>
                                <button type="submit" name="UpdateFind" class="btn btn-primary btn-sm">${ec.getL10n().localize("Update to Current")}</button>
                                <#if userFindInfo.isByUserId == "true"><button type="submit" name="DeleteFind" class="btn btn-danger btn-sm" onclick="return confirm('${ec.getL10n().localize("Delete")} ${formListFind.description?js_string}?');">&times;</button></#if>
                            </form>
                            <a href="${doFindUrl.urlWithParams}" class="btn btn-success btn-sm">${ec.getL10n().localize("Do Find")}</a>
                        <#else>
                            <a href="${doFindUrl.urlWithParams}" class="btn btn-success btn-sm">${ec.getL10n().localize("Do Find")}</a>
                            <#if userFindInfo.isByUserId == "true">
                            <form class="form-inline" id="${saveFindFormId}" method="post" action="${formSaveFindUrl}">
                                <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                                <input type="hidden" name="formListFindId" value="${formListFind.formListFindId}">
                                <button type="submit" name="DeleteFind" class="btn btn-danger btn-sm" onclick="return confirm('${ec.getL10n().localize("Delete")} ${formListFind.description?js_string}?');">&times;</button>
                            </form>
                            </#if>
                            <strong>${formListFind.description?html}</strong>
                        </#if>
                        </div>
                    </#list>
                </#if>
                <#if isSavedFinds && isHeaderDialog><h4>${ec.getL10n().localize("Find Parameters")}</h4></#if>
                <#if isHeaderDialog>
                    <#-- Find Parameters Form -->
                    <#assign curUrlInstance = sri.getCurrentScreenUrl()>
                    <form name="${headerFormId}" id="${headerFormId}" method="post" action="${curUrlInstance.url}">
                        <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                        <fieldset class="form-horizontal">
                            <#-- Always add an orderByField to select one or more columns to order by -->
                            <div class="form-group">
                                <label class="control-label col-sm-2" for="${headerFormId}_orderByField">${ec.getL10n().localize("Order By")}</label>
                                <div class="col-sm-10">
                                    <select name="orderBySelect" id="${headerFormId}_orderBySelect" multiple="multiple" style="width: 100%;">
                                        <#list formNode["field"] as fieldNode><#if fieldNode["header-field"]?has_content>
                                            <#assign headerFieldNode = fieldNode["header-field"][0]>
                                            <#assign showOrderBy = (headerFieldNode["@show-order-by"])!>
                                            <#if showOrderBy?has_content && showOrderBy != "false">
                                                <#assign caseInsensitive = showOrderBy == "case-insensitive">
                                                <#assign orderFieldName = fieldNode["@name"]>
                                                <#assign orderFieldTitle><@fieldTitle headerFieldNode/></#assign>
                                                <option value="${"+" + caseInsensitive?string("^", "") + orderFieldName}">${orderFieldTitle} ${ec.getL10n().localize("(Asc)")}</option>
                                                <option value="${"-" + caseInsensitive?string("^", "") + orderFieldName}">${orderFieldTitle} ${ec.getL10n().localize("(Desc)")}</option>
                                            </#if>
                                        </#if></#list>
                                    </select>
                                    <input type="hidden" id="${headerFormId}_orderByField" name="orderByField" value="${orderByField!""}">
                                    <script>
                                        $("#${headerFormId}_orderBySelect").selectivity({ positionDropdown: function(dropdownEl, selectEl) { dropdownEl.css("width", "300px"); } })[0].selectivity.filterResults = function(results) {
                                            // Filter out asc and desc options if anyone selected.
                                            return results.filter(function(item){return !this._data.some(function(data_item) {return data_item.id.substring(1) === item.id.substring(1);});}, this);
                                        };
                                        <#assign orderByJsValue = formListInfo.getOrderByActualJsString(ec.getContext().orderByField)>
                                        <#if orderByJsValue?has_content>$("#${headerFormId}_orderBySelect").selectivity("value", ${orderByJsValue});</#if>
                                        $("div#${headerFormId}_orderBySelect").on("change", function(evt) {
                                            if (evt.value) $("#${headerFormId}_orderByField").val(evt.value.join(","));
                                        });
                                    </script>
                                </div>
                            </div>
                            <#list formNode["field"] as fieldNode><#if fieldNode["header-field"]?has_content && fieldNode["header-field"][0]?children?has_content>
                                <#assign headerFieldNode = fieldNode["header-field"][0]>
                                <#assign defaultFieldNode = (fieldNode["default-field"][0])!>
                                <#assign allHidden = true>
                                <#list fieldNode?children as fieldSubNode>
                                    <#if !(fieldSubNode["hidden"]?has_content || fieldSubNode["ignored"]?has_content)><#assign allHidden = false></#if>
                                </#list>

                                <#if !(ec.getResource().condition(fieldNode["@hide"]!, "") || allHidden ||
                                        ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                        ((fieldNode["header-field"][0]["hidden"])?has_content || (fieldNode["header-field"][0]["ignored"])?has_content)))>
                                    <@formSingleWidget headerFieldNode headerFormId "col-sm" false false/>
                                <#elseif (headerFieldNode["hidden"])?has_content>
                                    <#recurse headerFieldNode/>
                                </#if>
                            </#if></#list>
                        </fieldset>
                    </form>
                </#if>
                </div>
            </div></div>
        </div>
        <script>$('#${headerFormDialogId}').on('shown.bs.modal', function() { $("#${headerFormDialogId} select:not([name='orderBySelect'])").select2({ ${select2DefaultOptions} }); })</script>
    </#if>
    <#if isSelectColumns>
        <#assign selectColumnsDialogId = formId + "_SelColsDialog">
        <#assign selectColumnsSortableId = formId + "_SelColsSortable">
        <#assign fieldsNotInColumns = formListInfo.getFieldsNotReferencedInFormListColumn()>
        <div id="${selectColumnsDialogId}" class="modal" aria-hidden="true" style="display: none;" tabindex="-1">
            <div class="modal-dialog" style="width: 600px;"><div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${ec.getL10n().localize("Column Fields")}</h4>
                </div>
                <div class="modal-body">
                    <p>Drag fields to the desired column or do not display</p>
                    <ul id="${selectColumnsSortableId}">
                        <li id="hidden"><div>Do Not Display</div>
                            <#if fieldsNotInColumns?has_content>
                            <ul>
                            <#list fieldsNotInColumns as fieldNode>
                                <#assign fieldSubNode = (fieldNode["header-field"][0])!(fieldNode["default-field"][0])!>
                                <li id="${fieldNode["@name"]}"><div><@fieldTitle fieldSubNode/></div></li>
                            </#list>
                            </ul>
                            </#if>
                        </li>
                        <#list allColInfoList as columnFieldList>
                            <li id="column_${columnFieldList_index}"><div>Column ${columnFieldList_index + 1}</div><ul>
                            <#list columnFieldList as fieldNode>
                                <#assign fieldSubNode = (fieldNode["header-field"][0])!(fieldNode["default-field"][0])!>
                                <li id="${fieldNode["@name"]}"><div><@fieldTitle fieldSubNode/></div></li>
                            </#list>
                            </ul></li>
                        </#list>
                        <#if allColInfoList?size < 10><#list allColInfoList?size..9 as ind>
                            <li id="column_${ind}"><div>Column ${ind + 1}</div></li>
                        </#list></#if>
                    </ul>
                    <form class="form-inline" id="${formId}_SelColsForm" method="post" action="${sri.buildUrl("formSelectColumns").url}">
                        <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
                        <input type="hidden" name="formLocation" value="${formListInfo.getFormLocation()}">
                        <input type="hidden" id="${formId}_SelColsForm_columnsTree" name="columnsTree" value="">
                        <#if currentFindUrlParms?has_content><#list currentFindUrlParms.keySet() as parmName>
                            <input type="hidden" name="${parmName}" value="${currentFindUrlParms.get(parmName)!?html}">
                        </#list></#if>
                        <input type="submit" name="SaveColumns" value="${ec.getL10n().localize("Save Columns")}" class="btn btn-primary btn-sm"/>
                        <input type="submit" name="ResetColumns" value="${ec.getL10n().localize("Reset to Default")}" class="btn btn-primary btn-sm"/>
                    </form>
                </div>
            </div></div>
        </div>
        <script>$('#${selectColumnsDialogId}').on('shown.bs.modal', function() {
            $("#${selectColumnsSortableId}").sortableLists({
                isAllowed: function(currEl, hint, target) {
                    <#-- don't allow hidden and column items to be moved; only allow others to be under hidden or column items -->
                    if (currEl.attr('id') === 'hidden' || currEl.attr('id').startsWith('column_')) {
                        if (!target.attr('id') || (target.attr('id') != 'hidden' && !currEl.attr('id').startsWith('column_'))) { hint.css('background-color', '#99ff99'); return true; }
                        else { hint.css('background-color', '#ff9999'); return false; }
                    }
                    if (target.attr('id') && (target.attr('id') === 'hidden' || target.attr('id').startsWith('column_'))) { hint.css('background-color', '#99ff99'); return true; }
                    else { hint.css('background-color', '#ff9999'); return false; }
                },
                placeholderCss: {'background-color':'#999999'}, insertZone: 50,
                <#-- jquery-sortable-lists currently logs an error if opener.as is not set to html or class -->
                opener: { active:false, as:'html', close:'', open:'' },
                onChange: function(cEl) {
                    var sortableHierarchy = $('#${selectColumnsSortableId}').sortableListsToHierarchy();
                    // console.log(sortableHierarchy); console.log(JSON.stringify(sortableHierarchy));
                    $("#${formId}_SelColsForm_columnsTree").val(JSON.stringify(sortableHierarchy));
                }
            });
            $("#${formId}_SelColsForm_columnsTree").val(JSON.stringify($('#${selectColumnsSortableId}').sortableListsToHierarchy()));
        })</script>
    </#if>
    <#if formNode["@show-text-button"]! == "true">
        <#assign showTextDialogId = formId + "_TextDialog">
        <#assign textLinkUrl = sri.getScreenUrlInstance()>
        <#assign textLinkUrlParms = textLinkUrl.getParameterMap()>
        <div id="${showTextDialogId}" class="modal" aria-hidden="true" style="display: none;" tabindex="-1">
            <div class="modal-dialog" style="width: 600px;"><div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${ec.getL10n().localize("Export Fixed-Width Plain Text")}</h4>
                </div>
                <div class="modal-body">
                    <form id="${formId}_Text" method="post" action="${textLinkUrl.getUrl()}">
                        <input type="hidden" name="renderMode" value="text">
                        <input type="hidden" name="pageNoLimit" value="true">
                        <input type="hidden" name="lastStandalone" value="true">
                        <#list textLinkUrlParms.keySet() as parmName>
                            <input type="hidden" name="${parmName}" value="${textLinkUrlParms.get(parmName)!?html}"></#list>
                        <fieldset class="form-horizontal">
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="${formId}_Text_lineCharacters">${ec.getL10n().localize("Line Characters")}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" size="4" name="lineCharacters" id="${formId}_Text_lineCharacters" value="132">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="${formId}_Text_lineWrap">${ec.getL10n().localize("Line Wrap?")}</label>
                                <div class="col-sm-9">
                                    <input type="checkbox" class="form-control" name="lineWrap" id="${formId}_Text_lineWrap" value="true">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="${formId}_Text_saveFilename">${ec.getL10n().localize("Save to Filename")}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" size="40" name="saveFilename" id="${formId}_Text_saveFilename" value="${formNode["@name"] + ".txt"}">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-default">${ec.getL10n().localize("Export Text")}</button>
                        </fieldset>
                    </form>
                </div>
            </div></div>
        </div>
    </#if>
    <#if formNode["@show-pdf-button"]! == "true">
        <#assign showPdfDialogId = formId + "_PdfDialog">
        <#assign pdfLinkUrl = sri.getScreenUrlInstance()>
        <#assign pdfLinkUrlParms = pdfLinkUrl.getParameterMap()>
        <div id="${showPdfDialogId}" class="modal" aria-hidden="true" style="display: none;" tabindex="-1">
            <div class="modal-dialog" style="width: 600px;"><div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">${ec.getL10n().localize("Generate PDF")}</h4>
                </div>
                <div class="modal-body">
                    <form id="${formId}_Pdf" method="post" action="${ec.web.getWebappRootUrl(false, null)}/fop${pdfLinkUrl.getScreenPath()}">
                        <input type="hidden" name="pageNoLimit" value="true">
                        <#list pdfLinkUrlParms.keySet() as parmName>
                            <input type="hidden" name="${parmName}" value="${pdfLinkUrlParms.get(parmName)!?html}"></#list>
                        <fieldset class="form-horizontal">
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="${formId}_Pdf_layoutMaster">${ec.getL10n().localize("Page Layout")}</label>
                                <div class="col-sm-9">
                                    <select name="layoutMaster"  id="${formId}_Pdf_layoutMaster" class="form-control">
                                        <option value="letter-landscape">US Letter - Landscape (11x8.5)</option>
                                        <option value="letter-portrait">US Letter - Portrait (8.5x11)</option>
                                        <option value="legal-landscape">US Legal - Landscape (14x8.5)</option>
                                        <option value="legal-portrait">US Legal - Portrait (8.5x14)</option>
                                        <option value="tabloid-landscape">US Tabloid - Landscape (17x11)</option>
                                        <option value="tabloid-portrait">US Tabloid - Portrait (11x17)</option>
                                        <option value="a4-landscape">A4 - Landscape (297x210)</option>
                                        <option value="a4-portrait">A4 - Portrait (210x297)</option>
                                        <option value="a3-landscape">A3 - Landscape (420x297)</option>
                                        <option value="a3-portrait">A3 - Portrait (297x420)</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-3" for="${formId}_Pdf_saveFilename">${ec.getL10n().localize("Save to Filename")}</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" size="40" name="saveFilename" id="${formId}_Pdf_saveFilename" value="${formNode["@name"] + ".pdf"}">
                                </div>
                            </div>
                            <button type="submit" class="btn btn-default">${ec.getL10n().localize("Generate PDF")}</button>
                        </fieldset>
                    </form>
                    <script>$("#${formId}_Pdf_layoutMaster").select2({ ${select2DefaultOptions} });</script>
                </div>
            </div></div>
        </div>
    </#if>
</#macro>
<#macro paginationHeader formListInfo formId isHeaderDialog>
    <#assign formNode = formListInfo.getFormNode()>
    <#assign mainColInfoList = formListInfo.getMainColInfo()>
    <#assign numColumns = (mainColInfoList?size)!100>
    <#if numColumns == 0><#assign numColumns = 100></#if>
    <#assign isSavedFinds = formNode["@saved-finds"]! == "true">
    <#assign isSelectColumns = formNode["@select-columns"]! == "true">
    <#assign isPaginated = !(formNode["@paginate"]! == "false") && context[listName + "Count"]?? && (context[listName + "Count"]! > 0) &&
            (!formNode["@paginate-always-show"]?has_content || formNode["@paginate-always-show"]! == "true" || (context[listName + "PageMaxIndex"] > 0))>
    <#if (isHeaderDialog || isSavedFinds || isSelectColumns || isPaginated) && hideNav! != "true">
        <tr class="form-list-nav-row"><th colspan="${numColumns}">
        <nav class="form-list-nav">
            <#if isSavedFinds>
                <#assign userFindInfoList = formListInfo.getUserFormListFinds(ec)>
                <#if userFindInfoList?has_content>
                    <#assign quickSavedFindId = formId + "_QuickSavedFind">
                    <select id="${quickSavedFindId}">
                        <option></option><#-- empty option for placeholder -->
                        <option value="_clear" data-action="${sri.getScreenUrlInstance().url}">${ec.getL10n().localize("Clear Current Find")}</option>
                        <#list userFindInfoList as userFindInfo>
                            <#assign formListFind = userFindInfo.formListFind>
                            <#assign findParameters = userFindInfo.findParameters>
                            <#assign doFindUrl = sri.getScreenUrlInstance().cloneUrlInstance().addParameters(findParameters).removeParameter("pageIndex").removeParameter("moquiFormName").removeParameter("moquiSessionToken")>
                            <option value="${formListFind.formListFindId}"<#if formListFind.formListFindId == ec.getContext().formListFindId!> selected="selected"</#if> data-action="${doFindUrl.urlWithParams}">${userFindInfo.description?html}</option>
                        </#list>
                    </select>
                    <script>
                        $("#${quickSavedFindId}").select2({ ${select2DefaultOptions}, placeholder:'${ec.getL10n().localize("Saved Finds")}' });
                        $("#${quickSavedFindId}").on('select2:select', function(evt) {
                            var dataAction = $(evt.params.data.element).attr("data-action");
                            if (dataAction) window.open(dataAction, "_self");
                        } );
                    </script>
                </#if>
            </#if>
            <#if isSavedFinds || isHeaderDialog><button id="${headerFormDialogId}_button" type="button" data-toggle="modal" data-target="#${headerFormDialogId}" data-original-title="${headerFormButtonText}" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> ${headerFormButtonText}</button></#if>
            <#if isSelectColumns><button id="${selectColumnsDialogId}_button" type="button" data-toggle="modal" data-target="#${selectColumnsDialogId}" data-original-title="${ec.getL10n().localize("Columns")}" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> ${ec.getL10n().localize("Columns")}</button></#if>

            <#if isPaginated>
                <#assign curPageIndex = context[listName + "PageIndex"]>
                <#assign curPageMaxIndex = context[listName + "PageMaxIndex"]>
                <#assign prevPageIndexMin = curPageIndex - 3><#if (prevPageIndexMin < 0)><#assign prevPageIndexMin = 0></#if>
                <#assign prevPageIndexMax = curPageIndex - 1><#assign nextPageIndexMin = curPageIndex + 1>
                <#assign nextPageIndexMax = curPageIndex + 3><#if (nextPageIndexMax > curPageMaxIndex)><#assign nextPageIndexMax = curPageMaxIndex></#if>
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
                <#assign paginationTemplate = ec.getL10n().localize("PaginationTemplate")?interpret>
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
                    <#assign goPageUrl = sri.getScreenUrlInstance().cloneUrlInstance().removeParameter("pageIndex").removeParameter("moquiFormName").removeParameter("moquiSessionToken")>
                    <#assign goPageUrlParms = goPageUrl.getParameterMap()>
                    <form class="form-inline" id="${formId}_GoPage" method="post" action="${goPageUrl.getUrl()}">
                        <#list goPageUrlParms.keySet() as parmName>
                            <input type="hidden" name="${parmName}" value="${goPageUrlParms.get(parmName)!?html}"></#list>
                        <div class="form-group">
                            <label class="sr-only" for="${formId}_GoPage_pageIndex">Page Number</label>
                            <input type="text" class="form-control" size="6" name="pageIndex" id="${formId}_GoPage_pageIndex" placeholder="${ec.getL10n().localize("Page #")}">
                        </div>
                        <button type="submit" class="btn btn-default">${ec.getL10n().localize("Go##Page")}</button>
                    </form>
                    <script>
                        $("#${formId}_GoPage").validate({ errorClass: 'help-block', errorElement: 'span',
                            rules: { pageIndex: { required:true, min:1, max:${(curPageMaxIndex + 1)?c} } },
                            highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                            unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); },
                            <#-- show 1-based index to user but server expects 0-based index -->
                            submitHandler: function(form) { $("#${formId}_GoPage_pageIndex").val($("#${formId}_GoPage_pageIndex").val() - 1); form.submit(); }
                        });
                    </script>
                </#if>
                <#if formNode["@show-all-button"]! == "true" && (context[listName + 'Count'] < 500)>
                    <#if context["pageNoLimit"]?has_content>
                        <#assign allLinkUrl = sri.getScreenUrlInstance().cloneUrlInstance().removeParameter("pageNoLimit")>
                        <a href="${allLinkUrl.getUrlWithParams()}" class="btn btn-default">Paginate</a>
                    <#else>
                        <#assign allLinkUrl = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("pageNoLimit", "true")>
                        <a href="${allLinkUrl.getUrlWithParams()}" class="btn btn-default">Show All</a>
                    </#if>
                </#if>
            </#if>

            <#if formNode["@show-csv-button"]! == "true">
                <#assign csvLinkUrl = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("renderMode", "csv")
                        .addParameter("pageNoLimit", "true").addParameter("lastStandalone", "true").addParameter("saveFilename", formNode["@name"] + ".csv")>
                <a href="${csvLinkUrl.getUrlWithParams()}" class="btn btn-default">${ec.getL10n().localize("CSV")}</a>
            </#if>
            <#if formNode["@show-text-button"]! == "true">
                <#assign showTextDialogId = formId + "_TextDialog">
                <button id="${showTextDialogId}_button" type="button" data-toggle="modal" data-target="#${showTextDialogId}" data-original-title="${ec.getL10n().localize("Text")}" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> ${ec.getL10n().localize("Text")}</button>
            </#if>
            <#if formNode["@show-pdf-button"]! == "true">
                <#assign showPdfDialogId = formId + "_PdfDialog">
                <button id="${showPdfDialogId}_button" type="button" data-toggle="modal" data-target="#${showPdfDialogId}" data-original-title="${ec.getL10n().localize("PDF")}" data-placement="bottom" class="btn btn-default"><i class="glyphicon glyphicon-share"></i> ${ec.getL10n().localize("PDF")}</button>
            </#if>
        </nav>
        </th></tr>
    </#if>
</#macro>
<#macro "form-list">
    <#if sri.doBoundaryComments()><!-- BEGIN form-list[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formInstance = sri.getFormInstance(.node["@name"])>
    <#assign formListInfo = formInstance.makeFormListRenderInfo()>
    <#assign formNode = formListInfo.getFormNode()>
    <#assign mainColInfoList = formListInfo.getMainColInfo()>
    <#assign subColInfoList = formListInfo.getSubColInfo()!>
    <#assign hasSubColumns = subColInfoList?has_content>
    <#assign numColumns = (mainColInfoList?size)!100>
    <#if numColumns == 0><#assign numColumns = 100></#if>
    <#assign formId>${ec.getResource().expandNoL10n(formNode["@name"], "")}<#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#assign>
    <#assign headerFormId = formId + "_header">
    <#assign skipStart = (formNode["@skip-start"]! == "true")>
    <#assign skipEnd = (formNode["@skip-end"]! == "true")>
    <#assign skipForm = (formNode["@skip-form"]! == "true")>
    <#assign skipHeader = !skipStart && (formNode["@skip-header"]! == "true")>
    <#assign needHeaderForm = !skipHeader && formListInfo.isHeaderForm()>
    <#assign isHeaderDialog = needHeaderForm && formNode["@header-dialog"]! == "true">
    <#assign isMulti = !skipForm && formNode["@multi"]! == "true">
    <#assign formListUrlInfo = sri.makeUrlByType(formNode["@transition"], "transition", null, "false")>
    <#assign listName = formNode["@list"]>
    <#assign listObject = formListInfo.getListObject(true)!>
    <#assign listHasContent = listObject?has_content>

    <#-- all form elements outside table element and referred to with input/etc.@form attribute for proper HTML -->
    <#if !(isMulti || skipForm) && listHasContent><#list listObject as listEntry>
        ${sri.startFormListRow(formListInfo, listEntry, listEntry_index, listEntry_has_next)}
        <form name="${formId}_${listEntry_index}" id="${formId}_${listEntry_index}" method="post" action="${formListUrlInfo.url}">
            <#assign listEntryIndex = listEntry_index>
            <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
            <#-- hidden fields -->
            <#assign hiddenFieldList = formListInfo.getListHiddenFieldList()>
            <#list hiddenFieldList as hiddenField><@formListSubField hiddenField true false isMulti false/></#list>
            <#assign listEntryIndex = "">
        </form>
        ${sri.endFormListRow()}
    </#list></#if>
    <#if !skipStart>
        <#if needHeaderForm && !isHeaderDialog>
            <#assign curUrlInstance = sri.getCurrentScreenUrl()>
        <form name="${headerFormId}" id="${headerFormId}" method="post" action="${curUrlInstance.url}">
            <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
            <#if orderByField?has_content><input type="hidden" name="orderByField" value="${orderByField}"></#if>
            <#assign hiddenFieldList = formListInfo.getListHiddenFieldList()>
            <#list hiddenFieldList as hiddenField><#if hiddenField["header-field"]?has_content><#recurse hiddenField["header-field"][0]/></#if></#list>
        </form>
        </#if>
        <#if isMulti>
        <form name="${formId}" id="${formId}" method="post" action="${formListUrlInfo.url}">
            <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
            <input type="hidden" name="moquiSessionToken" value="${(ec.getWeb().sessionToken)!}">
            <input type="hidden" name="_isMulti" value="true">
            <#if listHasContent><#list listObject as listEntry>
                <#assign listEntryIndex = listEntry_index>
                ${sri.startFormListRow(formListInfo, listEntry, listEntry_index, listEntry_has_next)}
                <#-- hidden fields -->
                <#assign hiddenFieldList = formListInfo.getListHiddenFieldList()>
                <#list hiddenFieldList as hiddenField><@formListSubField hiddenField true false isMulti false/></#list>
                ${sri.endFormListRow()}
                <#assign listEntryIndex = "">
            </#list></#if>
        </form>
        </#if>

        <#if !skipHeader><@paginationHeaderModals formListInfo formId isHeaderDialog/></#if>
        <table class="table table-striped table-hover table-condensed" id="${formId}_table">
        <#if !skipHeader>
            <thead>
                <@paginationHeader formListInfo formId isHeaderDialog/>

                <#assign ownerForm = headerFormId>
                <tr>
                <#list mainColInfoList as columnFieldList>
                    <#-- TODO: how to handle column style? <th<#if fieldListColumn["@style"]?has_content> class="${fieldListColumn["@style"]}"</#if>> -->
                    <th>
                    <#list columnFieldList as fieldNode>
                        <#if !(ec.getResource().condition(fieldNode["@hide"]!, "") ||
                                ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
                            <div><@formListHeaderField fieldNode isHeaderDialog/></div>
                        </#if>
                    </#list>
                    </th>
                </#list>
                </tr>
                <#if hasSubColumns>
                    <tr><td colspan="${numColumns}" class="form-list-sub-row-cell"><div class="form-list-sub-rows"><table class="table table-striped table-hover table-condensed"><thead>
                        <#list subColInfoList as subColFieldList><th>
                            <#list subColFieldList as fieldNode>
                                <#if !(ec.getResource().condition(fieldNode["@hide"]!, "") ||
                                ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
                                    <div><@formListHeaderField fieldNode isHeaderDialog/></div>
                                </#if>
                            </#list>
                        </th></#list>
                    </thead></table></div></td></tr>
                </#if>
                <#if needHeaderForm>
                    <#if _dynamic_container_id?has_content>
                        <#-- if we have an _dynamic_container_id this was loaded in a dynamic-container so init ajaxForm; for examples see http://www.malsup.com/jquery/form/#ajaxForm -->
                        <script>$("#${headerFormId}").ajaxForm({ target: '#${_dynamic_container_id}', <#-- success: activateAllButtons, --> resetForm: false });</script>
                    </#if>
                </#if>
                <#assign ownerForm = "">
            </thead>
        </#if>
            <tbody>
            <#assign ownerForm = formId>
    </#if>
    <#if listHasContent><#list listObject as listEntry>
        <#assign listEntryIndex = listEntry_index>
        <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
        ${sri.startFormListRow(formListInfo, listEntry, listEntry_index, listEntry_has_next)}
        <tr>
        <#if !(isMulti || skipForm)><#assign ownerForm = formId + "_" + listEntry_index></#if>
        <#-- actual columns -->
        <#list mainColInfoList as columnFieldList>
            <td>
            <#list columnFieldList as fieldNode>
                <@formListSubField fieldNode true false isMulti false/>
            </#list>
            </td>
        </#list>
        <#if hasSubColumns><#assign aggregateSubList = listEntry["aggregateSubList"]!><#if aggregateSubList?has_content>
            </tr>
            <tr><td colspan="${numColumns}" class="form-list-sub-row-cell"><div class="form-list-sub-rows"><table class="table table-striped table-hover table-condensed">
                <#list aggregateSubList as subListEntry><tr>
                    ${sri.startFormListSubRow(formListInfo, subListEntry, subListEntry_index, subListEntry_has_next)}
                    <#list subColInfoList as subColFieldList><td>
                        <#list subColFieldList as fieldNode>
                            <@formListSubField fieldNode true false isMulti false/>
                        </#list>
                    </td></#list>
                    ${sri.endFormListSubRow()}
                </tr></#list>
            </table></div></td><#-- note no /tr, let following blocks handle it -->
        </#if></#if>
        </tr>
        <#if !(isMulti || skipForm)>
            <script>
                $("#${formId}_${listEntryIndex}").validate({ errorClass: 'help-block', errorElement: 'span',
                    highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                    unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
                });
            </script>
            <#assign ownerForm = "">
        </#if>
        ${sri.endFormListRow()}
    </#list></#if>
    <#assign listEntryIndex = "">
    ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
    <#if !skipEnd>
        <#if isMulti && listHasContent>
            <tr><td colspan="${numColumns}">
                <#list formNode["field"] as fieldNode><@formListSubField fieldNode false false true true/></#list>
            </td></tr>
        </#if>
            </tbody>
            <#assign ownerForm = "">
        </table>
    </#if>
    <#if isMulti && !skipStart>
        <script>
            $("#${formId}").validate({ errorClass: 'help-block', errorElement: 'span',
                highlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
                unhighlight: function(element, errorClass, validClass) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
            });
            $('#${formId} [data-toggle="tooltip"]').tooltip();
        </script>
    </#if>
    <#if hasSubColumns><script>makeColumnsConsistent('${formId}_table');</script></#if>
    <#if sri.doBoundaryComments()><!-- END   form-list[@name=${.node["@name"]}] --></#if>
    <#assign skipForm = false>
</#macro>
<#macro formListHeaderField fieldNode isHeaderDialog>
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
    <#assign containerStyle = ec.getResource().expandNoL10n(headerFieldNode["@container-style"]!, "")>
    <#assign headerAlign = fieldNode["@align"]!"left">
    <#t><div class="form-title<#if containerStyle?has_content> ${containerStyle}</#if><#if headerAlign == "center"> text-center<#elseif headerAlign == "right"> text-right</#if>">
        <#t><#if fieldSubNode["submit"]?has_content>&nbsp;<#else><@fieldTitle fieldSubNode/></#if>
        <#if fieldSubNode["@show-order-by"]! == "true" || fieldSubNode["@show-order-by"]! == "case-insensitive">
            <#assign caseInsensitive = fieldSubNode["@show-order-by"]! == "case-insensitive">
            <#assign curFieldName = fieldNode["@name"]>
            <#assign curOrderByField = ec.getContext().orderByField!>
            <#if curOrderByField?has_content && curOrderByField?contains(",")>
                <#list curOrderByField?split(",") as curOrderByFieldCandidate>
                    <#if curOrderByFieldCandidate?has_content && curOrderByFieldCandidate?contains(curFieldName)>
                        <#assign curOrderByField = curOrderByFieldCandidate><#break></#if>
                </#list>
            </#if>
            <#assign ascActive = curOrderByField?has_content && curOrderByField?contains(curFieldName) && !curOrderByField?starts_with("-")>
            <#assign descActive = curOrderByField?has_content && curOrderByField?contains(curFieldName) && curOrderByField?starts_with("-")>
            <#assign ascOrderByUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("orderByField", "+" + caseInsensitive?string("^","") + curFieldName)>
            <#assign descOrderByUrlInfo = sri.getScreenUrlInstance().cloneUrlInstance().addParameter("orderByField", "-" + caseInsensitive?string("^","") + curFieldName)>
            <#if ascActive><#assign ascOrderByUrlInfo = descOrderByUrlInfo></#if>
            <#if descActive><#assign descOrderByUrlInfo = ascOrderByUrlInfo></#if>
            <span class="form-order-by">
                <a href="${ascOrderByUrlInfo.getUrlWithParams()}"<#if ascActive> class="active"</#if>><i class="glyphicon glyphicon-triangle-top"></i></a>
                <a href="${descOrderByUrlInfo.getUrlWithParams()}"<#if descActive> class="active"</#if>><i class="glyphicon glyphicon-triangle-bottom"></i></a>
            </span>
        </#if>
    <#t></div>
    <#if !isHeaderDialog && fieldNode["header-field"]?has_content && fieldNode["header-field"][0]?children?has_content>
        <div class="form-header-field<#if containerStyle?has_content> ${containerStyle}</#if>">
            <@formListWidget fieldNode["header-field"][0] true true false false/>
            <#-- <#recurse fieldNode["header-field"][0]/> -->
        </div>
    </#if>
</#macro>
<#macro formListSubField fieldNode skipCell isHeaderField isMulti isMultiFinalRow>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.getResource().condition(fieldSubNode["@condition"], "")>
            <@formListWidget fieldSubNode skipCell isHeaderField isMulti isMultiFinalRow/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <#assign isHeaderField = false>
        <@formListWidget fieldNode["default-field"][0] skipCell isHeaderField isMulti isMultiFinalRow/>
        <#return>
    </#if>
</#macro>
<#macro formListWidget fieldSubNode skipCell isHeaderField isMulti isMultiFinalRow>
    <#if fieldSubNode["ignored"]?has_content><#return></#if>
    <#assign fieldSubParent = fieldSubNode?parent>
    <#if ec.getResource().condition(fieldSubParent["@hide"]!, "")><#return></#if>
    <#-- don't do a column for submit fields, they'll go in their own row at the bottom -->
    <#t><#if !isHeaderField && isMulti && !isMultiFinalRow && fieldSubNode["submit"]?has_content><#return></#if>
    <#t><#if !isHeaderField && isMulti && isMultiFinalRow && !fieldSubNode["submit"]?has_content><#return></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return></#if>
    <#assign containerStyle = ec.getResource().expandNoL10n(fieldSubNode["@container-style"]!, "")>
    <#if fieldSubParent["@align"]! == "right"><#assign containerStyle = containerStyle + " text-right"><#elseif fieldSubParent["@align"]! == "center"><#assign containerStyle = containerStyle + " text-center"></#if>
    <#if !isMultiFinalRow && !isHeaderField><#if skipCell><div<#if containerStyle?has_content> class="${containerStyle}"</#if>><#else><td<#if containerStyle?has_content> class="${containerStyle}"</#if>></#if></#if>
    <#t>${sri.pushContext()}
    <#list fieldSubNode?children as widgetNode><#if widgetNode?node_name == "set">${sri.setInContext(widgetNode)}</#if></#list>
    <#list fieldSubNode?children as widgetNode>
        <#if widgetNode?node_name == "link">
            <#assign linkNode = widgetNode>
            <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
            <#if conditionResult>
                <#if linkNode["@entity-name"]?has_content>
                    <#assign linkText = sri.getFieldEntityValue(linkNode)>
                <#else>
                    <#assign textMap = "">
                    <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
                    <#if textMap?has_content><#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
                        <#else><#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")></#if>
                </#if>
                <#if linkText == "null"><#assign linkText = ""></#if>
                <#if linkText?has_content || linkNode["image"]?has_content || linkNode["@icon"]?has_content>
                    <#if linkNode["@encode"]! != "false"><#assign linkText = linkText?html></#if>
                    <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
                    <#assign linkFormId><@fieldId linkNode/>_${linkNode["@url"]?replace(".", "_")}</#assign>
                    <#assign afterFormText><@linkFormForm linkNode linkFormId linkText linkUrlInfo/></#assign>
                    <#t>${sri.appendToAfterScreenWriter(afterFormText)}
                    <#t><@linkFormLink linkNode linkFormId linkText linkUrlInfo/>
                </#if>
            </#if>
        <#elseif widgetNode?node_name == "set"><#-- do nothing, handled above -->
        <#else><#t><#visit widgetNode></#if>
    </#list>
    <#t>${sri.popContext()}
    <#if !isMultiFinalRow && !isHeaderField><#if skipCell></div><#else></td></#if></#if>
</#macro>
<#macro "row-actions"><#-- do nothing, these are run by the SRI --></#macro>

<#-- ========================================================== -->
<#-- ================== Form Field Widgets ==================== -->
<#-- ========================================================== -->

<#macro fieldName widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode["@name"]?html}<#if isMulti?exists && isMulti && listEntryIndex?has_content>_${listEntryIndex}</#if></#macro>
<#macro fieldId widgetNode><#assign fieldNode=widgetNode?parent?parent/><#if fieldFormId?has_content>${fieldFormId}<#else>${ec.getResource().expandNoL10n(fieldNode?parent["@name"], "")}</#if>_${fieldNode["@name"]}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#macro>
<#macro fieldTitle fieldSubNode><#t>
    <#t><#if (fieldSubNode?node_name == 'header-field')>
        <#local fieldNode = fieldSubNode?parent>
        <#local headerFieldNode = fieldNode["header-field"][0]!>
        <#local defaultFieldNode = fieldNode["default-field"][0]!>
        <#t><#if headerFieldNode["@title"]?has_content><#local fieldSubNode = headerFieldNode><#elseif defaultFieldNode["@title"]?has_content><#local fieldSubNode = defaultFieldNode></#if>
    </#if>
    <#t><#assign titleValue><#if fieldSubNode["@title"]?has_content>${ec.getResource().expand(fieldSubNode["@title"], "")}<#else><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.getL10n().localize(titleValue)}
</#macro>
<#macro fieldIdByName fieldName><#if fieldFormId?has_content>${fieldFormId}<#else>${ec.getResource().expandNoL10n(formNode["@name"], "")}</#if>_${fieldName}<#if listEntryIndex?has_content>_${listEntryIndex}</#if><#if sectionEntryIndex?has_content>_${sectionEntryIndex}</#if></#macro>

<#macro field><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "conditional-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "default-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro set><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>

<#macro check>
    <#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)>
    <#if !currentValue?has_content><#assign currentValue = ec.getResource().expandNoL10n(.node["@no-current-selected-key"]!, "")/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
    <#list (options.keySet())! as key>
        <#assign allChecked = ec.getResource().expandNoL10n(.node["@all-checked"]!, "")>
        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked! == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>${options.get(key)!""}</span>
    </#list>
</#macro>

<#macro "date-find">
    <#if .node["@type"]! == "time"><#assign size=9><#assign maxlength=13><#assign defaultFormat="HH:mm">
    <#elseif .node["@type"]! == "date"><#assign size=10><#assign maxlength=10><#assign defaultFormat="yyyy-MM-dd">
    <#else><#assign size=16><#assign maxlength=23><#assign defaultFormat="yyyy-MM-dd HH:mm">
    </#if>
    <#assign datepickerFormat><@getBootstrapDateFormat .node["@format"]!defaultFormat/></#assign>
    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign fieldValueFrom = ec.getL10n().format(ec.getContext().get(curFieldName + "_from")!?default(.node["@default-value-from"]!""), defaultFormat)>
    <#assign fieldValueThru = ec.getL10n().format(ec.getContext().get(curFieldName + "_thru")!?default(.node["@default-value-thru"]!""), defaultFormat)>
    <#assign id><@fieldId .node/></#assign>
    <span class="form-date-find">
      <span>${ec.getL10n().localize("From")}&nbsp;</span>
    <#if .node["@type"]! != "time">
        <div class="input-group date" id="${id}_from">
            <input type="text" class="form-control" name="${curFieldName}_from" value="${fieldValueFrom?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
        </div>
        <script>$('#${id}_from').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate:'${fieldValueFrom?html}' && moment('${fieldValueFrom?html}','${datepickerFormat}'), format:'${datepickerFormat}', stepping:5, locale:"${ec.getUser().locale.toLanguageTag()}"});</script>
    <#else>
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$"
               name="${curFieldName}_from" value="${fieldValueFrom?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
    </#if>
    </span>
    <span class="form-date-find">
      <span>${ec.getL10n().localize("Thru")}&nbsp;</span>
    <#if .node["@type"]! != "time">
        <div class="input-group date" id="${id}_thru">
            <input type="text" class="form-control" name="${curFieldName}_thru" value="${fieldValueThru?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
        </div>
        <script>$('#${id}_thru').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate:'${fieldValueThru?html}' && moment('${fieldValueThru?html}','${datepickerFormat}'), format:'${datepickerFormat}', stepping:5, locale:"${ec.getUser().locale.toLanguageTag()}"});</script>
    <#else>
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$"
               name="${curFieldName}_thru" value="${fieldValueThru?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
    </#if>
    </span>
</#macro>

<#macro "date-period">
    <#assign id><@fieldId .node/></#assign>
    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign fvOffset = ec.getContext().get(curFieldName + "_poffset")!>
    <#assign fvPeriod = ec.getContext().get(curFieldName + "_period")!?lower_case>
    <#assign allowEmpty = .node["@allow-empty"]!"true">
    <div class="date-period">
        <select name="${curFieldName}_poffset" id="${id}_poffset"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <#if (allowEmpty! != "false")>
                <option value="">&nbsp;</option>
            </#if>
            <option value="0"<#if fvOffset == "0"> selected="selected"</#if>>${ec.getL10n().localize("This")}</option>
            <option value="-1"<#if fvOffset == "-1"> selected="selected"</#if>>${ec.getL10n().localize("Last")}</option>
            <option value="-2"<#if fvOffset == "-2"> selected="selected"</#if>>-2</option>
            <option value="-3"<#if fvOffset == "-3"> selected="selected"</#if>>-3</option>
            <option value="-4"<#if fvOffset == "-4"> selected="selected"</#if>>-4</option>
            <option value="-5"<#if fvOffset == "-5"> selected="selected"</#if>>-5</option>
            <option value="1"<#if fvOffset == "1"> selected="selected"</#if>>${ec.getL10n().localize("Next")}</option>
            <option value="2"<#if fvOffset == "2"> selected="selected"</#if>>+2</option>
            <option value="3"<#if fvOffset == "3"> selected="selected"</#if>>+3</option>
            <option value="4"<#if fvOffset == "4"> selected="selected"</#if>>+4</option>
            <option value="5"<#if fvOffset == "5"> selected="selected"</#if>>+5</option>
        </select>
        <select name="${curFieldName}_period" id="${id}_period"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <#if (allowEmpty! != "false")>
            <option value="">&nbsp;</option>
            </#if>
            <option value="day" <#if fvPeriod == "day"> selected="selected"</#if>>${ec.getL10n().localize("Day")}</option>
            <option value="7d" <#if fvPeriod == "7d"> selected="selected"</#if>>7 ${ec.getL10n().localize("Days")}</option>
            <option value="30d" <#if fvPeriod == "30d"> selected="selected"</#if>>30 ${ec.getL10n().localize("Days")}</option>
            <option value="week" <#if fvPeriod == "week"> selected="selected"</#if>>${ec.getL10n().localize("Week")}</option>
            <option value="month" <#if fvPeriod == "month"> selected="selected"</#if>>${ec.getL10n().localize("Month")}</option>
            <option value="year" <#if fvPeriod == "year"> selected="selected"</#if>>${ec.getL10n().localize("Year")}</option>
        </select>
        <script>
            $("#${id}_poffset").select2({ ${select2DefaultOptions} });
            $("#${id}_period").select2({ ${select2DefaultOptions} });
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
            <input type="text" class="form-control" name="<@fieldName .node/>" value="${fieldValue?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
        </div>
        <script>$('#${id}').datetimepicker({toolbarPlacement:'top', showClose:true, showClear:true, showTodayButton:true, defaultDate: '${fieldValue?html}' && moment('${fieldValue?html}','${datepickerFormat}'), format:'${datepickerFormat}', stepping:5, locale:"${ec.getUser().locale.toLanguageTag()}"});</script>
    <#else>
        <#-- datetimepicker does not support time only, even with plain HH:mm format; use a regex to validate time format -->
        <input type="text" class="form-control" pattern="^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$" name="<@fieldName .node/>" value="${fieldValue?html}" size="${size}" maxlength="${maxlength}"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
    </#if>
</#macro>

<#macro display>
    <#assign dispFieldId><@fieldId .node/></#assign>
    <#assign dispFieldNode = .node?parent?parent>
    <#assign dispAlign = dispFieldNode["@align"]!"left">
    <#assign dispHidden = (!.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true") && !(skipForm!false)>
    <#assign fieldValue = "">
    <#if .node["@text"]?has_content>
        <#assign textMap = "">
        <#if .node["@text-map"]?has_content><#assign textMap = ec.getResource().expression(.node["@text-map"], "")!></#if>
        <#if textMap?has_content>
            <#assign fieldValue = ec.getResource().expand(.node["@text"], "", textMap)>
        <#else>
            <#assign fieldValue = ec.getResource().expand(.node["@text"], "")>
        </#if>
        <#if .node["@currency-unit-field"]?has_content>
            <#assign fieldValue = ec.getL10n().formatCurrency(fieldValue, ec.getResource().expression(.node["@currency-unit-field"], ""))>
        </#if>
    <#elseif .node["@currency-unit-field"]?has_content>
        <#assign fieldValue = ec.getL10n().formatCurrency(sri.getFieldValue(dispFieldNode, ""), ec.getResource().expression(.node["@currency-unit-field"], ""))>
    <#else>
        <#assign fieldValue = sri.getFieldValueString(.node)>
    </#if>
    <#t><span id="${dispFieldId}_display" class="${sri.getFieldValueClass(dispFieldNode)}<#if .node["@currency-unit-field"]?has_content> currency</#if><#if dispAlign == "center"> text-center<#elseif dispAlign == "right"> text-right</#if>">
    <#t><#if fieldValue?has_content><#if .node["@encode"]! == "false">${fieldValue}<#else>${fieldValue?html?replace("\n", "<br>")}</#if><#else>&nbsp;</#if>
    <#t></span>
    <#t><#if dispHidden>
        <#-- use getFieldValuePlainString() and not getFieldValueString() so we don't do timezone conversions, etc -->
        <#-- don't default to fieldValue for the hidden input value, will only be different from the entry value if @text is used, and we don't want that in the hidden value -->
        <input type="hidden" id="${dispFieldId}" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(dispFieldNode, "")?html}"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
    </#if>
    <#if .node["@dynamic-transition"]?has_content>
        <#assign defUrlInfo = sri.makeUrlByType(.node["@dynamic-transition"], "transition", .node, "false")>
        <#assign defUrlParameterMap = defUrlInfo.getParameterMap()>
        <#assign depNodeList = .node["depends-on"]>
        <script>
            function populate_${dispFieldId}() {
                var hasAllParms = true;
                <#list depNodeList as depNode>if (!$('#<@fieldIdByName depNode["@field"]/>').val()) { hasAllParms = false; } </#list>
                if (!hasAllParms) { <#-- alert("not has all parms"); --> return; }
                $.ajax({ type:"POST", url:"${defUrlInfo.url}", data:{ moquiSessionToken: "${(ec.getWeb().sessionToken)!}"<#rt>
                    <#t><#list depNodeList as depNode><#local depNodeField = depNode["@field"]><#local _void = defUrlParameterMap.remove(depNodeField)!>, "${depNode["@parameter"]!depNodeField}": $("#<@fieldIdByName depNodeField/>").val()</#list>
                    <#t><#list defUrlParameterMap?keys as parameterKey><#if defUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${defUrlParameterMap.get(parameterKey)}"</#if></#list>
                    <#t>}, dataType:"text" }).done( function(defaultText) { if (defaultText) { $('#${dispFieldId}_display').html(defaultText); <#if dispHidden>$('#${dispFieldId}').val(defaultText);</#if> } } );
            }
            <#list depNodeList as depNode>
            $("#<@fieldIdByName depNode["@field"]/>").on('change', function() { populate_${dispFieldId}(); });
            </#list>
            populate_${dispFieldId}();
        </script>
    </#if>
</#macro>
<#macro "display-entity">
    <#assign fieldValue = sri.getFieldEntityValue(.node)!/>
    <#t><span id="<@fieldId .node/>_display"><#if fieldValue?has_content><#if .node["@encode"]! == "false">${fieldValue!"&nbsp;"}<#else>${(fieldValue!" ")?html?replace("\n", "<br>")}</#if><#else>&nbsp;</#if></span>
    <#-- don't default to fieldValue for the hidden input value, will only be different from the entry value if @text is used, and we don't want that in the hidden value -->
    <#t><#if !.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true"><input type="hidden" id="<@fieldId .node/>" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(.node?parent?parent, "")?html}"<#if ownerForm?has_content> form="${ownerForm}"</#if>></#if>
</#macro>

<#macro "drop-down">
    <#assign ddFieldNode = .node?parent?parent>
    <#assign id><@fieldId .node/></#assign>
    <#assign allowMultiple = ec.getResource().expand(.node["@allow-multiple"]!, "") == "true">
    <#assign isDynamicOptions = .node["dynamic-options"]?has_content>
    <#assign name><@fieldName .node/></#assign>
    <#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValuePlainString(ddFieldNode, "")>
    <#if !currentValue?has_content><#assign currentValue = ec.getResource().expandNoL10n(.node["@no-current-selected-key"]!, "")></#if>
    <#if currentValue?starts_with("[")><#assign currentValue = currentValue?substring(1, currentValue?length - 1)?replace(" ", "")></#if>
    <#assign currentValueList = (currentValue?split(","))!>
    <#if currentValueList?has_content><#if allowMultiple><#assign currentValue=""><#else><#assign currentValue = currentValueList[0]></#if></#if>
    <#assign currentDescription = (options.get(currentValue))!>
    <#assign validationClasses = formInstance.getFieldValidationClasses(ddFieldNode["@name"])>
    <#assign optionsHasCurrent = currentDescription?has_content>
    <#if !optionsHasCurrent && .node["@current-description"]?has_content>
        <#assign currentDescription = ec.getResource().expand(.node["@current-description"], "")></#if>
    <select name="${name}" class="<#if isDynamicOptions> dynamic-options</#if><#if .node["@style"]?has_content> ${ec.getResource().expand(.node["@style"], "")}</#if><#if validationClasses?has_content> ${validationClasses}</#if>" id="${id}"<#if allowMultiple> multiple="multiple"</#if><#if .node["@size"]?has_content> size="${.node["@size"]}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
    <#if !allowMultiple>
        <#-- don't add first-in-list or empty option if allowMultiple (can deselect all to be empty, including empty option allows selection of empty which isn't the point) -->
        <#if currentValue?has_content>
            <#if .node["@current"]! == "first-in-list">
                <option selected="selected" value="${currentValue}"><#if currentDescription?has_content>${currentDescription}<#else>${currentValue}</#if></option><#rt/>
                <option value="${currentValue}">---</option><#rt/>
            <#elseif !optionsHasCurrent>
                <option selected="selected" value="${currentValue}"><#if currentDescription?has_content>${currentDescription}<#else>${currentValue}</#if></option><#rt/>
            </#if>
        </#if>
        <#assign allowEmpty = ec.getResource().expand(.node["@allow-empty"]!, "")/>
        <#if (allowEmpty! == "true") || !(options?has_content)>
            <option value="">&nbsp;</option>
        </#if>
    </#if>
    <#if !isDynamicOptions>
        <#list (options.keySet())! as key>
            <#if allowMultiple && currentValueList?has_content><#assign isSelected = currentValueList?seq_contains(key)>
                <#else><#assign isSelected = currentValue?has_content && currentValue == key></#if>
            <option<#if isSelected> selected="selected"</#if> value="${key}">${options.get(key)}</option>
        </#list>
    </#if>
    </select>
    <#-- <span>[${currentValue}]; <#list currentValueList as curValue>[${curValue!''}], </#list></span> -->
    <#if allowMultiple><input type="hidden" id="${id}_op" name="${name}_op" value="in"></#if>
    <#if .node["@combo-box"]! == "true">
        <script>$("#${id}").select2({ tags: true, tokenSeparators:[',',' '], theme:'bootstrap' });</script>
    <#elseif .node["@search"]! != "false">
        <script>$("#${id}").select2({ ${select2DefaultOptions} }); $("#${id}").on("select2:select", function (e) { $("#${id}").select2("open").select2("close"); });</script>
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
                $.ajax({ type:"POST", url:"${doUrlInfo.url}", data:{ moquiSessionToken: "${(ec.getWeb().sessionToken)!}"<#rt>
                        <#t><#list depNodeList as depNode><#local depNodeField = depNode["@field"]><#local _void = doUrlParameterMap.remove(depNodeField)!>, "${depNode["@parameter"]!depNodeField}": $("#<@fieldIdByName depNodeField/>").val()</#list>
                        <#t><#list doUrlParameterMap?keys as parameterKey><#if doUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${doUrlParameterMap.get(parameterKey)}"</#if></#list>
                        <#t>}, dataType:"json" }).done(
                    function(list) {
                        if (list) {
                            $("#${id}").select2("destroy");
                            $('#${id}').html("");<#-- clear out the drop-down -->
                            <#if allowEmpty! == "true">
                            $('#${id}').append('<option value="">&nbsp;</option>');
                            </#if>
                            <#if allowMultiple && currentValueList?has_content>var currentValues = [<#list currentValueList as curVal>"${curVal}"<#sep>, </#list>];</#if>
                            $.each(list, function(key, value) {
                                var optionValue = value["${doNode["@value-field"]!"value"}"];
                                <#if allowMultiple && currentValueList?has_content>
                                if (currentValues.indexOf(optionValue) >= 0) {
                                <#else>
                                if (optionValue == "${currentValue}") {
                                </#if>
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

<#macro file><input type="file" class="form-control" name="<@fieldName .node/>" value="${sri.getFieldValueString(.node)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>></#macro>

<#macro hidden>
    <#-- use getFieldValuePlainString() and not getFieldValueString() so we don't do timezone conversions, etc -->
    <#assign id><@fieldId .node/></#assign>
    <input type="hidden" name="<@fieldName .node/>" value="${sri.getFieldValuePlainString(.node?parent?parent, .node["@default-value"]!"")?html}" id="${id}"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
</#macro>

<#macro ignored><#-- shouldn't ever be called as it is checked in the form-* macros --></#macro>

<#-- TABLED, not to be part of 1.0:
<#macro "lookup">
    <#assign curFieldName = .node?parent?parent["@name"]?html/>
    <#assign curFormName = .node?parent?parent?parent["@name"]?html/>
    <#assign id><@fieldId .node/></#assign>
    <input type="text" name="${curFieldName}" value="${sri.getFieldValueString(.node?parent?parent, .node["@default-value"]!"", null)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if ec.getResource().condition(.node.@disabled!"false", "")> disabled="disabled"</#if> id="${id}">
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
    <#assign validationClasses = formInstance.getFieldValidationClasses(.node?parent?parent["@name"])>
    <input type="password" name="<@fieldName .node/>" id="<@fieldId .node/>" class="form-control<#if validationClasses?has_content> ${validationClasses}</#if>" size="${.node.@size!"25"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if validationClasses?contains("required")> required</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
</#macro>

<#macro radio>
    <#assign options = sri.getFieldOptions(.node)/>
    <#assign currentValue = sri.getFieldValueString(.node)/>
    <#if !currentValue?has_content><#assign currentValue = ec.getResource().expand(.node["@no-current-selected-key"]!, "")/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
    <#list (options.keySet())! as key>
        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="radio" name="${curName}" value="${key?html}"<#if currentValue?has_content && currentValue==key> checked="checked"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>&nbsp;${options.get(key)!""}</span>
    </#list>
</#macro>

<#macro "range-find">
    <#assign curFieldName><@fieldName .node/></#assign>
    <#assign id><@fieldId .node/></#assign>
<span class="form-range-find">
    <span>${ec.getL10n().localize("From")}&nbsp;</span><input type="text" class="form-control" name="${curFieldName}_from" value="${ec.getWeb().parameters.get(curFieldName + "_from")!?default(.node["@default-value-from"]!"")?html}" size="${.node.@size!"10"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="${id}_from"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
</span>
<span class="form-range-find">
    <span>${ec.getL10n().localize("Thru")}&nbsp;</span><input type="text" class="form-control" name="${curFieldName}_thru" value="${ec.getWeb().parameters.get(curFieldName + "_thru")!?default(.node["@default-value-thru"]!"")?html}" size="${.node.@size!"10"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="${id}_thru"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
</span>
</#macro>

<#macro reset><input type="reset" name="<@fieldName .node/>" value="<@fieldTitle .node?parent/>" id="<@fieldId .node/>"<#if .node["@icon"]?has_content> iconcls="ui-icon-${.node["@icon"]}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>></#macro>

<#macro submit>
    <#assign confirmationMessage = ec.getResource().expand(.node["@confirmation"]!, "")/>
    <#assign buttonText><#if .node["@text"]?has_content>${ec.getResource().expand(.node["@text"], "")}<#else><@fieldTitle .node?parent/></#if></#assign>
    <#assign iconClass = .node["@icon"]!>
    <#if !iconClass?has_content><#assign iconClass = sri.getThemeIconClass(buttonText)!></#if>
    <button type="submit" name="<@fieldName .node/>" value="<@fieldName .node/>" id="<@fieldId .node/>"<#if confirmationMessage?has_content> onclick="return confirm('${confirmationMessage?js_string}');"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if> class="btn btn-primary btn-sm"<#if ownerForm?has_content> form="${ownerForm}"</#if>><#if iconClass?has_content><i class="${iconClass}"></i> </#if>
    <#if .node["image"]?has_content><#assign imageNode = .node["image"][0]>
        <img src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null,"true")}" alt="<#if imageNode["@alt"]?has_content>${imageNode["@alt"]}<#else><@fieldTitle .node?parent/></#if>"<#if imageNode["@width"]?has_content> width="${imageNode["@width"]}"</#if><#if imageNode["@height"]?has_content> height="${imageNode["@height"]}"</#if>>
    <#else>
        <#t>${buttonText}
    </#if>
    </button>
</#macro>

<#macro "text-area"><textarea class="form-control" name="<@fieldName .node/>" cols="${.node["@cols"]!"60"}" rows="${.node["@rows"]!"3"}"<#if .node["@read-only"]!"false" == "true"> readonly="readonly"</#if><#if .node["@maxlength"]?has_content> maxlength="${.node["@maxlength"]}"</#if> id="<@fieldId .node/>"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>${sri.getFieldValueString(.node)?html}</textarea></#macro>

<#macro "text-line">
    <#assign tlFieldNode = .node?parent?parent>
    <#assign id><@fieldId .node/></#assign>
    <#assign name><@fieldName .node/></#assign>
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#assign validationClasses = formInstance.getFieldValidationClasses(tlFieldNode["@name"])>
    <#assign regexpInfo = formInstance.getFieldValidationRegexpInfo(tlFieldNode["@name"])!>
    <#-- NOTE: removed number type (<#elseif validationClasses?contains("number")>number) because on Safari, maybe others, ignores size and behaves funny for decimal values -->
    <#if .node["@ac-transition"]?has_content>
        <#assign acUrlInfo = sri.makeUrlByType(.node["@ac-transition"], "transition", .node, "false")>
        <#assign acUrlParameterMap = acUrlInfo.getParameterMap()>
        <#assign acShowValue = .node["@ac-show-value"]! == "true">
        <#assign acUseActual = .node["@ac-use-actual"]! == "true">
        <#if .node["@ac-initial-text"]?has_content><#assign valueText = ec.getResource().expand(.node["@ac-initial-text"]!, "")>
            <#else><#assign valueText = fieldValue></#if>
        <input id="${id}_ac" type="<#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if>" name="${name}_ac" value="${valueText?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if><#if ec.getResource().condition(.node.@disabled!"false", "")> disabled="disabled"</#if> class="form-control<#if validationClasses?has_content> ${validationClasses}</#if>"<#if validationClasses?has_content> data-vv-validations="${validationClasses}"</#if><#if validationClasses?contains("required")> required</#if><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}"</#if><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if> autocomplete="off"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
        <input id="${id}" type="hidden" name="${name}" value="${fieldValue?html}"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
        <#if acShowValue><span id="${id}_value" class="form-autocomplete-value"><#if valueText?has_content>${valueText?html}<#else>&nbsp;</#if></span></#if>
        <#assign depNodeList = .node["depends-on"]>
        <script>
            $("#${id}_ac").autocomplete({
                source: function(request, response) { $.ajax({
                    url: "${acUrlInfo.url}", type: "POST", dataType: "json", data: { term: request.term, moquiSessionToken: "${(ec.getWeb().sessionToken)!}"<#rt>
                        <#t><#list depNodeList as depNode><#local depNodeField = depNode["@field"]><#local _void = acUrlParameterMap.remove(depNodeField)!>, '${depNode["@parameter"]!depNodeField}': $('#<@fieldIdByName depNodeField/>').val()</#list>
                        <#t><#list acUrlParameterMap?keys as parameterKey><#if acUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${acUrlParameterMap.get(parameterKey)}"</#if></#list> },
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
                $.ajax({ url: "${acUrlInfo.url}", type: "POST", dataType: "json", data: { term: $("#${id}").val(), moquiSessionToken: "${(ec.getWeb().sessionToken)!}"<#list acUrlParameterMap?keys as parameterKey><#if acUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${acUrlParameterMap.get(parameterKey)}"</#if></#list> },
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
        <#assign tlAlign = tlFieldNode["@align"]!"left">
        <#t><input id="${id}" type="<#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if>"
        <#t> name="${name}" value="${fieldValue?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if>
        <#t><#if ec.getResource().condition(.node.@disabled!"false", "")> disabled="disabled"</#if>
        <#t> class="form-control<#if validationClasses?has_content> ${validationClasses}</#if><#if tlAlign == "center"> text-center<#elseif tlAlign == "right"> text-right</#if>"
        <#t><#if validationClasses?has_content> data-vv-validations="${validationClasses}"</#if><#if validationClasses?contains("required")> required</#if><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}"</#if>
        <#t><#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
        <#if .node["@default-transition"]?has_content>
            <#assign defUrlInfo = sri.makeUrlByType(.node["@default-transition"], "transition", .node, "false")>
            <#assign defUrlParameterMap = defUrlInfo.getParameterMap()>
            <#assign depNodeList = .node["depends-on"]>
            <script>
                function populate_${id}() {
                    if ($('#${id}').val()) return;
                    var hasAllParms = true;
                    <#list depNodeList as depNode>if (!$('#<@fieldIdByName depNode["@field"]/>').val()) { hasAllParms = false; } </#list>
                    if (!hasAllParms) { <#-- alert("not has all parms"); --> return; }
                    $.ajax({ type:"POST", url:"${defUrlInfo.url}", data:{ moquiSessionToken: "${(ec.getWeb().sessionToken)!}"<#rt>
                            <#t><#list depNodeList as depNode><#local depNodeField = depNode["@field"]><#local _void = defUrlParameterMap.remove(depNodeField)!>, "${depNode["@parameter"]!depNodeField}": $("#<@fieldIdByName depNodeField/>").val()</#list>
                            <#t><#list defUrlParameterMap?keys as parameterKey><#if defUrlParameterMap.get(parameterKey)?has_content>, "${parameterKey}":"${defUrlParameterMap.get(parameterKey)}"</#if></#list>
                            <#t>}, dataType:"text" }).done( function(defaultText) { if (defaultText) { $('#${id}').val(defaultText); } } );
                }
                <#list depNodeList as depNode>
                $("#<@fieldIdByName depNode["@field"]/>").on('change', function() { populate_${id}(); });
                </#list>
                populate_${id}();
            </script>
        </#if>
    </#if>
</#macro>

<#macro "text-find">
<span class="form-text-find">
    <#assign defaultOperator = .node["@default-operator"]!"contains">
    <#assign curFieldName><@fieldName .node/></#assign>
    <#if .node["@hide-options"]! == "true" || .node["@hide-options"]! == "operator">
        <input type="hidden" name="${curFieldName}_op" value="${defaultOperator}"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
    <#else>
        <span><input type="checkbox" class="form-control" name="${curFieldName}_not" value="Y"<#if ec.getWeb().parameters.get(curFieldName + "_not")! == "Y"> checked="checked"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>&nbsp;${ec.getL10n().localize("Not")}</span>
        <select name="${curFieldName}_op" class="form-control"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
            <option value="equals"<#if defaultOperator == "equals"> selected="selected"</#if>>${ec.getL10n().localize("Equals")}</option>
            <option value="like"<#if defaultOperator == "like"> selected="selected"</#if>>${ec.getL10n().localize("Like")}</option>
            <option value="contains"<#if defaultOperator == "contains"> selected="selected"</#if>>${ec.getL10n().localize("Contains")}</option>
            <option value="begins"<#if defaultOperator == "begins"> selected="selected"</#if>>${ec.getL10n().localize("Begins With")}</option>
            <option value="empty"<#rt/><#if defaultOperator == "empty"> selected="selected"</#if>>${ec.getL10n().localize("Empty")}</option>
        </select>
    </#if>
    <input type="text" class="form-control" name="${curFieldName}" value="${sri.getFieldValueString(.node)?html}" size="${.node.@size!"30"}"<#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if> id="<@fieldId .node/>"<#if .node?parent["@tooltip"]?has_content> data-toggle="tooltip" title="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>
    <#assign ignoreCase = (ec.getWeb().parameters.get(curFieldName + "_ic")! == "Y") || !(.node["@ignore-case"]?has_content) || (.node["ignore-case"] == "true")>
    <#if .node["@hide-options"]! == "true" || .node["@hide-options"]! == "ignore-case">
        <input type="hidden" name="${curFieldName}_ic" value="Y"<#if ownerForm?has_content> form="${ownerForm}"</#if>>
    <#else>
        <span><input type="checkbox" class="form-control" name="${curFieldName}_ic" value="Y"<#if ignoreCase> checked="checked"</#if><#if ownerForm?has_content> form="${ownerForm}"</#if>>&nbsp;${ec.getL10n().localize("Ignore Case")}</span>
    </#if>
</span>
</#macro>
