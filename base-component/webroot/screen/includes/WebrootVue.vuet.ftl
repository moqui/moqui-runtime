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
<div id="apps-root"><#-- NOTE: webrootVue component attaches here, uses this and below for template -->
    <input type="hidden" id="moquiSessionToken" value="${ec.web.sessionToken}">
    <input type="hidden" id="appHost" value="${ec.web.getHostName(true)}">
    <input type="hidden" id="appRootPath" value="${ec.web.servletContext.contextPath}">
    <input type="hidden" id="basePath" value="${ec.web.servletContext.contextPath}/apps">
    <input type="hidden" id="linkBasePath" value="${ec.web.servletContext.contextPath}/vapps">
    <input type="hidden" id="userId" value="${ec.user.userId!''}">
    <#if hideNav! != 'true'>
    <div id="top"><nav class="navbar navbar-inverse navbar-fixed-top"><#-- navbar-static-top --><div class="container-fluid">
        <#-- Brand and toggle get grouped for better mobile display -->
        <header class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
        <#assign headerLogoList = sri.getThemeValues("STRT_HEADER_LOGO")>
        <#if headerLogoList?has_content><m-link href="/apps" class="navbar-brand"><img src="${sri.buildUrl(headerLogoList?first).getUrl()}" alt="Home"></m-link></#if>
        <#assign headerTitleList = sri.getThemeValues("STRT_HEADER_TITLE")>
        <#if headerTitleList?has_content><div class="navbar-brand">${ec.resource.expand(headerTitleList?first, "")}</div></#if>
        </header>
        <div id="navbar-buttons" class="collapse navbar-collapse navbar-ex1-collapse">
            <ul id="dynamic-menus" class="nav navbar-nav">
                <li v-for="(navMenuItem, menuIndex) in navMenuList" class="dropdown">
                    <template v-if="menuIndex < (navMenuList.length - 1)">
                        <m-link v-if="navMenuItem.hasTabMenu" :href="navMenuItem.path">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></m-link>
                        <template v-else-if="navMenuItem.subscreens && navMenuItem.subscreens.length > 0">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></a>
                            <ul class="dropdown-menu">
                                <li v-for="subscreen in navMenuItem.subscreens" :class="{active:subscreen.active}">
                                    <m-link :href="subscreen.pathWithParams">
                                        <template v-if="subscreen.image">
                                            <i v-if="subscreen.imageType === 'icon'" :class="subscreen.image" style="padding-right: 8px;"></i>
                                            <img v-else :src="subscreen.image" :alt="subscreen.title" width="18" style="padding-right: 4px;"/>
                                        </template>
                                        <i v-else class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                                        {{subscreen.title}}</m-link></li>
                            </ul>
                        </template>
                        <m-link v-else :href="navMenuItem.path">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></m-link>
                    </template>
                </li>
            </ul>
            <m-link v-if="navMenuList.length > 0" class="navbar-text" :href="navMenuList[navMenuList.length - 1].pathWithParams">{{navMenuList[navMenuList.length - 1].title}}</m-link>
        <#-- logout button -->
            <a href="${sri.buildUrl("/Login/logout").url}" data-toggle="tooltip" data-original-title="Logout ${(ec.user.userAccount.userFullName)!''}" data-placement="bottom" class="btn btn-danger btn-sm navbar-btn navbar-right"><i class="glyphicon glyphicon-off"></i></a>
        <#-- dark/light switch -->
            <a href="#" @click="switchDarkLight()" data-toggle="tooltip" data-original-title="Switch Dark/Light" data-placement="bottom" class="btn btn-default btn-sm navbar-btn navbar-right"><i class="glyphicon glyphicon-adjust"></i></a>

            <template v-for="navPlugin in navPlugins"><component :is="navPlugin"></component></template>
        <#assign navbarCompList = sri.getThemeValues("STRT_HEADER_NAVBAR_COMP")>
        <#list navbarCompList! as navbarComp><add-nav-plugin url="${navbarComp}"></add-nav-plugin></#list>
        <#-- screen history menu -->
        <#-- get initial history from server? <#assign screenHistoryList = ec.web.getScreenHistory()><#list screenHistoryList as screenHistory><#if (screenHistory_index >= 25)><#break></#if>{url:pathWithParams, name:title}</#list> -->
            <div id="history-menu" class="nav navbar-right dropdown">
                <a id="history-menu-link" href="#" class="dropdown-toggle btn btn-default btn-sm navbar-btn" data-toggle="dropdown" title="History">
                    <i class="glyphicon glyphicon-list"></i></a>
                <ul class="dropdown-menu">
                    <li v-for="histItem in navHistoryList"><m-link :href="histItem.pathWithParams">
                        <template v-if="histItem.image">
                            <i v-if="histItem.imageType === 'icon'" :class="histItem.image" style="padding-right: 8px;"></i>
                            <img v-else :src="histItem.image" :alt="histItem.title" width="18" style="padding-right: 4px;"/>
                        </template>
                        <i v-else class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                        {{histItem.title}}</m-link></li>
                </ul>
            </div>
            <div class="btn btn-default btn-sm navbar-btn navbar-right" :class="{ hidden: loading < 1 }"><img src="/images/wait_anim_16x16.gif" alt="Loading..."></div>
        </div>
    </div></nav></div>
    </#if>

    <div id="content"><div class="inner"><div class="container-fluid">
        <subscreens-active/>
    </div></div></div>

    <#if hideNav! != 'true'>
    <div id="footer" class="bg-dark">
        <#assign footerItemList = sri.getThemeValues("STRT_FOOTER_ITEM")>
        <div id="apps-footer-content">
            <#list footerItemList! as footerItem>
                <#assign footerItemTemplate = footerItem?interpret>
                <@footerItemTemplate/>
            </#list>
        </div>
    </div>
    </#if>
</div>
