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
<nav class="navbar navbar-inverse navbar-fixed-top"><#-- navbar-static-top --><div class="container-fluid">
    <#-- Brand and toggle get grouped for better mobile display -->
    <header class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
        </button>
        <#assign headerLogoList = sri.getThemeValues("STRT_HEADER_LOGO")>
        <#if headerLogoList?has_content><a href="${sri.buildUrl("/").getUrl()}" class="navbar-brand"><img src="${sri.buildUrl(headerLogoList?first).getUrl()}" alt="Home"></a></#if>
        <#assign headerTitleList = sri.getThemeValues("STRT_HEADER_TITLE")>
        <#if headerTitleList?has_content><div class="navbar-brand">${ec.resource.expand(headerTitleList?first, "")}</div></#if>
    </header>
    <div id="navbar-buttons" class="collapse navbar-collapse navbar-ex1-collapse">
        <ul id="dynamic-menus" class="nav navbar-nav">
            <li v-for="(navMenuItem, menuIndex) in navMenuList" class="dropdown">
                <template v-if="menuIndex < (navMenuList.length - 1)">
                    <m-link v-if="navMenuItem.hasTabMenu" v-bind:href="navMenuItem.path">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></m-link>
                    <template v-else-if="navMenuItem.subscreens && navMenuItem.subscreens.length > 0">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></a>
                        <ul class="dropdown-menu">
                            <li v-for="subscreen in navMenuItem.subscreens" v-bind:class="{ active: subscreen.active }">
                                <m-link v-bind:href="subscreen.urlWithParams">
                                    <template v-if="subscreen.image">
                                        <i v-if="subscreen.imageType === 'icon'" v-bind:class="subscreen.image" style="padding-right: 8px;"></i>
                                        <img v-else v-bind:src="subscreen.image" v-bind:alt="subscreen.title" width="18" style="padding-right: 4px;"/>
                                    </template>
                                    <i v-else class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                                    {{subscreen.title}}</m-link></li>
                        </ul>
                    </template>
                    <m-link v-else v-bind:href="navMenuItem.path">{{navMenuItem.title}} <i class="glyphicon glyphicon-chevron-right"></i></m-link>
                </template>
            </li>
        </ul>
        <m-link v-if="navMenuList.length > 0" class="navbar-text" v-bind:href="navMenuList[navMenuList.length - 1].urlWithParams">{{navMenuList[navMenuList.length - 1].title}}</m-link>

        <#-- logout button -->
        <a href="${sri.buildUrl("/Login/logout").url}" data-toggle="tooltip" data-original-title="Logout ${(ec.getUser().getUserAccount().userFullName)!}" data-placement="bottom" class="btn btn-danger btn-sm navbar-btn navbar-right">
            <i class="glyphicon glyphicon-off"></i>
        </a>
        <#-- dark/light switch -->
        <a href="#" onclick="switchDarkLight();" data-toggle="tooltip" data-original-title="Switch Dark/Light" data-placement="bottom" class="btn btn-default btn-sm navbar-btn navbar-right">
            <i class="glyphicon glyphicon-adjust"></i>
        </a>
        <#-- header navbar items from the theme -->
        <#assign navbarItemList = sri.getThemeValues("STRT_HEADER_NAVBAR_ITEM")>
        <#list navbarItemList! as navbarItem>
            <#assign navbarItemTemplate = navbarItem?interpret>
            <@navbarItemTemplate/>
        </#list>
        <#-- screen history menu -->
        <#assign screenHistoryList = ec.web.getScreenHistory()>
        <div id="history-menu" class="nav navbar-right dropdown">
            <a id="history-menu-link" href="#" class="dropdown-toggle btn btn-default btn-sm navbar-btn" data-toggle="dropdown" title="History">
                <i class="glyphicon glyphicon-list"></i></a>
            <ul class="dropdown-menu"><#list screenHistoryList as screenHistory><#if (screenHistory_index >= 25)><#break></#if>
                <li><a href="${screenHistory.url}">
                    <#if screenHistory.image?has_content>
                        <#if screenHistory.imageType == "icon">
                            <i class="${screenHistory.image}" style="padding-right: 8px;"></i>
                        <#elseif screenHistory.imageType == "url-plain">
                            <img src="${screenHistory.image}" alt="${screenHistory.name}" width="18" style="padding-right: 4px;"/>
                        <#else>
                            <img src="${sri.buildUrl(screenHistory.image).url}" alt="${screenHistory.name}" height="18" style="padding-right: 4px;"/>
                        </#if>
                    <#else>
                        <i class="glyphicon glyphicon-link" style="padding-right: 8px;"></i>
                    </#if>
                    ${screenHistory.name}
                </a></li>
            </#list></ul>
        </div>
    </div>
    <#-- dark/light switch JS method; TODO: switch this to Vue method? -->
    <script>
        $('.navbar [data-toggle="tooltip"]').tooltip();
        $('#history-menu-link').tooltip({ placement:'bottom', trigger:'hover' });
        function switchDarkLight() {
            $("body").toggleClass("bg-dark");
            $("body").toggleClass("bg-light");
            var currentStyle = $("body").hasClass("bg-dark") ? "bg-dark" : "bg-light";
            $.ajax({ type:'POST', url:'${sri.buildUrl("/apps/setPreference").url}', data:{ 'moquiSessionToken': '${ec.web.sessionToken}','preferenceKey': 'OUTER_STYLE', 'preferenceValue': currentStyle }, dataType:'json' });
        }
    </script>
</div></nav>
