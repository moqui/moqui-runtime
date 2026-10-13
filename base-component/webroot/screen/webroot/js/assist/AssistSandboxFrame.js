/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */
/*
 * Parent side of the sandbox for generated (vue-sfc) Assist screens. Registers the assist-sandbox-frame component.
 *
 * Model-written Vue runs in <iframe sandbox="allow-scripts"> with no allow-same-origin. That gives the frame an opaque
 * origin, so it cannot touch this page's DOM, cookies, session token or storage, and cannot navigate, open windows or
 * submit forms. A CSP in the frame document also removes its network (connect-src 'none') and allows images only as
 * data: URLs. The two font hosts below are allowed so Quasar's icons render, and nothing else leaves the frame.
 *
 * The one channel is a MessageChannel port transferred after load with a one-time nonce. Everything that crosses it is
 * validated here: message shape and size, path syntax, request rate. Reads go to /llm/v1/read, which runs the profile's
 * request tool as the user and refuses a path that would change data. The bridge cannot write. Writes happen through the
 * canvas actions, which the page renders as buttons outside the frame and runs from a user click.
 *
 * Message protocol (frame runtime: AssistSandboxRuntime.js):
 *   parent -> frame:  init {sfc, schema, mode, values}   values {values}   getResult {id, ok, status, json, text, error}
 *   frame -> parent:  ready   input {payload}   submit {payload}   cancel   resize {height}
 *                     error {phase, message}   get {id, path, query}
 * Plain ES5 on purpose, like the other Assist scripts.
 */
(function(root) {
    'use strict';
    var MAX_MESSAGE_CHARS = 262144;     // one message from the frame
    var MAX_INPUT_KEYS = 200;
    var MAX_QUERY_KEYS = 30;
    var MAX_QUERY_VALUE = 500;
    var MAX_PATH_CHARS = 500;
    var MAX_INFLIGHT = 6;
    var RATE_WINDOW_MS = 10000;
    var RATE_MAX = 60;                  // reads per window
    var MIN_HEIGHT = 40;
    var MAX_HEIGHT = 4000;
    // Quasar's icons and Roboto come from Google Fonts, as on the main page. Nothing else is allowed outside the app.
    var FONT_STYLE_HOST = 'https://fonts.googleapis.com';
    var FONT_FILE_HOST = 'https://fonts.gstatic.com';

    // Same-origin data paths only: /apps/... screens and /rest/... services. No host, scheme, dot-dot or odd characters.
    var PATH_OK = /^\/(apps|rest)\/[A-Za-z0-9_\-.\/~%:@+=,$]*$/;
    function validPath(path) {
        if (typeof path !== 'string' || path.length === 0 || path.length > MAX_PATH_CHARS) return false;
        if (!PATH_OK.test(path)) return false;
        if (path.indexOf('..') >= 0 || path.indexOf('//') >= 0) return false;
        var decoded;
        try { decoded = decodeURIComponent(path); } catch (e) { return false; }
        return decoded.indexOf('..') < 0 && decoded.indexOf('\\') < 0 && !/[\s\u0000-\u001f]/.test(decoded);
    }
    function cleanQuery(q) {
        var out = {}, n = 0;
        if (q == null) return out;
        if (typeof q !== 'object' || Array.isArray(q)) return null;
        for (var k in q) {
            if (!Object.prototype.hasOwnProperty.call(q, k)) continue;
            if (++n > MAX_QUERY_KEYS) return null;
            var v = q[k];
            if (v == null) continue;
            if (typeof v === 'object') return null;
            v = String(v);
            if (k.length > 100 || v.length > MAX_QUERY_VALUE) return null;
            out[k] = v;
        }
        return out;
    }
    function randomNonce() {
        var a = new Uint8Array(16);
        (root.crypto || root.msCrypto).getRandomValues(a);
        var s = '';
        for (var i = 0; i < a.length; i++) s += ('0' + a[i].toString(16)).slice(-2);
        return s;
    }
    function escAttr(s) { return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;'); }

    /** The frame document. origin is this page's origin, written out because 'self' does not match an opaque origin. */
    function frameDocument(origin, version, nonce) {
        var q = version ? ('?v=' + encodeURIComponent(version)) : '';
        var csp = "default-src 'none'; script-src " + origin + " 'unsafe-eval' 'nonce-" + nonce + "'; " +
            "style-src " + origin + " 'unsafe-inline' " + FONT_STYLE_HOST + "; font-src " + origin + " " + FONT_FILE_HOST + " data:; " +
            "img-src data:; connect-src 'none'; form-action 'none'; frame-src 'none'; base-uri 'none'";
        var closeScript = '<' + '/script>';
        return '<!doctype html><html><head><meta charset="utf-8">' +
            '<meta http-equiv="Content-Security-Policy" content="' + escAttr(csp) + '">' +
            '<link rel="stylesheet" href="' + origin + '/libs/quasar/quasar.min.css' + q + '">' +
            '<link rel="stylesheet" href="' + FONT_STYLE_HOST + '/css?family=Roboto:300,400,500,700|Material+Icons">' +
            '<style>html,body{margin:0;padding:0;background:transparent;font-family:Roboto,sans-serif}</style>' +
            '</head><body><div id="assist-sandbox-app"></div>' +
            '<script nonce="' + nonce + '">window.__ASSIST_SANDBOX = {nonce: "' + nonce + '"};' + closeScript +
            '<script src="' + origin + '/libs/vue/vue.min.js' + q + '">' + closeScript +
            '<script src="' + origin + '/libs/quasar/quasar.umd.min.js' + q + '">' + closeScript +
            '<script src="' + origin + '/js/http-vue-loader/httpVueLoader.js' + q + '">' + closeScript +
            '<script src="' + origin + '/js/assist/AssistSandboxRuntime.js' + q + '">' + closeScript +
            '</body></html>';
    }

    var Vue = root.Vue;
    if (!Vue) return;
    Vue.component('assist-sandbox-frame', {
        name: 'assistSandboxFrame',
        props: {
            sfc: { type: String, required: true },
            schema: { type: Object },
            values: { type: Object, 'default': function() { return {}; } },
            mode: { type: String, 'default': 'script' },
            // Base of the LLM servlet, e.g. "/llm/v1". Reads go to <readBase>/read.
            readBase: { type: String, required: true },
            profile: { type: String, required: true },
            appRoot: { type: String, 'default': '' },
            version: { type: String, 'default': '' }
        },
        data: function() {
            return { srcdoc: '', nonce: '', height: 120, ready: false, inflight: 0, stamps: [] };
        },
        template:
            '<iframe ref="frame" class="assist-sandbox-frame" sandbox="allow-scripts" referrerpolicy="no-referrer"' +
                ' title="Generated screen" :srcdoc="srcdoc" :style="{width:\'100%\', height:height + \'px\', border:\'0\', display:\'block\'}"' +
                ' @load="onLoad"></iframe>',
        created: function() {
            this.nonce = randomNonce();
            // Built once. A new srcdoc would reload the frame, so a new screen gets a new component (keyed by the caller).
            this.srcdoc = frameDocument(root.location.origin, this.version, this.nonce);
            this.channel = null;
            this.port = null;
        },
        beforeDestroy: function() { this.closePort(); },
        watch: {
            values: { deep: true, handler: function(v) { if (this.ready) this.post({ t: 'values', values: this.plain(v) }); } }
        },
        methods: {
            plain: function(v) { try { return JSON.parse(JSON.stringify(v == null ? {} : v)); } catch (e) { return {}; } },
            post: function(msg) { if (this.port) { try { this.port.postMessage(msg); } catch (e) { /* closed */ } } },
            closePort: function() {
                if (this.port) { try { this.port.onmessage = null; this.port.close(); } catch (e) { /* closed */ } }
                this.port = null;
                this.ready = false;
            },
            onLoad: function() {
                if (this.port) return;   // a reload of the frame document must not hand out a second port
                var frame = this.$refs.frame;
                if (!frame || !frame.contentWindow) return;
                var ch = new root.MessageChannel();
                this.channel = ch;
                this.port = ch.port1;
                var self = this;
                this.port.onmessage = function(e) { self.onFrameMessage(e.data); };
                // The target origin must be '*': an opaque origin has no name to target. The nonce, which only this frame's
                // document contains, is what the frame checks before it accepts the port.
                frame.contentWindow.postMessage({ t: 'port', nonce: this.nonce }, '*', [ch.port2]);
            },
            onFrameMessage: function(m) {
                if (!m || typeof m !== 'object' || typeof m.t !== 'string') return;
                var size;
                try { size = JSON.stringify(m).length; } catch (e) { return; }
                if (size > MAX_MESSAGE_CHARS) { this.$emit('error', { phase: 'runtime', message: 'The generated screen sent a message that was too large' }); return; }
                switch (m.t) {
                    case 'ready':
                        if (this.ready) return;
                        this.ready = true;
                        this.post({ t: 'init', sfc: this.sfc, schema: this.plain(this.schema), mode: this.mode, values: this.plain(this.values) });
                        return;
                    case 'input': this.onInput(m.payload); return;
                    case 'submit': this.$emit('submit', this.cleanPayload(m.payload)); return;
                    case 'cancel': this.$emit('cancel'); return;
                    case 'resize': {
                        var h = Number(m.height);
                        if (isFinite(h)) this.height = Math.max(MIN_HEIGHT, Math.min(MAX_HEIGHT, Math.ceil(h)));
                        return;
                    }
                    case 'error':
                        this.$emit('error', { phase: m.phase === 'compile' ? 'compile' : 'runtime',
                            message: String(m.message == null ? '' : m.message).slice(0, 2000) });
                        return;
                    case 'get': this.onGet(m); return;
                    default: return;   // unknown types are ignored
                }
            },
            // Input is a field change: {name, value} or an object of values. Keep scalars, arrays of scalars and plain
            // objects, bounded, and drop anything else.
            cleanPayload: function(p) {
                if (p == null || typeof p !== 'object' || Array.isArray(p)) return {};
                var out = {}, n = 0;
                for (var k in p) {
                    if (!Object.prototype.hasOwnProperty.call(p, k)) continue;
                    if (++n > MAX_INPUT_KEYS) break;
                    out[k] = p[k];
                }
                return out;
            },
            onInput: function(p) {
                var clean = this.cleanPayload(p);
                if (Object.keys(clean).length) this.$emit('input', clean);
            },
            refuse: function(id, status, message) {
                this.post({ t: 'getResult', id: id, ok: false, status: status, error: message });
            },
            onGet: function(m) {
                var id = typeof m.id === 'string' && m.id.length <= 40 ? m.id : null;
                if (id === null) return;
                if (!validPath(m.path)) { this.refuse(id, 400, 'That path is not allowed'); return; }
                var query = cleanQuery(m.query);
                if (query === null) { this.refuse(id, 400, 'The query is not allowed'); return; }
                var now = Date.now();
                this.stamps = this.stamps.filter(function(t) { return now - t < RATE_WINDOW_MS; });
                if (this.stamps.length >= RATE_MAX) { this.refuse(id, 429, 'Too many reads, slow down'); return; }
                if (this.inflight >= MAX_INFLIGHT) { this.refuse(id, 429, 'Too many reads at once'); return; }
                this.stamps.push(now);
                this.inflight++;
                var url = (this.appRoot || '') + this.readBase + '/read?profile=' + encodeURIComponent(this.profile) +
                    '&path=' + encodeURIComponent(m.path) + '&q=' + encodeURIComponent(JSON.stringify(query));
                var self = this;
                root.fetch(url, { method: 'GET', credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
                    .then(function(r) {
                        return r.text().then(function(text) {
                            var body = null;
                            try { body = JSON.parse(text); } catch (e) { /* not JSON */ }
                            if (!r.ok || !body) {
                                self.refuse(id, r.status, (body && body.error) || ('The read failed (' + r.status + ')'));
                            } else if (body.error && body.status >= 400) {
                                self.refuse(id, body.status, String(body.error));
                            } else {
                                self.post({ t: 'getResult', id: id, ok: true, status: body.status || r.status,
                                    json: body.json === undefined ? null : body.json,
                                    text: typeof body.text === 'string' ? body.text : null });
                            }
                        });
                    })
                    .catch(function(e) { self.refuse(id, 0, (e && e.message) || 'The read failed'); })
                    .then(function() { self.inflight = Math.max(0, self.inflight - 1); });
            }
        }
    });
})(window);
