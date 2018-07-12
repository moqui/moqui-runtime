/* This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License. */
if (window.qz && window.moqui) {
    console.info("Creating QZ component");
    moqui.qzVue = {
        template:
        '<span>' +
            '<button id="qz-print-modal-link" type="button" class="btn btn-sm navbar-btn navbar-right" :class="readyStyleBtn" data-toggle="modal" data-target="#qz-print-modal" title="Print Options"><i class="glyphicon glyphicon-print"></i></button>' +
            '<div class="modal fade" id="qz-print-modal" tabindex="-1" role="dialog" aria-labelledby="qz-print-modal-label">' +
                '<div class="modal-dialog" role="document"><div class="modal-content">' +
                    '<div class="modal-header">' +
                        '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
                        '<h4 class="modal-title" id="qz-print-modal-label">QZ Print Options</h4>' +
                    '</div>' +
                    '<div class="modal-body">' +
                        '<div id="qz-connection" class="row"><div class="col-xs-8">' +
                            '<h4 :class="connectionClass">Connection: {{connectionState}}<span v-if="qzVersion" class="text-muted"> ver {{qzVersion}}</span></h4>' +
                        '</div><div class="col-xs-4 text-right">' +
                            '<button v-if="connectionState !== \'Active\'" type="button" class="btn btn-success btn-sm" @click="startConnection()">Connect</button>' +
                            '<button v-if="connectionState === \'Active\'" type="button" class="btn btn-warning btn-sm" @click="endConnection()">Disconnect</button>' +
                        '</div></div>' +
                        '<div class="panel panel-default">' +
                            '<div class="panel-heading"><h5 class="panel-title">Printers: Main <span class="text-info">{{currentPrinter||"not set"}}</span> Label <span class="text-info">{{currentLabelPrinter||"not set"}}</span></h5>' +
                                '<div class="panel-toolbar"><button type="button" class="btn btn-default btn-sm" @click="findPrinters()">Find</button></div></div>' +
                            '<div class="panel-body"><div class="row">' +
                                '<div v-for="printerName in printerList" class="col-xs-6">{{printerName}} <button type="button" class="btn btn-default btn-sm" @click="setPrinter(printerName)">Main</button><button type="button" class="btn btn-default btn-sm" @click="setLabelPrinter(printerName)">Label</button></div>' +
                            '</div>' +
                        '</div></div>' +
                    '</div>' +
                '</div></div>' +
            '</div>' +
        '</span>',
        data: function() { return { connectionState:'Inactive', connectionClass:'text-muted', qzVersion:null,
                currentPrinter:null, currentLabelPrinter:null, printerList:[] } },
        methods: {
            findPrinters: function() {
                var vm = this;
                qz.printers.find().then(function(data) {
                    if (moqui.isArray(data)) {
                        var labelKeywords = ["label", "zebra", "sato", "dymo"];
                        vm.printerList = data;
                        for (var i = 0; i < data.length; i++) {
                            var printerName = data[i]; var pnLower = printerName.toLowerCase(); var hasLabelKw = false;
                            for (var j = 0; j < labelKeywords.length; j++) { if (pnLower.indexOf(labelKeywords[j]) !== -1) { hasLabelKw = true; } }
                            if (!hasLabelKw && !vm.currentPrinter) vm.currentPrinter = printerName;
                            if (hasLabelKw && !vm.currentLabelPrinter) vm.currentLabelPrinter = printerName;
                        }
                    }
                }).catch(moqui.showQzError);
            },
            setPrinter: function(printerName) {
                this.currentPrinter = printerName;
                $.ajax({ type:'POST', url:(this.$root.appRootPath + '/apps/setPreference'), error:moqui.handleAjaxError,
                    data:{ moquiSessionToken:this.$root.moquiSessionToken, preferenceKey:'qz.printer.main.active', preferenceValue:printerName } });
            },
            setLabelPrinter: function(printerName) {
                this.currentLabelPrinter = printerName;
                $.ajax({ type:'POST', url:(this.$root.appRootPath + '/apps/setPreference'), error:moqui.handleAjaxError,
                    data:{ moquiSessionToken:this.$root.moquiSessionToken, preferenceKey:'qz.printer.label.active', preferenceValue:printerName } });
            },
            handleConnectionError: function(err) {
                this.connectionState = "Error"; this.connectionClass = 'text-danger';
                if (err.target !== undefined) {
                    if (err.target.readyState >= 2) { //if CLOSING or CLOSED
                        moqui.notifyGrowl({type:"info", title:"Connection to QZ Tray was closed"});
                    } else {
                        moqui.notifyGrowl({type:"danger", title:"A QZ Tray connection error occurred, check log for details"});
                        console.error(err);
                    }
                } else {
                    moqui.notifyGrowl({type:"danger", title:err});
                }
            },
            startConnection: function () {
                if (!qz.websocket.isActive()) {
                    var vm = this;
                    this.connectionState = "Connecting..."; this.connectionClass = 'text-info';
                    // Retry 5 times, pausing 1 second between each attempt
                    qz.websocket.connect({ retries: 5, delay: 1 }).then(function() {
                        vm.connectionState = "Active"; vm.connectionClass = 'text-success';
                        qz.api.getVersion().then(function(data) { vm.qzVersion = data; }).catch(moqui.showQzError);
                    }).catch(this.handleConnectionError);
                }
            },
            endConnection: function () {
                if (qz.websocket.isActive()) {
                    var vm = this;
                    qz.websocket.disconnect().then(function() {
                        vm.connectionState = "Inactive"; vm.connectionClass = 'text-muted';
                        vm.qzVersion = null;
                    }).catch(this.handleConnectionError);
                }
            }
        },
        computed: {
            isReady: function () { return this.connectionState === 'Active' && (this.currentPrinter || this.currentLabelPrinter); },
            readyStyleBtn: function () { return this.connectionState === 'Active' ? (this.currentPrinter || this.currentLabelPrinter ? "btn-success" : "btn-warning") : "btn-danger"; }
        },
        mounted: function() {
            $('#qz-print-modal-link').tooltip({ placement:'bottom', trigger:'hover' });
            this.startConnection();
            // TODO: AJAX calls or something to get preferences: qz.printer.main.active, qz.printer.label.active
        }
    };
    moqui.isQzActive = function() { return qz.websocket.isActive(); };
    moqui.getQzMainConfig = function() {
        // TODO
    };
    moqui.getQzLabelConfig = function() {
        // TODO
    };
    moqui.showQzError = function(error) { moqui.notifyGrowl({type:"danger", title:error}); };
    moqui.printFile = function(config, urlOrData, type, format) {
        if (!type || !type.length) type = "pdf";
        if (!moqui.isQzActive()) {
            moqui.notifyGrowl({type:"warning", title:"Cannot print, QZ is not active"});
            console.warn("Tried to print type " + type + " at URL " + url + " but QZ is not active");
            return;
        }
        var config = moqui.getQzConfig();
        var printDataObj = { type:type, data:urlOrData };
        if (format) printDataObj.format = format;
        qz.print(config, [printDataObj]).catch(moqui.showQzError);
    };
    moqui.printMain = function(urlOrData, type, format) { moqui.printFile(moqui.getQzMainConfig(), urlOrData, type, format); };
    moqui.printLabel = function(urlOrData, type, format) { moqui.printFile(moqui.getQzLabelConfig(), urlOrData, type, format); };
} else {
    console.info("Not creating QZ component, qz: " + window.qz + ", moqui: " + window.moqui)
}
