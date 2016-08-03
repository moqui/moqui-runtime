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
<#if ec.factory.serverContainer?has_content><#-- make sure WebSocket server is in place -->
    <#-- NotificationClient, note that does not connect the WebSocket until notificationClient.registerListener() is called the first time -->
    function NotifyOptions(message, url, type, icon) {
        this.message = message;
        if (url) this.url = url;
        if (icon) {
            this.icon = icon;
        } else {
            if (type == 'success') this.icon = 'glyphicon glyphicon-ok-sign';
            else if (type == 'warning') this.icon = 'glyphicon glyphicon-warning-sign';
            else if (type == 'danger') this.icon = 'glyphicon glyphicon-exclamation-sign';
            else this.icon = 'glyphicon glyphicon-info-sign';
        }
    }
    function NotifySettings(type) {
        this.delay = 6000; this.offset = { x:20, y:70 };
        this.animate = { enter:'animated fadeInDown', exit:'animated fadeOutUp' };
        if (type) { this.type = type; } else { this.type = 'info'; }
        this.template = '<div data-notify="container" class="notify-container col-xs-11 col-sm-3 alert alert-{0}" role="alert">' +
                '<button type="button" aria-hidden="true" class="close" data-notify="dismiss">&times;</button>' +
                '<span data-notify="icon"></span> <span data-notify="message">{2}</span>' +
                '<a href="{3}" target="{4}" data-notify="url"></a>' +
            '</div>'
    }
    function NotificationClient(webSocketUrl) {
        this.displayEnable = true;
        this.webSocketUrl = webSocketUrl;
        this.topicListeners = {};

        this.disableDisplay = function() { this.displayEnable = false; };
        this.enableDisplay = function() { this.displayEnable = true; };

        this.initWebSocket = function() {
            this.webSocket = new WebSocket(this.webSocketUrl);
            this.webSocket.clientObj = this;

            this.webSocket.onopen = function(event) {
                var topics = [];
                for (var topic in this.clientObj.topicListeners) { topics.push(topic); }
                this.send("subscribe:" + topics.join(","));
            };
            this.webSocket.onmessage = function(event) {
                var jsonObj = JSON.parse(event.data);
                var callbacks = this.clientObj.topicListeners[jsonObj.topic];
                if (callbacks) callbacks.forEach(function(callback) { callback(jsonObj, this) }, this);
                var allCallbacks = this.clientObj.topicListeners["ALL"];
                if (allCallbacks) allCallbacks.forEach(function(allCallbacks) { allCallbacks(jsonObj, this) }, this);
            };
            this.webSocket.onclose = function(event) { console.log(event); };
            this.webSocket.onerror = function(event) { console.log(event); };
        };

        this.displayNotify = function(jsonObj, webSocket) {
            if (!webSocket.clientObj.displayEnable) return;
            // console.log(jsonObj);
            if (jsonObj.title && jsonObj.showAlert == true) {
                $.notify(new NotifyOptions(jsonObj.title, jsonObj.link, jsonObj.type, jsonObj.icon), new NotifySettings(jsonObj.type));
            }
        };
        this.registerListener = function(topic, callback) {
            if (!this.webSocket) this.initWebSocket();

            if (!callback) callback = this.displayNotify;
            var listenerArray = this.topicListeners[topic];
            if (!listenerArray) {
                listenerArray = [];
                this.topicListeners[topic] = listenerArray;
                if (this.webSocket.readyState == WebSocket.OPEN) this.webSocket.send("subscribe:" + topic);
            }
            if (listenerArray.indexOf(callback) < 0) { listenerArray.push(callback); }
        };
    }
    var notificationClient = new NotificationClient("ws://${ec.web.getHostName(true)}${ec.web.servletContext.contextPath}/notws");
</#if>
<#-- Example Notification Listener Registration (note listener method defaults to displayNotify as in first example;
    you can register more than one listener method for the same topic):
<#if ec.factory.serverContainer?has_content>
    <script>
        notificationClient.registerListener("ALL"); // register for all topics
        notificationClient.registerListener("MantleEvent", notificationClient.displayNotify);
    </script>
</#if>
-->
