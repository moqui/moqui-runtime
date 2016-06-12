<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <#if html_keywords?has_content><meta name="keywords" content="${html_keywords}"></#if>
    <#if html_description?has_content><meta name="description" content="${html_description}"></#if>
    <#assign parentMenuName = (sri.screenUrlInfo.parentScreen.getDefaultMenuName())!"">
    <#assign defaultMenuName = sri.screenUrlInfo.targetScreen.getDefaultMenuName()>
    <title><#if html_title?has_content>${html_title}<#else><#-- ${ec.l10n.localize((ec.tenant.tenantName)!'Moqui')}--><#if parentMenuName?has_content>${ec.resource.expand(parentMenuName, "")} - </#if><#if defaultMenuName?has_content>${ec.resource.expand(defaultMenuName, "")}</#if></#if></title>
    <link rel="apple-touch-icon" href="/MoquiLogo100.png"/>
<#-- Style Sheets -->
<#list sri.getThemeValues("STRT_STYLESHEET") as styleSheetLocation>
    <link rel="stylesheet" href="${sri.buildUrl(styleSheetLocation).url}" type="text/css">
</#list>
<#list html_stylesheets?if_exists as styleSheetLocation>
    <link rel="stylesheet" href="${sri.buildUrl(styleSheetLocation).url}" type="text/css">
</#list>
<#-- JavaScript -->
<#list html_scripts?if_exists as scriptLocation>
    <script language="javascript" src="${sri.buildUrl(scriptLocation).url}" type="text/javascript"></script>
</#list>
<#list sri.getThemeValues("STRT_SCRIPT") as scriptLocation>
    <script language="javascript" src="${sri.buildUrl(scriptLocation).url}" type="text/javascript"></script>
</#list>
<#-- Icon -->
<#list sri.getThemeValues("STRT_SHORTCUT_ICON") as iconLocation>
    <link rel="shortcut icon" href="${sri.buildUrl(iconLocation).url}">
</#list>

<#if ec.factory.serverContainer?has_content><#-- make sure WebSocket server is in place -->
    <#-- NotificationClient, note that does not connect the WebSocket until notificationClient.registerListener() is called the first time -->
    <script>
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
    </script>
</#if>
<#-- Example Notification Listener Registration (note listener method defaults to displayNotify as in first example;
    you can register more than one listener method for the same topic):
<#if ec.factory.serverContainer?has_content>
    <script>
        notificationClient.registerListener("MantleTask");
        notificationClient.registerListener("MantleEvent", notificationClient.displayNotify);
    </script>
</#if>
-->

</head>

<#assign bodyClassList = sri.getThemeValues("STRT_BODY_CLASS")>
<body class="${(ec.user.getPreference("OUTER_STYLE")!(bodyClassList?first))!"bg-light"} ${(sri.screenUrlInfo.targetScreen.screenName)!""}"><!-- try "bg-dark" or "bg-light" -->
