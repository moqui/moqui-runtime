(function() {
    'use strict';

    var FC3_JS_URL = 'https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.1.0/fullcalendar.min.js';
    var FC3_LOCALE_URL = 'https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.1.0/locale-all.js';
    var FC3_CSS_URL = 'https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.1.0/fullcalendar.min.css';
    var fullCalendarAssetsPromise = null;

    function loadModalBody(triggerEl) {
        var loadUrl = triggerEl && triggerEl.getAttribute ? triggerEl.getAttribute('data-moqui-load-url') : null;
        var bodyTarget = triggerEl && triggerEl.getAttribute ? triggerEl.getAttribute('data-moqui-body-target') : null;
        if (!loadUrl || !bodyTarget) return;

        var bodyEl = document.querySelector(bodyTarget);
        if (!bodyEl) return;

        var applyAfterLoad = function() {
            var dialogEl = triggerEl.closest('.modal') || document.querySelector(triggerEl.getAttribute('data-bs-target') || triggerEl.getAttribute('data-target'));
            if (dialogEl) initSelect2($(dialogEl).find(':not(.noResetSelect2)>select:not(.noResetSelect2)'));
            runPostRenderInits(dialogEl || bodyEl);
        };

        if (window.up && up.render) {
            Promise.resolve(up.render({ url: loadUrl, target: bodyTarget, history: false }))
                .then(applyAfterLoad)
                .catch(function() {
                    fetch(loadUrl, { credentials: 'same-origin' })
                        .then(function(resp) { return resp.text(); })
                        .then(function(html) { bodyEl.innerHTML = html; applyAfterLoad(); });
                });
        } else {
            fetch(loadUrl, { credentials: 'same-origin' })
                .then(function(resp) { return resp.text(); })
                .then(function(html) { bodyEl.innerHTML = html; applyAfterLoad(); });
        }
    }

    function ensureMoquiModalSupport() {
        function triggerBsModalEvent(dialogEl, type, relatedTarget) {
            if (!dialogEl) return false;
            if (window.$ && $.Event) {
                var jqEvt = $.Event(type, { relatedTarget: relatedTarget || null });
                $(dialogEl).trigger(jqEvt);
                return !!jqEvt.isDefaultPrevented();
            }
            return false;
        }

        function ensureManualBackdrop() {
            if (document.querySelector('.modal-backdrop')) return;
            var backdrop = document.createElement('div');
            backdrop.className = 'modal-backdrop fade in moqui-backdrop';
            document.body.appendChild(backdrop);
        }

        function forceOpenState(dialogEl) {
            if (!dialogEl) return;
            if (dialogEl.removeAttribute) dialogEl.removeAttribute('inert');
            dialogEl.style.display = 'block';
            dialogEl.classList.add('show');
            dialogEl.classList.add('in');
            dialogEl.setAttribute('aria-hidden', 'false');
            document.body.classList.add('modal-open');
            ensureManualBackdrop();
        }

        function forceClosedState(dialogEl) {
            if (!dialogEl) return;
            dialogEl.style.display = 'none';
            dialogEl.classList.remove('show');
            dialogEl.classList.remove('in');
            dialogEl.setAttribute('aria-hidden', 'true');
            dialogEl.setAttribute('inert', '');
        }

        function closeDuplicateDialogs(targetSel, keepEl) {
            if (!targetSel || targetSel.charAt(0) !== '#') return;
            document.querySelectorAll(targetSel).forEach(function(el) {
                if (el === keepEl) return;
                forceClosedState(el);
            });
        }

        function cleanupStaleModalArtifacts() {
            var hasVisibleModal = !!document.querySelector('.modal.in, .modal.show');
            if (hasVisibleModal) return;
            document.querySelectorAll('.modal-backdrop').forEach(function(el) { el.remove(); });
            if (document.body) {
                document.body.classList.remove('modal-open');
                document.body.style.paddingRight = '';
            }
        }

        function clearModalFocus(dialogEl, withDeferredPass) {
            if (!dialogEl) return;

            var focused = document.activeElement;
            if (focused && dialogEl.contains(focused) && typeof focused.blur === 'function') {
                focused.blur();
            }

            var trigger = dialogEl.__moquiLastTrigger;
            if (trigger && typeof trigger.focus === 'function') {
                try { trigger.focus({ preventScroll: true }); } catch (ignore) { trigger.focus(); }
            }

            // Select2 may re-focus selection asynchronously after blur; run another pass.
            if (withDeferredPass) {
                setTimeout(function() {
                    var deferredFocused = document.activeElement;
                    if (deferredFocused && dialogEl.contains(deferredFocused) && typeof deferredFocused.blur === 'function') {
                        deferredFocused.blur();
                    }
                    var deferredTrigger = dialogEl.__moquiLastTrigger;
                    if (deferredTrigger && typeof deferredTrigger.focus === 'function') {
                        try { deferredTrigger.focus({ preventScroll: true }); } catch (ignore) { deferredTrigger.focus(); }
                    } else if (document.body && typeof document.body.focus === 'function') {
                        document.body.focus();
                    }
                }, 0);
                setTimeout(function() {
                    var lateFocused = document.activeElement;
                    if (lateFocused && dialogEl.contains(lateFocused) && typeof lateFocused.blur === 'function') {
                        lateFocused.blur();
                    }
                }, 30);
            }
        }

        function resolveDialogElement(dialogId, triggerEl, targetSel) {
            var selector = targetSel || ('#' + dialogId);
            if (triggerEl && triggerEl.nextElementSibling && triggerEl.nextElementSibling.matches && triggerEl.nextElementSibling.matches(selector)) {
                return triggerEl.nextElementSibling;
            }
            if (triggerEl && triggerEl.previousElementSibling && triggerEl.previousElementSibling.matches && triggerEl.previousElementSibling.matches(selector)) {
                return triggerEl.previousElementSibling;
            }
            if (triggerEl && triggerEl.closest) {
                var contentScope = triggerEl.closest('#content');
                if (contentScope && contentScope.querySelector) {
                    var inContentAll = contentScope.querySelectorAll(selector);
                    if (inContentAll && inContentAll.length >= 1) return inContentAll[inContentAll.length - 1];
                }
                var scope = triggerEl.parentElement;
                while (scope && scope.querySelector) {
                    var inScopeAll = scope.querySelectorAll(selector);
                    if (inScopeAll && inScopeAll.length >= 1) return inScopeAll[inScopeAll.length - 1];
                    scope = scope.parentElement;
                }
            }

            var allMatches = document.querySelectorAll(selector);
            if (!allMatches || allMatches.length === 0) return null;
            if (allMatches.length === 1) return allMatches[0];
            for (var i = allMatches.length - 1; i >= 0; i--) {
                if (allMatches[i] && allMatches[i].isConnected) return allMatches[i];
            }
            return allMatches[allMatches.length - 1];
        }

        if (typeof window.moquiOpenModal !== 'function') {
            window.moquiOpenModal = function(dialogId, triggerEl, targetSel) {
                var dialogEl = resolveDialogElement(dialogId, triggerEl, targetSel);
                if (!dialogEl) return false;
                if (triggerBsModalEvent(dialogEl, 'show.bs.modal', triggerEl)) return false;
                dialogEl.__moquiLastTrigger = triggerEl || null;
                closeDuplicateDialogs(targetSel || ('#' + dialogId), dialogEl);
                forceOpenState(dialogEl);
                if (triggerEl) loadModalBody(triggerEl);
                triggerBsModalEvent(dialogEl, 'shown.bs.modal', triggerEl);
                return false;
            };
        }

        if (typeof window.moquiHandleModalTrigger !== 'function') {
            window.moquiHandleModalTrigger = function(triggerEl, dialogId) {
                if (!dialogId) return false;
                var targetSel = '#' + dialogId;
                if (typeof window.moquiOpenModal === 'function') {
                    return window.moquiOpenModal(dialogId, triggerEl, targetSel);
                }
                var dialogEl = resolveDialogElement(dialogId, triggerEl, targetSel);
                if (!dialogEl) return false;
                closeDuplicateDialogs(targetSel, dialogEl);
                forceOpenState(dialogEl);
                if (triggerEl) loadModalBody(triggerEl);
                return false;
            };
        }

        if (typeof window.moquiHandleModalClick !== 'function') {
            window.moquiHandleModalClick = function(triggerEl) {
                if (!triggerEl || !triggerEl.getAttribute) return false;
                var dialogId = triggerEl.getAttribute('data-moqui-dialog-id');
                if (!dialogId) {
                    var targetSel = triggerEl.getAttribute('data-bs-target') || triggerEl.getAttribute('data-target') || triggerEl.getAttribute('href') || '';
                    if (targetSel && targetSel.charAt(0) === '#') dialogId = targetSel.substring(1);
                }
                if (!dialogId) return false;
                return window.moquiHandleModalTrigger(triggerEl, dialogId);
            };
        }

        if (typeof window.moquiOpenModalFromClick !== 'function') {
            window.moquiOpenModalFromClick = function(triggerEl) {
                if (typeof window.moquiHandleModalClick === 'function') return window.moquiHandleModalClick(triggerEl);
                return false;
            };
        }

        if (typeof window.moquiCloseModal !== 'function') {
            window.moquiCloseModal = function(dialogEl) {
                if (!dialogEl) return false;
                var selector = dialogEl.id ? ('#' + dialogEl.id) : null;
                triggerBsModalEvent(dialogEl, 'hide.bs.modal', null);
                // Force close current dialog and any duplicate stale instances with same id.
                forceClosedState(dialogEl);
                if (selector) closeDuplicateDialogs(selector, null);
                clearModalFocus(dialogEl, true);
                cleanupStaleModalArtifacts();
                triggerBsModalEvent(dialogEl, 'hidden.bs.modal', null);
                return false;
            };
        }

        if (typeof window.moquiHandleModalCloseClick !== 'function') {
            window.moquiHandleModalCloseClick = function(closeTriggerEl) {
                if (!closeTriggerEl || !closeTriggerEl.closest) return false;
                var dialogEl = closeTriggerEl.closest('.modal');
                if (typeof window.moquiCloseModal === 'function' && dialogEl) {
                    return window.moquiCloseModal(dialogEl);
                }
                return false;
            };
        }
        if (typeof window.moquiCloseModalFromClick !== 'function') {
            window.moquiCloseModalFromClick = function(closeTriggerEl) {
                if (typeof window.moquiHandleModalCloseClick === 'function') return window.moquiHandleModalCloseClick(closeTriggerEl);
                return false;
            };
        }

        if (!window.__moquiModalClickBound) {
            window.__moquiModalClickBound = true;
            var openHandler = function(ev) {
                cleanupStaleModalArtifacts();
                var trigger = ev.target && ev.target.closest ? ev.target.closest('[data-bs-toggle="modal"], [data-toggle="modal"]') : null;
                if (!trigger) return;
                if (trigger.getAttribute && trigger.getAttribute('data-moqui-inline-open') === 'true') return;
                var targetSel = trigger.getAttribute('data-bs-target') || trigger.getAttribute('data-target') || trigger.getAttribute('href');
                if (!targetSel || targetSel.charAt(0) !== '#') return;
                ev.preventDefault();
                window.moquiOpenModal(targetSel.substring(1), trigger, targetSel);
            };

            var closeHandler = function(ev) {
                var closeTrigger = ev.target && ev.target.closest ? ev.target.closest('[data-bs-dismiss="modal"], [data-dismiss="modal"]') : null;
                if (!closeTrigger) return;
                var dialogEl = closeTrigger.closest ? closeTrigger.closest('.modal') : null;
                if (!dialogEl) return;
                ev.preventDefault();
                if (ev.stopImmediatePropagation) ev.stopImmediatePropagation();
                window.moquiCloseModal(dialogEl);
            };

            if (!window.__moquiModalPointerBound) {
                window.__moquiModalPointerBound = true;
                document.addEventListener('pointerdown', openHandler, true);
                document.addEventListener('pointerdown', closeHandler, true);
            }
            document.addEventListener('click', openHandler, true);
            document.addEventListener('click', closeHandler, true);
            document.addEventListener('click', function(ev) {
                var modalEl = ev.target && ev.target.classList && ev.target.classList.contains('modal') ? ev.target : null;
                if (!modalEl) return;
                // Backdrop click closes modal unless click was inside dialog box.
                if (ev.target.closest && ev.target.closest('.modal-dialog')) return;
                ev.preventDefault();
                window.moquiCloseModal(modalEl);
            }, true);

            // Avoid accessibility warning when Bootstrap toggles aria-hidden while focus is still inside modal.
            if (window.$ && $.fn) {
                if (!window.__moquiModalA11yBound) {
                    window.__moquiModalA11yBound = true;
                    $(document).off('show.bs.modal.moquiA11y hide.bs.modal.moquiA11y hidden.bs.modal.moquiA11y');
                    $(document).on('show.bs.modal.moquiA11y', '.modal', function() {
                        forceOpenState(this);
                    });
                    $(document).on('hide.bs.modal.moquiA11y', '.modal', function() {
                        forceClosedState(this);
                        clearModalFocus(this, true);
                    });
                    $(document).on('hidden.bs.modal.moquiA11y', '.modal', function() {
                        forceClosedState(this);
                        clearModalFocus(this, true);
                    });
                }
            } else {
                document.addEventListener('hide.bs.modal', function(ev) {
                    forceClosedState(ev.target);
                    clearModalFocus(ev.target, true);
                });
                document.addEventListener('hidden.bs.modal', function(ev) {
                    forceClosedState(ev.target);
                    clearModalFocus(ev.target, true);
                });
            }
        }

        cleanupStaleModalArtifacts();
    }

    function pushUnique(list, value) {
        if (Array.isArray(list) && list.indexOf(value) === -1) list.push(value);
    }

    function initUnpolyDefaults() {
        if (!window.up || window.__moquiUnpolyDefaultsInit) return;
        window.__moquiUnpolyDefaultsInit = true;

        if (up.fragment && up.fragment.config && Array.isArray(up.fragment.config.mainTargets)) {
            ['[up-main]', '#content', 'main'].forEach(function(target) {
                pushUnique(up.fragment.config.mainTargets, target);
            });
        }

        if (up.layer && up.layer.config) {
            ['any', 'root', 'overlay', 'popup', 'modal'].forEach(function(layerName) {
                var layerCfg = up.layer.config[layerName];
                if (!layerCfg || !Array.isArray(layerCfg.mainTargets)) return;
                ['[up-main]', '#content', 'main'].forEach(function(target) {
                    pushUnique(layerCfg.mainTargets, target);
                });
            });
        }

        if (up.link && up.link.config && Array.isArray(up.link.config.followSelectors)) {
            pushUnique(up.link.config.followSelectors, 'a[href]:not([target]):not([href^="javascript"]):not([up-no-follow])');
        }

        if (up.network && up.network.config) {
            up.network.config.autoCache = function() { return false; };
            if (up.cache && typeof up.cache.reset === 'function') {
                try { up.cache.reset(); } catch (ignore) { }
            }
        }

        // up:fragment:before-render does not exist in Unpoly 3.x.
        // Use up:fragment:loaded (fires before rendering) to clear navbar dynamic areas
        // so jQuery scripts in the new content can re-populate them correctly.
        document.addEventListener('up:fragment:loaded', function(event) {
            var renderOpts = event && event.renderOptions;
            if (!renderOpts) return;
            // Only clear for main-content navigations, not sub-fragment updates (forms, modals).
            // mainTargets are configured as ['[up-main]', '#content', 'main'] above.
            var targetSel = renderOpts.target || '';
            var isMainContent = typeof targetSel !== 'string' ? false :
                !targetSel ||
                targetSel.indexOf('up-main') >= 0 ||
                targetSel.indexOf('#content') >= 0 ||
                targetSel === ':main' || targetSel === 'main';
            if (!isMainContent) return;
            ['header-menus', 'navbar-menu-crumbs', 'navbar-buttons'].forEach(function(id) {
                var el = document.getElementById(id);
                if (el) el.innerHTML = '';
            });
        });

        document.addEventListener('up:fragment:inserted', function(event) {
            // For app-injected navbar elements (e.g. marble's org menu):
            // if the inline jQuery script couldn't move them (because stale copies exist
            // in the navbar), move them here after insertion.
            var fragment = event && event.target;
            var isMain = fragment && fragment.hasAttribute && fragment.hasAttribute('up-main');
            if (isMain && fragment.querySelector) {
                var navbarButtons = document.getElementById('navbar-buttons');
                if (navbarButtons) {
                    var orgMenu = fragment.querySelector('#active-org-menu');
                    if (orgMenu) {
                        // Remove any stale copy already in the navbar before adding the fresh one.
                        var stale = navbarButtons.querySelector('#active-org-menu');
                        if (stale) stale.remove();
                        navbarButtons.appendChild(orgMenu);
                    }
                }
            }
            if (document.querySelectorAll('.modal.in, .modal.show').length === 0) {
                document.querySelectorAll('.modal-backdrop').forEach(function(el) { el.remove(); });
                document.body.classList.remove('modal-open');
                document.body.style.paddingRight = '';
            }
            runPostRenderInits(document);
        });

        document.addEventListener('up:rendered', function() {
            runPostRenderInits(document);
        });

        runPostRenderInits(document);
    }

    function ensureCssOnce(url, dataAttr) {
        var existing = document.querySelector('link[' + dataAttr + '="true"]');
        if (existing) return;
        var link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = url;
        link.setAttribute(dataAttr, 'true');
        document.head.appendChild(link);
    }

    function loadScriptOnce(url, dataAttr) {
        return new Promise(function(resolve, reject) {
            var existing = document.querySelector('script[' + dataAttr + '="true"]');
            if (existing) {
                if (existing.dataset.loaded === 'true') return resolve();
                existing.addEventListener('load', function() { resolve(); }, { once: true });
                existing.addEventListener('error', function(err) { reject(err); }, { once: true });
                return;
            }
            var script = document.createElement('script');
            script.src = url;
            script.async = false;
            script.setAttribute(dataAttr, 'true');
            script.addEventListener('load', function() {
                script.dataset.loaded = 'true';
                resolve();
            }, { once: true });
            script.addEventListener('error', function(err) { reject(err); }, { once: true });
            document.head.appendChild(script);
        });
    }

    function ensureFullCalendarAssets() {
        if (window.$ && $.fn && $.fn.fullCalendar) return Promise.resolve();
        if (fullCalendarAssetsPromise) return fullCalendarAssetsPromise;

        ensureCssOnce(FC3_CSS_URL, 'data-moqui-fc3-css');
        fullCalendarAssetsPromise = Promise.resolve()
            .then(function() {
                if (!(window.$ && $.fn)) throw new Error('jQuery not available for FullCalendar');
                return loadScriptOnce(FC3_JS_URL, 'data-moqui-fc3-js');
            })
            .then(function() { return loadScriptOnce(FC3_LOCALE_URL, 'data-moqui-fc3-locale'); })
            .then(function() {
                if (!(window.$ && $.fn && $.fn.fullCalendar)) throw new Error('FullCalendar plugin unavailable after load');
            })
            .catch(function(err) {
                fullCalendarAssetsPromise = null;
                throw err;
            });

        return fullCalendarAssetsPromise;
    }

    function buildEventData(el) {
        var data = { moquiSessionToken: el.dataset.sessionToken || '' };
        if (el.dataset.partyId) data.partyId = el.dataset.partyId;
        if (el.dataset.facilityId) data.facilityId = el.dataset.facilityId;
        if (el.dataset.assetId) data.assetId = el.dataset.assetId;
        return data;
    }

    function initFullCalendarElement(el) {
        if (!el || !el.isConnected) return;

        ensureFullCalendarAssets().then(function() {
            if (!(window.$ && $.fn && $.fn.fullCalendar)) return;
            var $cal = $(el);
            var eventUrl = el.dataset.eventsUrl;
            if (!eventUrl) return;

            var sourceData = buildEventData(el);
            var eventSources = [{ url: eventUrl, type: 'POST', data: sourceData }];
            if (el.dataset.tasksUrl) {
                eventSources.push({
                    url: el.dataset.tasksUrl,
                    type: 'POST',
                    data: sourceData,
                    backgroundColor: '#5cb85c',
                    borderColor: '#4cae4c'
                });
            }

            try {
                if ($cal.data('fullCalendar')) $cal.fullCalendar('destroy');
            } catch (ignore) { }

            try {
                $cal.fullCalendar({
                    timezone: false,
                    defaultView: 'agendaWeek',
                    locale: el.dataset.locale || 'en',
                    header: { left: 'prev,next today', center: 'title', right: 'month,agendaWeek,agendaDay' },
                    eventSources: eventSources
                });
                el.dataset.fullcalendarInit = 'true';
            } catch (err) {
                console.error('FullCalendar load failed', err);
            }
        }).catch(function(err) {
            console.error('FullCalendar load failed', err);
            if (!el.querySelector('.alert')) {
                el.innerHTML = '<div class="alert alert-warning">Calendar assets unavailable</div>';
            }
        });
    }

    function initFullCalendars(root) {
        var scope = root && root.querySelectorAll ? root : document;
        var calendars = scope.querySelectorAll('.m-fullcalendar');
        calendars.forEach(function(el) { initFullCalendarElement(el); });
    }

    function initTooltips(root) {
        if (!(window.$ && $.fn && $.fn.tooltip)) return;
        var scope = root && root.querySelectorAll ? root : document;
        var tooltipElements = [];
        if (scope.matches && scope.matches('[data-bs-toggle="tooltip"], [data-toggle="tooltip"]')) tooltipElements.push(scope);
        scope.querySelectorAll('[data-bs-toggle="tooltip"], [data-toggle="tooltip"]').forEach(function(el) { tooltipElements.push(el); });
        tooltipElements.forEach(function(el) {
            var $el = $(el);
            if ($el.data('bs.tooltip')) return;
            $el.tooltip({ placement: 'auto top' });
        });
    }

    function normalizeBootstrapLegacyDataAttrs(root) {
        var scope = root && root.querySelectorAll ? root : document;
        var nodes = [];
        if (scope.matches && scope.matches('[data-toggle], [data-target], [data-dismiss]')) nodes.push(scope);
        scope.querySelectorAll('[data-toggle], [data-target], [data-dismiss]').forEach(function(el) { nodes.push(el); });
        if (!nodes.length) return;

        nodes.forEach(function(el) {
            var toggle = el.getAttribute('data-toggle');
            if (toggle && !el.getAttribute('data-bs-toggle')) el.setAttribute('data-bs-toggle', toggle);

            var target = el.getAttribute('data-target');
            if (target && !el.getAttribute('data-bs-target')) el.setAttribute('data-bs-target', target);

            var dismiss = el.getAttribute('data-dismiss');
            if (dismiss && !el.getAttribute('data-bs-dismiss')) el.setAttribute('data-bs-dismiss', dismiss);
        });
    }

    function normalizeDateTimePickerMarkup(root) {
        var scope = root && root.querySelectorAll ? root : document;
        var hosts = [];
        if (scope.matches && scope.matches('.input-group.date')) hosts.push(scope);
        scope.querySelectorAll('.input-group.date').forEach(function(el) { hosts.push(el); });
        if (!hosts.length) return;

        hosts.forEach(function(host) {
            host.querySelectorAll('.input-group-text').forEach(function(el) {
                if (!el.classList.contains('input-group-addon')) el.classList.add('input-group-addon');
            });
        });
    }

    function ensureBootstrapDropdownAndCollapseCompat() {
        if (window.__moquiBootstrapCompatBound) return;
        window.__moquiBootstrapCompatBound = true;

        document.addEventListener('click', function(ev) {
            var trigger = ev.target && ev.target.closest ? ev.target.closest('[data-toggle="dropdown"]') : null;
            if (!trigger) return;
            if (trigger.getAttribute('data-bs-toggle')) return;
            if (!(window.bootstrap && window.bootstrap.Dropdown)) return;
            ev.preventDefault();
            if (ev.stopPropagation) ev.stopPropagation();
            if (ev.stopImmediatePropagation) ev.stopImmediatePropagation();
            window.bootstrap.Dropdown.getOrCreateInstance(trigger).toggle();
        }, true);

        document.addEventListener('click', function(ev) {
            var trigger = ev.target && ev.target.closest ? ev.target.closest('[data-toggle="collapse"]') : null;
            if (!trigger) return;
            if (trigger.getAttribute('data-bs-toggle')) return;
            if (!(window.bootstrap && window.bootstrap.Collapse)) return;
            var selector = trigger.getAttribute('data-bs-target') || trigger.getAttribute('data-target') || trigger.getAttribute('href');
            if (!selector || selector.charAt(0) !== '#') return;
            var target = document.querySelector(selector);
            if (!target) return;
            ev.preventDefault();
            if (ev.stopPropagation) ev.stopPropagation();
            if (ev.stopImmediatePropagation) ev.stopImmediatePropagation();
            window.bootstrap.Collapse.getOrCreateInstance(target).toggle();
        }, true);
    }

    function ensureBootstrapJqueryCompat() {
        if (window.__moquiBootstrapJqueryCompatBound) return;
        window.__moquiBootstrapJqueryCompatBound = true;
        if (!(window.$ && $.fn)) return;

        // Bootstrap 5 removed jQuery plugins; keep compatibility for legacy Moqui scripts.
        if (typeof $.fn.tooltip !== 'function') {
            $.fn.tooltip = function(arg) {
                if (!(window.bootstrap && window.bootstrap.Tooltip)) return this;
                return this.each(function() {
                    var instance = window.bootstrap.Tooltip.getOrCreateInstance(this, (typeof arg === 'object' ? arg : undefined));
                    if (typeof arg === 'string' && typeof instance[arg] === 'function') instance[arg]();
                });
            };
        }

        if (typeof $.fn.dropdown !== 'function' && window.bootstrap && window.bootstrap.Dropdown) {
            $.fn.dropdown = function(arg) {
                return this.each(function() {
                    var instance = window.bootstrap.Dropdown.getOrCreateInstance(this);
                    var method = (typeof arg === 'string' ? arg : 'toggle');
                    if (typeof instance[method] === 'function') instance[method]();
                });
            };
        }

        if (typeof $.fn.collapse !== 'function' && window.bootstrap && window.bootstrap.Collapse) {
            $.fn.collapse = function(arg) {
                return this.each(function() {
                    var options = (typeof arg === 'object' ? arg : { toggle: false });
                    var instance = window.bootstrap.Collapse.getOrCreateInstance(this, options);
                    if (typeof arg === 'string' && typeof instance[arg] === 'function') {
                        instance[arg]();
                    } else if (arg == null || arg === true) {
                        instance.toggle();
                    }
                });
            };
        }
    }

    function ensureDateTimePickerClickCompat() {
        if (window.__moquiDateTimePickerClickCompatBound) return;
        window.__moquiDateTimePickerClickCompatBound = true;

        document.addEventListener('click', function(ev) {
            var iconTrigger = ev.target && ev.target.closest
                ? ev.target.closest('.input-group.date .input-group-addon, .input-group.date .input-group-text')
                : null;
            if (!iconTrigger) return;
            if (!(window.$ && $.fn && $.fn.datetimepicker)) return;

            var host = iconTrigger.closest('.input-group.date');
            if (!host) return;
            var $host = $(host);
            var picker = $host.data('DateTimePicker');
            if (!picker && typeof $host.datetimepicker === 'function') {
                try { $host.datetimepicker(); } catch (ignore) { }
                picker = $host.data('DateTimePicker');
            }
            if (picker && typeof picker.show === 'function') {
                ev.preventDefault();
                if (ev.stopPropagation) ev.stopPropagation();
                if (ev.stopImmediatePropagation) ev.stopImmediatePropagation();
                picker.show();
            }
        }, true);

        document.addEventListener('focusin', function(ev) {
            var inputEl = ev.target && ev.target.closest
                ? ev.target.closest('.input-group.date input.form-control')
                : null;
            if (!inputEl) return;
            if (!(window.$ && $.fn && $.fn.datetimepicker)) return;
            var host = inputEl.closest('.input-group.date');
            if (!host) return;
            var picker = $(host).data('DateTimePicker');
            if (picker && typeof picker.show === 'function') picker.show();
        }, true);
    }

    function ensureExternalSubmitButtonCompat() {
        if (window.__moquiExternalSubmitButtonCompatBound) return;
        window.__moquiExternalSubmitButtonCompatBound = true;

        document.addEventListener('click', function(ev) {
            var submitBtn = ev.target && ev.target.closest
                ? ev.target.closest('button[type="submit"][form], input[type="submit"][form]')
                : null;
            if (!submitBtn) return;
            if (ev.defaultPrevented) return;

            var formId = submitBtn.getAttribute('form');
            if (!formId) return;
            var formEl = document.getElementById(formId);
            if (!formEl || formEl.tagName !== 'FORM') return;

            // Only fallback for external submitters (outside the target form).
            if (submitBtn.closest && submitBtn.closest('form') === formEl) return;

            ev.preventDefault();
            try {
                if (typeof formEl.requestSubmit === 'function') formEl.requestSubmit(submitBtn);
                else formEl.submit();
            } catch (ignore) {
                try { formEl.submit(); } catch (ignore2) { }
            }
        }, false);
    }

    function ensureMoquiRuntimeCompat() {
        ensureMoquiModalSupport();
        ensureBootstrapDropdownAndCollapseCompat();
        ensureBootstrapJqueryCompat();
        ensureDateTimePickerClickCompat();
        ensureExternalSubmitButtonCompat();
    }

    function initSelect2(target, options, forceReinit) {
        if (!(window.$ && $.fn && $.fn.select2)) return;

        function repositionSelect2Dropdown($source, $dropdownParent) {
            if (!$source || !$source.length) return;
            var $selectionHost = $source.next('.select2');
            if (!$selectionHost.length) return;

            // Select2 appends one open container at a time.
            var $openDropdown = $('.select2-container--open').last();
            if (!$openDropdown.length) return;

            var parentEl = ($dropdownParent && $dropdownParent.length) ? $dropdownParent[0] : document.body;
            var selectionEl = $selectionHost[0];
            if (!selectionEl || !selectionEl.getBoundingClientRect) return;

            var selRect = selectionEl.getBoundingClientRect();
            var parentRect = (parentEl && parentEl.getBoundingClientRect)
                ? parentEl.getBoundingClientRect()
                : { top: 0, left: 0 };
            var parentScrollTop = parentEl ? (parentEl.scrollTop || 0) : 0;
            var parentScrollLeft = parentEl ? (parentEl.scrollLeft || 0) : 0;

            var top = selRect.bottom - parentRect.top + parentScrollTop;
            var left = selRect.left - parentRect.left + parentScrollLeft;
            var width = $selectionHost.outerWidth();

            $openDropdown.css({
                top: top + 'px',
                left: left + 'px',
                width: width + 'px'
            });
        }

        var $targets = target ? $(target) : $();
        $targets.each(function() {
            var $el = $(this);
            if (!forceReinit && ($el.data('select2') || this.classList.contains('select2-hidden-accessible'))) return;
            if (forceReinit && $el.data('select2')) {
                try { $el.select2('destroy'); } catch (ignore) { }
            }
            var select2Options = $.extend({}, options || {});
            if (!select2Options.dropdownParent) {
                // In modals, use modal root as dropdown parent to avoid wrong offsets in scrollable bodies.
                var modalEl = this.closest ? this.closest('.modal') : null;
                if (modalEl) select2Options.dropdownParent = $(modalEl);
            }
            $el.select2(select2Options);

            var dropdownParent = (select2Options.dropdownParent && select2Options.dropdownParent.length)
                ? select2Options.dropdownParent
                : null;
            var reposition = function() {
                repositionSelect2Dropdown($el, dropdownParent);
            };

            $el.off('select2:open.moquiPos').on('select2:open.moquiPos', function() {
                reposition();
                if (window.requestAnimationFrame) window.requestAnimationFrame(reposition);
                setTimeout(reposition, 0);
                if (dropdownParent) {
                    dropdownParent.off('scroll.moquiS2Pos').on('scroll.moquiS2Pos', reposition);
                }
                var modalBody = this.closest ? this.closest('.modal-body') : null;
                if (modalBody) $(modalBody).off('scroll.moquiS2BodyPos').on('scroll.moquiS2BodyPos', reposition);
                $(window).off('resize.moquiS2Pos').on('resize.moquiS2Pos', reposition);
            });
            $el.off('select2:close.moquiPos').on('select2:close.moquiPos', function() {
                if (dropdownParent) dropdownParent.off('scroll.moquiS2Pos');
                var modalBody = this.closest ? this.closest('.modal-body') : null;
                if (modalBody) $(modalBody).off('scroll.moquiS2BodyPos');
                $(window).off('resize.moquiS2Pos');
            });
        });
    }

    function initDateTimePicker(target, options, forceReinit) {
        if (!(window.$ && $.fn && $.fn.datetimepicker)) return;
        var $targets = target ? $(target) : $();
        $targets.each(function() {
            var $el = $(this);
            // bootstrap-datetimepicker 4.x expects legacy .input-group-addon.
            $el.find('.input-group-text').addClass('input-group-addon');
            var hasPicker = !!$el.data('DateTimePicker');
            var mergeOnExisting = !!(options && options.__moquiMergeOnExisting);
            if (!forceReinit && hasPicker) {
                if (mergeOnExisting) {
                    try {
                        var picker = $el.data('DateTimePicker');
                        var mergedOptions = $.extend({}, options);
                        delete mergedOptions.__moquiMergeOnExisting;
                        if (picker && typeof picker.options === 'function') picker.options(mergedOptions);
                    } catch (ignore) { }
                }
                return;
            }
            if (forceReinit && hasPicker) {
                try { $el.data('DateTimePicker').destroy(); } catch (ignore) { }
            }
            var initOptions = $.extend({
                ignoreReadonly: true,
                allowInputToggle: true,
                focusOnShow: false
            }, options || {});
            delete initOptions.__moquiMergeOnExisting;
            $el.datetimepicker(initOptions);
        });
    }

    function initDateTimePickerDefaults(root) {
        if (!(window.$ && $.fn && $.fn.datetimepicker)) return;
        var scope = root && root.querySelectorAll ? root : document;
        var pickerHosts = [];
        if (scope.matches && scope.matches('.input-group.date')) pickerHosts.push(scope);
        scope.querySelectorAll('.input-group.date').forEach(function(el) { pickerHosts.push(el); });
        if (!pickerHosts.length) return;

        var localeTag = (window.moment && moment.locale && moment.locale()) || 'en';
        var defaults = {
            toolbarPlacement: 'top',
            showClose: true,
            showClear: true,
            showTodayButton: true,
            useStrict: true,
            format: 'YYYY-MM-DD',
            extraFormats: ['l', 'L', 'YYYY-MM-DD'],
            locale: localeTag,
            keyBinds: {
                t: function() { if (window.moment) this.date(moment()); },
                up: function() { this.date(this.date().clone().add(1, 'd')); },
                down: function() { this.date(this.date().clone().subtract(1, 'd')); },
                'control up': function() { this.date(this.date().clone().add(1, 'd')); },
                'control down': function() { this.date(this.date().clone().subtract(1, 'd')); }
            }
        };
        initDateTimePicker($(pickerHosts), defaults, false);
    }

    function initValidator(target, options) {
        if (!(window.$ && $.fn && $.fn.validate)) return null;
        var $el = target ? $(target) : $();
        if (!$el.length) return null;
        var defaults = {
            errorClass: 'help-block',
            errorElement: 'span',
            highlight: function(element) { $(element).parents('.form-group').removeClass('has-success').addClass('has-error'); },
            unhighlight: function(element) { $(element).parents('.form-group').removeClass('has-error').addClass('has-success'); }
        };
        return $el.validate($.extend(true, {}, defaults, options || {}));
    }

    function initSelectivity(target, options) {
        if (!(window.$ && $.fn && $.fn.selectivity)) return null;
        var $el = target ? $(target) : $();
        if (!$el.length) return null;
        return $el.selectivity(options || { });
    }

    function initInputMask(target, mask) {
        if (!(window.$ && $.fn && $.fn.inputmask)) return;
        var $targets = target ? $(target) : $();
        $targets.each(function() {
            try { $(this).inputmask(mask); } catch (ignore) { }
        });
    }

    function runPostRenderInits(root) {
        ensureMoquiRuntimeCompat();
        normalizeBootstrapLegacyDataAttrs(root);
        normalizeDateTimePickerMarkup(root);
        initTooltips(root);
        initDateTimePickerDefaults(root);
        initFullCalendars(root);
    }

    if (typeof window.moquiInitTooltips !== 'function') {
        window.moquiInitTooltips = initTooltips;
    }
    if (typeof window.moquiInitSelect2 !== 'function') {
        window.moquiInitSelect2 = initSelect2;
    }
    if (typeof window.moquiInitDateTimePicker !== 'function') {
        window.moquiInitDateTimePicker = initDateTimePicker;
    }
    if (typeof window.moquiInitDateTimePickers !== 'function') {
        window.moquiInitDateTimePickers = initDateTimePicker;
    }
    if (typeof window.moquiInitValidator !== 'function') {
        window.moquiInitValidator = initValidator;
    }
    if (typeof window.moquiInitSelectivity !== 'function') {
        window.moquiInitSelectivity = initSelectivity;
    }
    if (typeof window.moquiInitInputMask !== 'function') {
        window.moquiInitInputMask = initInputMask;
    }
    if (typeof window.moquiRunPostRenderInits !== 'function') {
        window.moquiRunPostRenderInits = runPostRenderInits;
    }

    ensureMoquiRuntimeCompat();

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            ensureMoquiRuntimeCompat();
            initUnpolyDefaults();
        });
    } else {
        ensureMoquiRuntimeCompat();
        initUnpolyDefaults();
    }
})();
