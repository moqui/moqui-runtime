<#assign screenDocList = sri.getScreenUrlInfo().getTargetScreen().getScreenDocumentInfoList()>
<#assign currentScreenUrl = sri.getScreenUrlInstance().getUrlWithParams()>
<#assign currentScreenTitle = html_title!(ec.resource.expand(sri.screenUrlInfo.targetScreen.getDefaultMenuName()!"Page", ""))>

<nav class="moqui-topbar navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid moqui-topbar__inner">
    <div class="moqui-topbar__brand-zone">
      <button class="navbar-toggler moqui-topbar__toggler" type="button"
              data-bs-toggle="collapse" data-bs-target="#navbar-collapse"
              aria-controls="navbar-collapse" aria-expanded="false"
              aria-label="${ec.l10n.localize('Toggle navigation')}">
        <span class="navbar-toggler-icon"></span>
      </button>

      <#assign headerLogoList = sri.getThemeValues("STRT_HEADER_LOGO")>
      <#if headerLogoList?has_content>
        <a href="${sri.buildUrl('/uapps').getUrl()}"
           class="navbar-brand moqui-topbar__brand"
           up-follow up-target="#content" up-history="true">
          <img src="${sri.buildUrl(headerLogoList?first).getUrl()}" alt="Home">
        </a>
      </#if>

      <div class="moqui-topbar__context">
        <#assign headerTitleList = sri.getThemeValues("STRT_HEADER_TITLE")>
        <#if headerTitleList?has_content>
          <a href="${sri.buildUrl('/uapps').getUrl()}"
             class="moqui-topbar__app-title"
             up-follow up-target="#content" up-history="true">${ec.resource.expand(headerTitleList?first, "")}</a>
        </#if>
        <ul id="header-menus" class="navbar-nav moqui-topbar__menus">
          <#-- NOTE: menu drop-downs are appended here using JS as subscreens render so this is empty -->
        </ul>
        <div id="navbar-menu-crumbs" class="moqui-topbar__crumbs"></div>
        <a id="navbar-current-title"
           class="moqui-topbar__current"
           href="${currentScreenUrl}"
           up-follow up-target="#content" up-history="true">${currentScreenTitle}</a>
      </div>
    </div>

    <div id="navbar-collapse" class="collapse navbar-collapse moqui-topbar__collapse">
      <ul id="navbar-buttons" class="navbar-nav me-auto moqui-topbar__app-nav"></ul>
      <div class="moqui-topbar__actions">
        <#-- header navbar items from the theme -->
        <#assign navbarItemList = sri.getThemeValues("STRT_HEADER_NAVBAR_ITEM")>
        <#list navbarItemList! as navbarItem>
          <#assign navbarItemTemplate = navbarItem?interpret>
          <@navbarItemTemplate/>
        </#list>

        <#if screenDocList?has_content>
          <div id="document-menu" class="dropdown moqui-topbar__dropdown">
            <button id="document-menu-link"
                    class="btn btn-sm btn-outline-info moqui-topbar__icon-btn"
                    type="button"
                    data-bs-toggle="dropdown"
                    aria-expanded="false"
                    title="Documentation">
              <i class="fa fa-question-circle"></i>
              <span class="visually-hidden">Documentation</span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm">
              <#list screenDocList as screenDoc>
                <li>
                  <button type="button" class="dropdown-item" onclick="return showScreenDocDialog('${screenDoc.index}')">${screenDoc.title}</button>
                </li>
              </#list>
            </ul>
          </div>
        </#if>

        <div id="history-menu" class="dropdown moqui-topbar__dropdown">
          <button id="history-menu-link"
                  class="btn btn-sm btn-outline-light moqui-topbar__icon-btn"
                  type="button"
                  data-bs-toggle="dropdown"
                  aria-expanded="false"
                  title="${ec.l10n.localize('History')}">
            <i class="fa fa-list"></i>
            <span class="visually-hidden">${ec.l10n.localize('History')}</span>
          </button>
          <#assign screenHistoryList = ec.web.getScreenHistory()>
          <ul class="dropdown-menu dropdown-menu-end shadow-sm moqui-topbar__history-menu">
            <#list screenHistoryList as screenHistory><#if (screenHistory_index >= 25)><#break></#if>
              <li>
                <a class="dropdown-item"
                   href="${screenHistory.url}"
                   up-follow up-target="#content" up-history="true">
                  <#if screenHistory.image?has_content>
                    <#if screenHistory.imageType == "icon">
                      <i class="${screenHistory.image} me-2"></i>
                    <#elseif screenHistory.imageType == "url-plain">
                      <img src="${screenHistory.image}" alt="${screenHistory.name}" width="18" class="me-2"/>
                    <#else>
                      <img src="${sri.buildUrl(screenHistory.image).url}" alt="${screenHistory.name}" height="18" class="me-2"/>
                    </#if>
                  <#else>
                    <i class="fa fa-link me-2"></i>
                  </#if>
                  <span>${screenHistory.name}</span>
                </a>
              </li>
            </#list>
          </ul>
        </div>

        <div id="theme-menu" class="moqui-topbar__dropdown">
          <label for="bootstrap-theme-select" class="visually-hidden">${ec.l10n.localize('Bootstrap Theme')}</label>
          <select id="bootstrap-theme-select"
                  class="form-select form-select-sm bg-dark text-light border-secondary"
                  title="${ec.l10n.localize('Bootstrap Theme')}"
                  aria-label="${ec.l10n.localize('Bootstrap Theme')}">
            <option value="">Bootstrap (Default)</option>
            <option value="brite">Brite</option>
            <option value="cerulean">Cerulean</option>
            <option value="cosmo">Cosmo</option>
            <option value="cyborg">Cyborg</option>
            <option value="darkly">Darkly</option>
            <option value="flatly">Flatly</option>
            <option value="journal">Journal</option>
            <option value="litera">Litera</option>
            <option value="lumen">Lumen</option>
            <option value="lux">Lux</option>
            <option value="materia">Materia</option>
            <option value="minty">Minty</option>
            <option value="morph">Morph</option>
            <option value="pulse">Pulse</option>
            <option value="quartz">Quartz</option>
            <option value="sandstone">Sandstone</option>
            <option value="simplex">Simplex</option>
            <option value="sketchy">Sketchy</option>
            <option value="slate">Slate</option>
            <option value="solar">Solar</option>
            <option value="spacelab">Spacelab</option>
            <option value="superhero">Superhero</option>
            <option value="united">United</option>
            <option value="vapor">Vapor</option>
            <option value="yeti">Yeti</option>
            <option value="zephyr">Zephyr</option>
          </select>
        </div>

        <button type="button"
                class="btn btn-sm btn-outline-light moqui-topbar__icon-btn"
                title="${ec.l10n.localize('Switch Dark/Light')}"
                onclick="switchDarkLight(); return false;">
          <i class="fa fa-adjust"></i>
          <span class="visually-hidden">${ec.l10n.localize('Switch Dark/Light')}</span>
        </button>

        <a href="${sri.buildUrl('/Login/logout').url}"
           class="btn btn-sm btn-outline-danger moqui-topbar__icon-btn"
           title="${ec.l10n.localize('Logout')} ${(ec.getUser().getUserAccount().userFullName)!}">
          <i class="fa fa-power-off"></i>
          <span class="visually-hidden">${ec.l10n.localize('Logout')}</span>
        </a>
      </div>
    </div>
  </div>
</nav>

<script>
(function() {
    var BOOTSWATCH_VERSION = '5.3.8';
    var BOOTSWATCH_CSS_BASE = 'https://cdn.jsdelivr.net/npm/bootswatch@' + BOOTSWATCH_VERSION + '/dist/';
    var LOCAL_BOOTSTRAP_MARKER = '/libs/bootstrap5/css/bootstrap.min.css';
    var themePreferenceKey = 'moqui.bootstrapTheme';

    function getBootstrapLinkEl() {
        var links = document.querySelectorAll('link[rel="stylesheet"][href]');
        for (var i = 0; i < links.length; i++) {
            var href = links[i].getAttribute('href') || '';
            if (href.indexOf(LOCAL_BOOTSTRAP_MARKER) >= 0 || href.indexOf('/bootswatch@') >= 0) return links[i];
        }
        return null;
    }

    function getDefaultBootstrapHref() {
        var linkEl = getBootstrapLinkEl();
        if (!linkEl) return null;
        var existing = linkEl.getAttribute('data-default-href');
        if (existing) return existing;
        existing = linkEl.getAttribute('href');
        linkEl.setAttribute('data-default-href', existing);
        return existing;
    }

    function applyBootstrapTheme(themeName) {
        var linkEl = getBootstrapLinkEl();
        if (!linkEl) return;

        var defaultHref = getDefaultBootstrapHref();
        if (!defaultHref) return;

        if (!themeName) {
            linkEl.setAttribute('href', defaultHref);
            return;
        }

        linkEl.setAttribute('href', BOOTSWATCH_CSS_BASE + encodeURIComponent(themeName) + '/bootstrap.min.css');
    }

    function initBootstrapThemeSwitcher() {
        var selectEl = document.getElementById('bootstrap-theme-select');
        if (!selectEl) return;

        var savedTheme = '';
        try { savedTheme = localStorage.getItem(themePreferenceKey) || ''; } catch (e) {}

        if (savedTheme) applyBootstrapTheme(savedTheme);
        selectEl.value = savedTheme;

        selectEl.addEventListener('change', function() {
            var selectedTheme = selectEl.value || '';
            applyBootstrapTheme(selectedTheme);
            try { localStorage.setItem(themePreferenceKey, selectedTheme); } catch (e) {}
        });
    }

    function syncNavbarCurrentTitle() {
        var titleEl = document.getElementById('navbar-current-title');
        if (!titleEl) return;

        var metaEl = document.querySelector('#content .moqui-current-screen-meta');
        if (metaEl) {
            var screenTitle = metaEl.getAttribute('data-screen-title');
            var screenUrl = metaEl.getAttribute('data-screen-url');
            if (screenTitle) titleEl.textContent = screenTitle;
            if (screenUrl) titleEl.setAttribute('href', screenUrl);
        }

        var crumbsHost = document.getElementById('navbar-menu-crumbs');
        var hasAnyCrumb = crumbsHost && crumbsHost.children && crumbsHost.children.length > 0;
        titleEl.style.display = hasAnyCrumb ? 'none' : '';
    }

    window.switchDarkLight = function() {
        var body = document.body;
        body.classList.toggle('bg-dark');
        body.classList.toggle('bg-light');
        var currentStyle = body.classList.contains('bg-dark') ? 'bg-dark' : 'bg-light';
        fetch('${sri.buildUrl("/uapps/setPreference").url}', {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: 'moquiSessionToken=' + encodeURIComponent('${ec.web.sessionToken}') +
                  '&preferenceKey=' + encodeURIComponent('OUTER_STYLE') +
                  '&preferenceValue=' + encodeURIComponent(currentStyle)
        }).catch(function() {});
    };

    window.showScreenDocDialog = function(docIndex) {
        var trigger = document.getElementById('document-menu-link');
        var dialogId = 'screen-document-dialog';
        if (typeof window.moquiOpenModal === 'function') {
            window.moquiOpenModal(dialogId, trigger, '#' + dialogId);
        } else {
            var dlg = document.getElementById(dialogId);
            if (dlg) {
                dlg.style.display = 'block';
                dlg.classList.add('show');
                dlg.classList.add('in');
                dlg.removeAttribute('inert');
                dlg.setAttribute('aria-hidden', 'false');
            }
        }
        if (window.up && up.render) {
            up.render({ url: '${sri.buildUrlFromTarget("screenDoc").url}?docIndex=' + encodeURIComponent(docIndex), target: '#screen-document-dialog-body', history: false });
        } else {
            fetch('${sri.buildUrlFromTarget("screenDoc").url}?docIndex=' + encodeURIComponent(docIndex), { credentials: 'same-origin' })
                .then(function(resp) { return resp.text(); })
                .then(function(html) {
                    var body = document.getElementById('screen-document-dialog-body');
                    if (body) body.innerHTML = html;
                });
        }
        return false;
    };

    function resetScreenDocBody() {
        var body = document.getElementById('screen-document-dialog-body');
        if (!body) return;
        body.innerHTML = '<img src="/images/wait_anim_16x16.gif" alt="Loading...">';
    }

    document.addEventListener('hidden.bs.modal', function(ev) {
        if (ev.target && ev.target.id === 'screen-document-dialog') resetScreenDocBody();
    });
    document.addEventListener('up:rendered', syncNavbarCurrentTitle);
    document.addEventListener('up:fragment:loaded', syncNavbarCurrentTitle);
    document.addEventListener('up:fragment:inserted', syncNavbarCurrentTitle);
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            initBootstrapThemeSwitcher();
            syncNavbarCurrentTitle();
        });
    } else {
        initBootstrapThemeSwitcher();
        syncNavbarCurrentTitle();
    }
})();
</script>

<#if screenDocList?has_content>
    <#assign screenDocDialogText>
    <div id="screen-document-dialog" class="modal dynamic-dialog" aria-hidden="true" style="display: none;" tabindex="-1" inert>
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">${ec.l10n.localize("Documentation")}</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="${ec.l10n.localize('Close')}"></button>
                </div>
                <div class="modal-body" id="screen-document-dialog-body">
                    <img src="/images/wait_anim_16x16.gif" alt="Loading...">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">${ec.l10n.localize("Close")}</button>
                </div>
            </div>
        </div>
    </div>
    </#assign>
    <#t>${sri.appendToAfterScreenWriter(screenDocDialogText)}
</#if>
