/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */

var moqui = {
    isString: function(obj) { return typeof obj === 'string'; },
    isBoolean: function(obj) { return typeof obj === 'boolean'; },
    isNumber: function(obj) { return typeof obj === 'number'; },
    isArray: function(obj) { return Object.prototype.toString.call(obj) === '[object Array]'; },
    isFunction: function(obj) { return Object.prototype.toString.call(obj) === '[object Function]'; },
    isPlainObject: function(obj) { return obj != null && typeof obj == 'object' && Object.prototype.toString.call(obj) === '[object Object]'; },

    htmlEncode: function(value) { return $('<div/>').text(value).html(); },
    htmlDecode: function(value) { return $('<div/>').html(value).text(); },

    // return a function that delay the execution
    debounce: function(func, wait) {
        var timeout, result;
        return function() {
            var context = this, args = arguments, later;
            later = function() {
                timeout = null;
                result = func.apply(context, args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            return result;
        };
    },
    // function to set columns across multiple tables to the same width
    makeColumnsConsistent: function(outerId) {
        var tableArr = $('#' + outerId + ' table');
        // console.log(tableArr);
        var widthMaxArr = [];
        var i, j, curTable, row, rowIdx;
        for (i = 0; i < tableArr.length; i++) {
            curTable = tableArr[i];
            if (!curTable.rows || curTable.rows.length === 0) continue;
            rowIdx = 0; row = curTable.rows[rowIdx];
            while (rowIdx < 5 && rowIdx < curTable.rows.length) {
                if ((!row.cells || row.cells.length <= 1) && curTable.rows.length > (rowIdx + 1)) {
                    rowIdx++; row = curTable.rows[rowIdx]; } else { break; }
            }
            if (!row.cells || row.cells.length === 0) continue;
            for (j = 0; j < row.cells.length; j++) {
                var curWidth = $(row.cells[j]).width();
                if (!widthMaxArr[j] || widthMaxArr[j] < curWidth) widthMaxArr[j] = curWidth;
            }
        }
        // console.log("Columns max widths: " + widthMaxArr);
        var numCols = widthMaxArr.length;
        var totalWidth = 0; for (i = 0; i < numCols; i++) totalWidth += widthMaxArr[i];
        var widthPercents = []; for (i = 0; i < numCols; i++) widthPercents[i] = (widthMaxArr[i] * 100) / totalWidth;
        // console.log("Columns " + numCols + ", percents: " + widthPercents);
        for (i = 0; i < tableArr.length; i++) {
            curTable = tableArr[i];
            if (!curTable.rows || curTable.rows.length === 0) continue;
            rowIdx = 0; row = curTable.rows[rowIdx];
            while (rowIdx < 5 && rowIdx < curTable.rows.length) {
                if ((!row.cells || row.cells.length <= 1) && curTable.rows.length > (rowIdx + 1)) {
                    rowIdx++; row = curTable.rows[rowIdx]; } else { break; }
            }
            if (!row.cells || row.cells.length === 0) continue;
            for (j = 0; j < row.cells.length; j++) {
                // console.log("setting table " + i + " row " + rowIdx + " col " + j + " to " + widthPercents[j]);
                row.cells[j].style.width = widthPercents[j]+'%';
            }
        }
    },

    downloadData: function download(data, filename, type) {
        var file = new Blob([data], {type: type});
        if (window.navigator.msSaveOrOpenBlob) { // IE10+
            window.navigator.msSaveOrOpenBlob(file, filename);
        } else { // Others
            var a = document.createElement("a"), url = URL.createObjectURL(file);
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            setTimeout(function() { document.body.removeChild(a); window.URL.revokeObjectURL(url); }, 0);
        }
    },

    notifyNotification: function (jsonObj, fallback) {
        if (!jsonObj) return;
        var notificationOptions = {};
        if (jsonObj.topic && jsonObj.topic.length) notificationOptions.tag = jsonObj.topic;
        // consider options 'body' and 'icon' (icon URL, any way to use glyphicon class?)
        if (window.Notification && Notification.permission === "granted") {
            var notif = new Notification(jsonObj.title, notificationOptions);
            if (jsonObj.link && jsonObj.link.length) notif.onclick = function () { window.open(jsonObj.link); };
            if (moqui.webrootVue) { moqui.webrootVue.addNotify(jsonObj.title, jsonObj.type); }
        } else if (window.Notification && Notification.permission !== "denied") {
            Notification.requestPermission(function (status) {
                if (status === "granted") {
                    var notif = new Notification(jsonObj.title, notificationOptions);
                    if (jsonObj.link && jsonObj.link.length) notif.onclick = function () { window.open(jsonObj.link); };
                    if (moqui.webrootVue) { moqui.webrootVue.addNotify(jsonObj.title, jsonObj.type); }
                } else { fallback(jsonObj); }
            });
        } else { fallback(jsonObj); }
    },

    NotifyOptions: function(message, url, type, icon) {
        // console.warn("notify options message: [" + message + "] encoded: " + moqui.htmlEncode(message));
        this.message = moqui.htmlEncode(message);
        if (url) this.url = url;
        if (icon) { this.icon = icon; }
        else {
            if (type === 'success') this.icon = 'glyphicon glyphicon-ok-sign';
            else if (type === 'warning') this.icon = 'glyphicon glyphicon-warning-sign';
            else if (type === 'danger') this.icon = 'glyphicon glyphicon-exclamation-sign';
            else this.icon = 'glyphicon glyphicon-info-sign';
        }
    },
    NotifySettings: function(type) {
        this.delay = 4000; this.offset = { x:20, y:60 }; this.placement = {from:'top',align:'right'};
        this.animate = { enter:'animated fadeInDown', exit:'' }; // no animate on exit: animated fadeOutUp
        if (type) { this.type = type; } else { this.type = 'info'; }
        this.template =
            '<div data-notify="container" class="notify-container col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
                '<button type="button" aria-hidden="true" class="close" data-notify="dismiss">&times;</button>' +
                '<span data-notify="icon"></span> <span data-notify="message">{2}</span>' +
                '<a href="{3}" target="{4}" data-notify="url"></a>' +
            '</div>';
    },
    notifyGrowl: function (jsonObj) {
        if (!jsonObj) return;
        $.notify(new moqui.NotifyOptions(jsonObj.title, jsonObj.link, jsonObj.type, jsonObj.icon), new moqui.NotifySettings(jsonObj.type));
        if (moqui.webrootVue) { moqui.webrootVue.addNotify(jsonObj.title, jsonObj.type); }
    },

    /* NotificationClient, note does not connect the WebSocket until notificationClient.registerListener() is called the first time */
    NotificationClient: function(webSocketUrl) {
        this.displayEnable = true;
        this.webSocketUrl = webSocketUrl;
        this.topicListeners = {};
        this.disableDisplay = function() { this.displayEnable = false; };
        this.enableDisplay = function() { this.displayEnable = true; };
        this.initWebSocket = function() {
            this.webSocket = new WebSocket(this.webSocketUrl);
            this.webSocket.clientObj = this;
            this.webSocket.onopen = function(event) {
                this.clientObj.tryReopenCount = 0;
                var topics = []; for (var topic in this.clientObj.topicListeners) { topics.push(topic); }
                this.send("subscribe:" + topics.join(","));
            };
            this.webSocket.onmessage = function(event) {
                var jsonObj = JSON.parse(event.data);
                var callbacks = this.clientObj.topicListeners[jsonObj.topic];
                if (callbacks) callbacks.forEach(function(callback) { callback(jsonObj, this) }, this);
                var allCallbacks = this.clientObj.topicListeners["ALL"];
                if (allCallbacks) allCallbacks.forEach(function(allCallbacks) { allCallbacks(jsonObj, this) }, this);
            };
            this.webSocket.onclose = function(event) {
                console.log(event);
                setTimeout(this.clientObj.tryReopen, 30*1000, this.clientObj);
            };
            this.webSocket.onerror = function(event) { console.log(event); };
        };
        this.tryReopen = function (clientObj) {
            if ((!clientObj.webSocket || clientObj.webSocket.readyState === WebSocket.CLOSED || clientObj.webSocket.readyState === WebSocket.CLOSING) &&
                    (!clientObj.tryReopenCount || clientObj.tryReopenCount < 6)) {
                console.log("Trying WebSocket reopen, count " + clientObj.tryReopenCount);
                clientObj.tryReopenCount = (clientObj.tryReopenCount || 0) + 1;
                clientObj.initWebSocket();
                // no need to call this, onclose gets called when WS connect fails: setTimeout(clientObj.tryReopen, 30*1000, clientObj);
            }
        };
        this.displayNotify = function(jsonObj, webSocket) {
            if (!webSocket.clientObj.displayEnable) return; // console.log(jsonObj);
            if (jsonObj.title && jsonObj.showAlert === true) {
                moqui.notifyNotification(jsonObj, moqui.notifyGrowl);
            }
        };
        this.registerListener = function(topic, callback) {
            if (!this.webSocket) this.initWebSocket();
            if (!callback) callback = this.displayNotify;
            var listenerArray = this.topicListeners[topic];
            if (!listenerArray) {
                listenerArray = []; this.topicListeners[topic] = listenerArray;
                if (this.webSocket.readyState === WebSocket.OPEN) this.webSocket.send("subscribe:" + topic);
            }
            if (listenerArray.indexOf(callback) < 0) { listenerArray.push(callback); }
        };
    },
    /* Example Notification Listener Registration (note listener method defaults to displayNotify as in first example;
         you can register more than one listener method for the same topic):
     <#if ec.factory.serverContainer?has_content>
     <script>
     notificationClient.registerListener("ALL"); // register for all topics
     notificationClient.registerListener("MantleEvent", notificationClient.displayNotify);
     </script>
     </#if>
    */

    LruMap: function(limit) {
        this.limit = limit; this.valueMap = {}; this.lruList = []; // end of list is least recently used
        this.put = function(key, value) {
            var lruList = this.lruList; var valueMap = this.valueMap;
            valueMap[key] = value; this._keyUsed(key);
            while (lruList.length > this.limit) { var rem = lruList.pop(); valueMap[rem] = null; }
        };
        this.get = function (key) {
            var value = this.valueMap[key];
            if (value) { this._keyUsed(key); }
            return value;
        };
        this.containsKey = function (key) { return !!this.valueMap[key]; };
        this._keyUsed = function(key) {
            var lruList = this.lruList;
            var lruIdx = -1;
            for (var i=0; i<lruList.length; i++) { if (lruList[i] === key) { lruIdx = i; break; }}
            if (lruIdx >= 0) { lruList.splice(lruIdx,1); }
            lruList.unshift(key);
        };
    }
};

if ($.fn.select2) {
    // set defaults for select2
    $.fn.select2.defaults.set("theme", "bootstrap");
    $.fn.select2.defaults.set("minimumResultsForSearch", "10");
    $.fn.select2.defaults.set("dropdownAutoWidth", true);
    // for select2 with multiple delete item on backspace instead of changing it to text
    $.fn.select2.amd.require(['select2/selection/search'], function (Search) {
        var oldRemoveChoice = Search.prototype.searchRemoveChoice;
        Search.prototype.searchRemoveChoice = function () { oldRemoveChoice.apply(this, arguments); this.$search.val(''); };
    });
    $.fn.select2.defaults.set("selectOnClose", true);

    // custom event handler: programmatically trigger validation
    $(function() { $('.select2-hidden-accessible').on('select2:select', function(evt) { $(this).valid(); }); });

    if ($.fn.modal) {
        // this is a fix for Select2 search input within Bootstrap Modal
        $.fn.modal.Constructor.prototype.enforceFocus = function() {};
    }
}

if ($.validator) {
// set jQuery Validator defaults that work with select2
    $.validator.setDefaults({ errorPlacement: function (error, element) {
            if (element.parent('.twitter-typeahead').length) { error.insertAfter(element.parent()); /* typeahead */ }
            else if (element.parent('.input-group').length) { error.insertAfter(element.parent()); /* radio/checkbox? */ }
            else if (element.hasClass('select2-hidden-accessible')) { error.insertAfter(element.next('span')); /* select2 */ }
            else { error.insertAfter(element); /* default */ }
        }});
// jQuery Validator does not work well with bootstrap popover http://stackoverflow.com/a/30539639/244431, this patches it.
    $.validator.prototype.errorsFor = function(element) {
        var name = this.escapeCssMeta(this.idOrName(element)), selector = "label[for='" + name + "'], label[for='" + name + "'] *";
        // 'aria-describedby' should directly reference the error element
        if (this.settings.errorElement !== 'label') { selector = selector + ", #" + name + '-error'; }
        return this.errors().filter(selector);
    };
    $.validator.prototype.errors = function() {
        var errorClass = this.settings.errorClass.split(" ").join(".");
        if (this.errorContext.is && this.errorContext.is("form")) {
            // Moqui change here: if the error context is the form then look for error element under grandparent of each form element
            return $(this.currentForm.elements).parents().parents().find(this.settings.errorElement + "." + errorClass);
        } else {
            return $(this.settings.errorElement + "." + errorClass, this.errorContext);
        }
    };
// jQuery Validator does not support inputs/etc added to a form using the HTML5 @form attribute (for form-list, form-single in some cases)
    $.validator.prototype.elements = function() {
        var validator = this, rulesCache = {};
        // Select all valid inputs inside the form (no submit or reset buttons)
        // NOTE: this line modified to use .elements and filter instead of find
        return $(this.currentForm.elements).filter(":input, [contenteditable]").not(":submit, :reset, :image, :disabled").not(this.settings.ignore)
            .filter(function() {
                var name = this.name || $(this).attr("name"); // For contenteditable
                if (!name && window.console) { console.error("%o has no name assigned", this); }

                // Set form expando on contenteditable
                if (this.hasAttribute("contenteditable")) { this.form = $(this).closest("form")[0]; this.name = name; }

                // Select only the first element for each name, and only those with rules specified
                if (name in rulesCache || !validator.objectLength($(this).rules())) { return false; }

                rulesCache[name] = true;
                return true;
            });
    };
    $.validator.prototype.init = function() {
        this.labelContainer = $(this.settings.errorLabelContainer);
        this.errorContext = this.labelContainer.length && this.labelContainer || $(this.currentForm);
        this.containers = $(this.settings.errorContainer).add(this.settings.errorLabelContainer);
        this.submitted = {};
        this.valueCache = {};
        this.pendingRequest = 0;
        this.pending = {};
        this.invalid = {};
        this.reset();

        var groups = (this.groups = {}), rules;
        $.each(this.settings.groups, function(key, value) {
            if (typeof value === "string") { value = value.split(/\s/); }
            $.each(value, function(index, name) { groups[name] = key; });
        });
        rules = this.settings.rules;
        $.each(rules, function(key, value) { rules[key] = $.validator.normalizeRule(value); });

        function delegate(event) {
            // Set form expando on contenteditable
            if (!this.form && this.hasAttribute("contenteditable")) {
                this.form = $(this).closest("form")[0];
                this.name = $(this).attr("name");
            }

            var validator = $.data(this.form, "validator"), eventType = "on" + event.type.replace(/^validate/, ""), settings = validator.settings;
            if (settings[eventType] && !$(this).is(settings.ignore)) { settings[eventType].call(validator, this, event); }
        }

        // BEGIN Moqui changes for .elements and filter instead of find
        var onElements = $(this.currentForm.elements).filter(":input, [contenteditable]").not(":submit, :reset, :image, :disabled").not(this.settings.ignore);
        onElements.on("focusin.validate focusout.validate keyup.validate", delegate);
        // Support: Chrome, oldIE
        // "select" is provided as event.target when clicking a option
        onElements.on("click.validate", "select, option, [type='radio'], [type='checkbox']", delegate);
        // END Moqui changes
    };
}

// a date/time alias for inputmask
if (window.Inputmask) {
    Inputmask.extendAliases({
        'yyyy-mm-dd hh:mm': {
            mask:"y-1-2 h:s", placeholder:"yyyy-mm-dd hh:mm", alias:"datetime", separator:"-", leapday:"-02-29",
            regex: {
                val2pre: function (separator) {
                    var escapedSeparator = Inputmask.escapeRegex.call(this, separator);
                    return new RegExp("((0[13-9]|1[012])" + escapedSeparator + "[0-3])|(02" + escapedSeparator + "[0-2])");
                }, //daypre
                val2: function (separator) {
                    var escapedSeparator = Inputmask.escapeRegex.call(this, separator);
                    return new RegExp("((0[1-9]|1[012])" + escapedSeparator + "(0[1-9]|[12][0-9]))|((0[13-9]|1[012])" + escapedSeparator + "30)|((0[13578]|1[02])" + escapedSeparator + "31)");
                }, //day
                val1pre: new RegExp("[01]"), //monthpre
                val1: new RegExp("0[1-9]|1[012]") //month
            },
            onKeyDown: function (e, buffer, caretPos, opts) { }
        }
    });
}
