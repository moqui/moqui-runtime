/* Assist OpenUI Lang renderer (Vue 2.7). Port of @openuidev/vue-lang state/Renderer against lang-core. */
(function(root) {
    'use strict';

    function unwrapFieldValue(v) {
        if (v && typeof v === 'object' && !Array.isArray(v) && Object.prototype.hasOwnProperty.call(v, 'value'))
            return v.value;
        return v;
    }
    function flattenRender(list) {
        var out = [];
        function walk(v) {
            if (v == null || v === false) return;
            if (Array.isArray(v)) { v.forEach(walk); return; }
            out.push(v);
        }
        walk(list);
        return out;
    }
    function validateActionPath(path) {
        if (root.AssistOpenUiNav && typeof root.AssistOpenUiNav.validatePath === 'function')
            return root.AssistOpenUiNav.validatePath(path);
        if (!path || path.charAt(0) !== '/') return 'path must start with /';
        if (path.indexOf('://') >= 0 || path.indexOf('//') === 0) return 'path must not contain a host';
        if (path.indexOf('..') >= 0) return 'path must not contain ..';
        var lower = String(path).toLowerCase();
        if (lower.indexOf('javascript:') >= 0 || lower.indexOf('data:') >= 0)
            return 'path scheme not allowed';
        return null;
    }
    function isHtmlBody(text, contentType) {
        if (contentType && String(contentType).toLowerCase().indexOf('html') >= 0) return true;
        if (text == null) return false;
        var t = String(text).trim();
        if (!t) return false;
        var head = t.length > 32 ? t.slice(0, 32).toLowerCase() : t.toLowerCase();
        return head.indexOf('<!doctype') === 0 || head.indexOf('<html') === 0
            || head.indexOf('<body') === 0 || head.indexOf('<head') === 0;
    }

    var AST_KINDS = { Comp: 1, Ref: 1, StateRef: 1, RuntimeRef: 1, BinOp: 1, UnaryOp: 1, Ternary: 1,
        Member: 1, Index: 1, Assign: 1, Str: 1, Num: 1, Bool: 1, Null: 1, Arr: 1, Obj: 1, Ph: 1 };
    /** Components whose first positional argument is an array of children or columns. */
    var ARRAY_FIRST = { Stack: 1, Card: 1, Accordion: 1, Steps: 1, ListBlock: 1, Buttons: 1, Tabs: 1, Table: 1 };
    /** Of those, the ones that take no further arguments. Extra args are dropped by the parser and hide the list. */
    var ARRAY_ONLY = { Card: 1, Accordion: 1, Steps: 1, ListBlock: 1, Buttons: 1, Tabs: 1, Table: 1 };

    function isOpenUiAst(v) {
        return !!(v && typeof v === 'object' && !Array.isArray(v) && AST_KINDS[v.k]);
    }
    function readStringToken(src, i) {
        var j = i + 1, inner = '';
        while (j < src.length) {
            var c = src.charAt(j);
            if (c === '\\') {
                inner += c;
                if (j + 1 < src.length) { inner += src.charAt(j + 1); j += 2; continue; }
                j++;
                continue;
            }
            if (c === '"') return { text: src.slice(i, j + 1), inner: inner, end: j + 1 };
            inner += c;
            j++;
        }
        return { text: src.slice(i), inner: inner, end: src.length };
    }
    function readCall(src, parenAt) {
        var depth = 0, j = parenAt;
        while (j < src.length) {
            var c = src.charAt(j);
            if (c === '"') { j = readStringToken(src, j).end; continue; }
            if (c === '(' || c === '[' || c === '{') depth++;
            else if (c === ')' || c === ']' || c === '}') {
                depth--;
                if (depth === 0 && c === ')') return { inner: src.slice(parenAt + 1, j), end: j + 1 };
            }
            j++;
        }
        return null;
    }
    function splitArgs(inner) {
        var args = [], depth = 0, start = 0, i = 0;
        while (i < inner.length) {
            var c = inner.charAt(i);
            if (c === '"') { i = readStringToken(inner, i).end; continue; }
            if (c === '(' || c === '[' || c === '{') depth++;
            else if (c === ')' || c === ']' || c === '}') depth--;
            else if (c === ',' && depth === 0) {
                args.push(inner.slice(start, i).trim());
                start = i + 1;
            }
            i++;
        }
        var last = inner.slice(start).trim();
        if (last || args.length) args.push(last);
        return args;
    }
    function structuresBalanced(src) {
        var depth = 0, i = 0;
        while (i < src.length) {
            var c = src.charAt(i);
            if (c === '"') { i = readStringToken(src, i).end; continue; }
            if (c === '(' || c === '[' || c === '{') depth++;
            else if (c === ')' || c === ']' || c === '}') {
                depth--;
                if (depth < 0) return false;
            }
            i++;
        }
        return depth === 0;
    }
    function isIdentStart(c) {
        return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c === '_';
    }
    function readIdent(src, i) {
        var j = i + 1;
        while (j < src.length) {
            var c = src.charAt(j);
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c === '_') j++;
            else break;
        }
        return { name: src.slice(i, j), end: j };
    }
    function isComponentCall(text) {
        return /^[A-Z][A-Za-z0-9_]*\s*\(/.test(text);
    }
    function isExprString(inner) {
        var t = inner.trim();
        if (t.charAt(0) !== '@' || t.charAt(t.length - 1) !== ')') return false;
        if (t.indexOf('\n') >= 0) return false;
        return structuresBalanced(t);
    }
    function unquoteExprStrings(src) {
        var i = 0, out = '';
        while (i < src.length) {
            if (src.charAt(i) === '"') {
                var s = readStringToken(src, i);
                if (isExprString(s.inner)) out += s.inner.replace(/'([^'\\]*)'/g, '"$1"');
                else out += s.text;
                i = s.end;
                continue;
            }
            out += src.charAt(i);
            i++;
        }
        return out;
    }
    function rewriteIf(inner) {
        var rewritten = rewriteCalls(inner);
        var args = splitArgs(rewritten);
        if (args.length !== 3) return '@If(' + rewritten + ')';
        return '(' + args[0] + ' ? ' + args[1] + ' : ' + args[2] + ')';
    }
    function rewriteMap(inner) {
        var rewritten = rewriteCalls(inner);
        var args = splitArgs(rewritten);
        if (args.length !== 3) return '@Map(' + rewritten + ')';
        var nameTok = args[1];
        var varName = null;
        if (nameTok.charAt(0) === '"' && nameTok.charAt(nameTok.length - 1) === '"')
            varName = nameTok.slice(1, -1);
        if (!varName || !/^[A-Za-z_][A-Za-z0-9_]*$/.test(varName)) return '@Map(' + rewritten + ')';
        var expr = args[2];
        if (expr !== varName && expr.indexOf(varName + '.') !== 0) return '@Map(' + rewritten + ')';
        return args[0] + expr.slice(varName.length);
    }
    function wrapArrayFirst(inner) {
        var args = splitArgs(inner);
        if (!args.length) return inner;
        var first = args[0];
        if (!first || first.charAt(0) === '[') return inner;
        if (!isComponentCall(first)) return inner;
        if (args.length > 1 && isComponentCall(args[1])) return inner;
        args[0] = '[' + first + ']';
        return args.join(', ');
    }
    function rewriteCalls(src) {
        var i = 0, out = '';
        while (i < src.length) {
            var c = src.charAt(i);
            if (c === '"') {
                var s = readStringToken(src, i);
                out += s.text;
                i = s.end;
                continue;
            }
            if (c === '@' && src.substr(i, 4) === '@If(') {
                var iff = readCall(src, i + 3);
                if (!iff) { out += c; i++; continue; }
                out += rewriteIf(iff.inner);
                i = iff.end;
                continue;
            }
            if (c === '@' && src.substr(i, 5) === '@Map(') {
                var mapc = readCall(src, i + 4);
                if (!mapc) { out += c; i++; continue; }
                out += rewriteMap(mapc.inner);
                i = mapc.end;
                continue;
            }
            if (isIdentStart(c)) {
                var id = readIdent(src, i);
                var k = id.end;
                while (src.charAt(k) === ' ' || src.charAt(k) === '\t') k++;
                if (ARRAY_FIRST[id.name] && src.charAt(k) === '(') {
                    var call = readCall(src, k);
                    if (!call) { out += c; i++; continue; }
                    var inner = rewriteCalls(call.inner);
                    var wrapped = wrapArrayFirst(inner);
                    if (ARRAY_ONLY[id.name]) {
                        var only = splitArgs(wrapped);
                        if (only.length > 1 && only[0].charAt(0) === '[') wrapped = only[0];
                    }
                    out += src.slice(i, k) + '(' + wrapped + ')';
                    i = call.end;
                    continue;
                }
            }
            out += c;
            i++;
        }
        return out;
    }
    function isSimpleLiteral(rhs) {
        var t = rhs.trim();
        if (t === 'true' || t === 'false' || t === 'null') return true;
        if (/^-?\d+(\.\d+)?$/.test(t)) return true;
        if (t.charAt(0) === '"') {
            var s = readStringToken(t, 0);
            return s.end === t.length;
        }
        return false;
    }
    function replaceDollarsOutsideStrings(line, names) {
        var i = 0, out = '';
        while (i < line.length) {
            if (line.charAt(i) === '"') {
                var s = readStringToken(line, i);
                out += s.text;
                i = s.end;
                continue;
            }
            if (line.charAt(i) === '$') {
                var id = readIdent(line, i + 1);
                var key = '$' + id.name;
                if (id.name && names[key]) {
                    out += id.name;
                    i = id.end;
                    continue;
                }
            }
            out += line.charAt(i);
            i++;
        }
        return out;
    }
    function rewriteDollarComputes(src) {
        var lines = src.split('\n');
        var names = Object.create(null);
        var decl = /^(\s*)(\$[A-Za-z_][A-Za-z0-9_]*)(\s*=\s*)([\s\S]+)$/;
        lines.forEach(function(line) {
            var m = line.match(decl);
            if (!m || isSimpleLiteral(m[4])) return;
            names[m[2]] = true;
        });
        if (!Object.keys(names).length) return src;
        return lines.map(function(line) {
            var m = line.match(decl);
            if (m && names[m[2]]) line = m[1] + m[2].slice(1) + m[3] + m[4];
            return replaceDollarsOutsideStrings(line, names);
        }).join('\n');
    }
    function identBoundary(src, i) {
        if (i <= 0) return true;
        return !/[A-Za-z0-9_@]/.test(src.charAt(i - 1));
    }
    /** Expression immediately before `.toFixed(`. -1 if it is not a call receiver. */
    function toFixedReceiverStart(src, dot) {
        var j = dot - 1;
        while (j >= 0 && (src.charAt(j) === ' ' || src.charAt(j) === '\t' || src.charAt(j) === '\n')) j--;
        if (j < 0) return -1;
        if (src.charAt(j) === ')') {
            var depth = 1;
            j--;
            while (j >= 0 && depth > 0) {
                var c = src.charAt(j);
                if (c === '"') return -1;
                if (c === ')' || c === ']' || c === '}') depth++;
                else if (c === '(' || c === '[' || c === '{') depth--;
                j--;
            }
            if (depth !== 0) return -1;
            while (j >= 0 && (src.charAt(j) === ' ' || src.charAt(j) === '\t')) j--;
            while (j >= 0 && /[A-Za-z0-9_@]/.test(src.charAt(j))) j--;
            return j + 1;
        }
        if (!/[A-Za-z0-9_.]/.test(src.charAt(j))) return -1;
        while (j >= 0 && /[A-Za-z0-9_$.]/.test(src.charAt(j))) j--;
        return j + 1;
    }
    /**
     * OpenUI has no JavaScript Number() or method calls. Number(x).toFixed(n) parses as an
     * unknown component, so a money cell renders as "$".
     */
    function rewriteJsNumbers(src) {
        var i = 0, out = '';
        while (i < src.length) {
            if (src.charAt(i) === '"') {
                var s = readStringToken(src, i);
                out += s.text;
                i = s.end;
                continue;
            }
            if (src.substr(i, 9) === '.toFixed(') {
                var call = readCall(src, i + 8);
                var start = call ? toFixedReceiverStart(src, i) : -1;
                if (call && start >= 0 && start < i) {
                    var recv = src.slice(start, i).trim();
                    var decimals = call.inner.trim() || '0';
                    out = out.slice(0, out.length - (i - start)) + '@Round(' + recv + ', ' + decimals + ')';
                    i = call.end;
                    continue;
                }
            }
            out += src.charAt(i);
            i++;
        }
        var src2 = out;
        i = 0;
        out = '';
        while (i < src2.length) {
            if (src2.charAt(i) === '"') {
                var str = readStringToken(src2, i);
                out += str.text;
                i = str.end;
                continue;
            }
            if (src2.substr(i, 7) === 'Number(' && identBoundary(src2, i)) {
                var num = readCall(src2, i + 6);
                if (num && splitArgs(num.inner).length === 1) {
                    out += '(' + splitArgs(num.inner)[0] + ')';
                    i = num.end;
                    continue;
                }
            }
            out += src2.charAt(i);
            i++;
        }
        return out;
    }
    /**
     * Models often emit `$orders = Query(...)` and `$placed = @Count(...)`. `$` is mutable
     * state: the initializer is stored raw, so the canvas prints the expression tree.
     * Lift non-literal `$` declarations to ordinary names, and repair @If / @Map / a single
     * component passed where an array is required.
     */
    function rewriteOpenUiLang(src) {
        if (!src) return src || '';
        try {
            var text = rewriteJsNumbers(unquoteExprStrings(String(src)));
            if (structuresBalanced(text)) text = rewriteCalls(text);
            return rewriteLoopPluck(rewriteDollarComputes(text));
        } catch (e) {
            return String(src);
        }
    }
    function argSpans(inner) {
        var spans = [], depth = 0, start = 0, i = 0;
        function push(from, to) {
            var raw = inner.slice(from, to);
            var lead = (raw.match(/^\s*/) || [''])[0].length;
            var trail = (raw.match(/\s*$/) || [''])[0].length;
            var a = from + lead, b = to - trail;
            if (b < a) b = a;
            spans.push({ start: a, end: b });
        }
        while (i < inner.length) {
            var c = inner.charAt(i);
            if (c === '"') { i = readStringToken(inner, i).end; continue; }
            if (c === '(' || c === '[' || c === '{') depth++;
            else if (c === ')' || c === ']' || c === '}') depth--;
            else if (c === ',' && depth === 0) {
                push(start, i);
                start = i + 1;
            }
            i++;
        }
        push(start, inner.length);
        return spans;
    }
    /**
     * `Col("Customer", r.customerPartyId)` is empty: r exists only inside @Each.
     * When every @Each uses the same array for that name, rewrite the bare member to array.field.
     */
    function rewriteLoopPluck(src) {
        var byVar = Object.create(null);
        var i = 0;
        while (i < src.length) {
            if (src.charAt(i) === '"') { i = readStringToken(src, i).end; continue; }
            if (src.substr(i, 6) === '@Each(') {
                var call = readCall(src, i + 5);
                if (call) {
                    var spans = argSpans(call.inner);
                    if (spans.length >= 3) {
                        var varTok = call.inner.slice(spans[1].start, spans[1].end);
                        var varName = null;
                        if (varTok.charAt(0) === '"' && varTok.charAt(varTok.length - 1) === '"')
                            varName = varTok.slice(1, -1);
                        if (varName && /^[A-Za-z_][A-Za-z0-9_]*$/.test(varName)) {
                            var abs = i + 6;
                            if (!byVar[varName]) byVar[varName] = [];
                            byVar[varName].push({
                                array: call.inner.slice(spans[0].start, spans[0].end),
                                tStart: abs + spans[2].start,
                                tEnd: abs + spans[2].end
                            });
                        }
                    }
                }
                i += 6;
                continue;
            }
            i++;
        }
        var usable = Object.create(null);
        Object.keys(byVar).forEach(function(name) {
            var list = byVar[name];
            var array = list[0].array;
            if (!list.every(function(e) { return e.array === array; })) return;
            usable[name] = { array: array, ranges: list.map(function(e) { return [e.tStart, e.tEnd]; }) };
        });
        if (!Object.keys(usable).length) return src;
        var out = '';
        i = 0;
        while (i < src.length) {
            if (src.charAt(i) === '"') {
                var s = readStringToken(src, i);
                out += s.text;
                i = s.end;
                continue;
            }
            if (isIdentStart(src.charAt(i))) {
                var id = readIdent(src, i);
                var info = usable[id.name];
                var prev = i > 0 ? src.charAt(i - 1) : '';
                var boundary = !prev || !/[A-Za-z0-9_$.]/.test(prev);
                var j = id.end;
                while (src.charAt(j) === ' ' || src.charAt(j) === '\t') j++;
                var inside = false;
                if (info) {
                    for (var r = 0; r < info.ranges.length; r++) {
                        if (i >= info.ranges[r][0] && i < info.ranges[r][1]) { inside = true; break; }
                    }
                }
                if (info && boundary && !inside && src.charAt(j) === '.') {
                    out += info.array;
                    i = id.end;
                    continue;
                }
                out += src.slice(i, id.end);
                i = id.end;
                continue;
            }
            out += src.charAt(i);
            i++;
        }
        return out;
    }
    root.rewriteOpenUiLang = rewriteOpenUiLang;
    root.isOpenUiAst = isOpenUiAst;

    if (typeof Vue === 'undefined') return;

    Vue.component('assist-openui-node', {
        name: 'assist-openui-node',
        props: ['node'],
        inject: ['openui'],
        render: function(h) {
            var node = this.node, ctx = this.openui;
            if (!node) return h('span');
            if (typeof node === 'string' || typeof node === 'number' || typeof node === 'boolean')
                return h('span', String(node));
            if (node.type !== 'element') return h('span');
            var def = ctx && ctx.library && ctx.library.components[node.typeName];
            if (!def || !def.component) {
                return h('div', { class: 'text-grey-7 text-caption' }, 'Unknown component: ' + node.typeName);
            }
            function renderNode(value) {
                if (value == null) return null;
                if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean')
                    return String(value);
                if (Array.isArray(value)) {
                    return flattenRender(value.map(function(item) { return renderNode(item); }));
                }
                if (typeof value === 'object' && value.type === 'element') {
                    return h('assist-openui-node', { key: value.statementId || undefined, props: { node: value } });
                }
                return null;
            }
            return h(def.component, {
                props: { props: node.props || {}, renderNode: renderNode, statementId: node.statementId }
            });
        }
    });

    Vue.component('assist-openui', {
        name: 'assist-openui',
        props: {
            lang: { type: String, default: '' },
            streaming: { type: Boolean, default: false },
            mode: { type: String, default: 'script' },
            csrf: { type: String, default: '' },
            appRoot: { type: String, default: '' },
            initialState: { type: Object, default: function() { return {}; } }
        },
        data: function() {
            return {
                evaluatedRoot: null,
                isQueryLoading: false,
                parseErrors: [],
                storeTick: 0,
                storeSnapshot: {},
                ready: false,
                loadError: null
            };
        },
        provide: function() {
            return { openui: this };
        },
        computed: {
            isStreaming: function() { return !!this.streaming; },
            library: function() { return root.AssistOpenUiLibrary; }
        },
        created: function() {
            this._lastStoreInitKey = '';
            this._lastErrorKey = '';
            var self = this;
            var boot = function() {
                var OpenUI = root.OpenUILang;
                if (!OpenUI) { self.loadError = 'OpenUI lang-core is not loaded'; return; }
                var spec = root.AssistOpenUiSpec;
                if (!spec) { self.loadError = 'OpenUI library spec is not loaded'; return; }
                self._OpenUI = OpenUI;
                self._parser = OpenUI.createStreamingParser(spec, 'Stack');
                self._store = OpenUI.createStore();
                self._qm = OpenUI.createQueryManager(self.makeToolProvider());
                self._qm.activate();
                self._unsubStore = self._store.subscribe(function() {
                    self.storeSnapshot = self._store.getSnapshot();
                    self.storeTick++;
                    self.$emit('state-update', self.storeSnapshot);
                    if (!self.streaming) self.reeval();
                });
                self._unsubQm = self._qm.subscribe(function() {
                    self.isQueryLoading = self._qm.isAnyLoading();
                    if (!self.streaming) self.reeval();
                });
                self.ready = true;
                self.reparse();
            };
            if (root.AssistOpenUiSpec) boot();
            else if (typeof root.loadAssistOpenUiSpec === 'function') {
                root.loadAssistOpenUiSpec(function(err) {
                    if (err) self.loadError = (err && err.message) || String(err);
                    else boot();
                });
            } else boot();
        },
        beforeDestroy: function() {
            if (this._unsubStore) this._unsubStore();
            if (this._unsubQm) this._unsubQm();
            if (this._qm) this._qm.dispose();
            if (this._store) this._store.dispose();
        },
        watch: {
            lang: function() { this.reparse(); },
            streaming: function(v) { if (!v) this.reparse(); }
        },
        methods: {
            getState: function(name) {
                if (!this._store) return undefined;
                return unwrapFieldValue(this._store.get(name));
            },
            setState: function(name, value) {
                if (!this._store) return;
                this._store.set(name, value);
            },
            getFieldValue: function(formName, name) {
                if (!this._store) return undefined;
                if (!formName) return unwrapFieldValue(this._store.get(name));
                var formData = this._store.get(formName);
                if (!formData || typeof formData !== 'object' || Array.isArray(formData)) return undefined;
                return unwrapFieldValue(formData[name]);
            },
            setFieldValue: function(formName, componentType, name, value, shouldSave) {
                if (!this._store) return;
                var wrapped = { value: value, componentType: componentType };
                if (!formName) this._store.set(name, wrapped);
                else {
                    var raw = this._store.get(formName);
                    var formData = raw && typeof raw === 'object' && !Array.isArray(raw) ? Object.assign({}, raw) : {};
                    formData[name] = wrapped;
                    this._store.set(formName, formData);
                }
                if (shouldSave !== false) this.$emit('state-update', this._store.getSnapshot());
            },
            valuesMap: function() {
                var snap = this._store ? this._store.getSnapshot() : {};
                var out = {};
                Object.keys(snap).forEach(function(k) {
                    var v = unwrapFieldValue(snap[k]);
                    if (k.charAt(0) === '$') out[k.slice(1)] = v;
                    else if (v && typeof v === 'object' && !Array.isArray(v)) {
                        Object.keys(v).forEach(function(fk) { out[fk] = unwrapFieldValue(v[fk]); });
                    } else out[k] = v;
                });
                return out;
            },
            makeToolProvider: function() {
                var vm = this;
                return {
                    callTool: function(toolName, args) {
                        args = args || {};
                        if (toolName === 'request') return vm.callRequest(args);
                        return Promise.reject(new Error('Unknown OpenUI tool: ' + toolName));
                    }
                };
            },
            callRequest: function(args) {
                var method = String(args.method || 'GET').toUpperCase();
                var path = args.path;
                var pathErr = validateActionPath(path);
                if (pathErr) return Promise.reject(new Error(pathErr));
                if (path.indexOf('/qapps') === 0)
                    return Promise.reject(new Error('Use /apps (not /qapps) for JSON'));
                if (method !== 'GET' && method !== 'HEAD' && this.mode === 'agent')
                    return Promise.reject(new Error('Agent mode does not POST from the canvas'));
                var url = (this.appRoot || '') + path;
                var init = { method: method, credentials: 'same-origin',
                    headers: { 'Accept': 'application/json', 'X-CSRF-Token': this.csrf } };
                if (method === 'GET' || method === 'HEAD') {
                    var q = args.query || args.body || {};
                    var parts = [];
                    Object.keys(q).forEach(function(k) {
                        if (q[k] != null && q[k] !== '') parts.push(encodeURIComponent(k) + '=' + encodeURIComponent(q[k]));
                    });
                    if (parts.length) url += (url.indexOf('?') >= 0 ? '&' : '?') + parts.join('&');
                } else {
                    init.headers['Content-Type'] = 'application/json';
                    init.body = JSON.stringify(args.body || args.query || {});
                }
                return fetch(url, init).then(function(r) {
                    return r.text().then(function(txt) {
                        var ct = r.headers && r.headers.get ? r.headers.get('Content-Type') : null;
                        if (isHtmlBody(txt, ct))
                            throw new Error('HTML screens are not valid tool results. Use /apps (not /qapps).');
                        var parsed = txt;
                        try { parsed = JSON.parse(txt); } catch (e) { /* keep */ }
                        if (r.status >= 400) {
                            var err = new Error('request failed: ' + r.status);
                            err.body = parsed;
                            throw err;
                        }
                        if (Array.isArray(parsed) && path.indexOf('/actions/') >= 0) {
                            parsed = parsed.filter(function(row) {
                                return !(row && row._moquiRowType === 'total');
                            });
                            var total = r.headers && r.headers.get ? r.headers.get('X-Total-Count') : null;
                            parsed = { rows: parsed,
                                totalCount: total != null && total !== '' ? Number(total) : parsed.length };
                        }
                        return parsed;
                    });
                });
            },
            evaluationContext: function() {
                var store = this._store, qm = this._qm, OpenUI = this._OpenUI;
                var evaluating = Object.create(null);
                var ctx = {
                    getState: function(name) {
                        if (evaluating[name]) return null;
                        var value = store ? unwrapFieldValue(store.get(name)) : undefined;
                        // `$placed = @Count(...)` is stored as the AST. Evaluate it, and let a
                        // null `$orders` state slot fall through to the Query registered under that name.
                        if (isOpenUiAst(value) && OpenUI) {
                            evaluating[name] = true;
                            try { return OpenUI.evaluate(value, ctx); }
                            catch (e) { return null; }
                            finally { delete evaluating[name]; }
                        }
                        if (value == null && qm) {
                            var mut = qm.getMutationResult(name);
                            if (mut) return mut;
                            var qr = qm.getResult(name);
                            if (qr != null) return qr;
                        }
                        return value;
                    },
                    resolveRef: function(name) {
                        if (!qm) return null;
                        var mut = qm.getMutationResult(name);
                        if (mut) return mut;
                        return qm.getResult(name);
                    }
                };
                return ctx;
            },
            reparse: function() {
                if (!this.ready || !this._parser) return;
                var OpenUI = this._OpenUI;
                var text = rewriteOpenUiLang(this.lang || '');
                var parseResult = null;
                try { parseResult = this._parser.set(text); }
                catch (e) {
                    this.parseErrors = [{ source: 'parser', code: 'parse-exception', message: (e && e.message) || String(e) }];
                    this.evaluatedRoot = null;
                    this.$emit('error', this.parseErrors);
                    return;
                }
                this._parseResult = parseResult;
                var decls = (parseResult && parseResult.stateDeclarations) || {};
                var initial = this.initialState || {};
                var key = JSON.stringify(decls) + '::' + JSON.stringify(initial);
                if (key !== this._lastStoreInitKey) {
                    this._lastStoreInitKey = key;
                    var persisted = {};
                    Object.keys(initial).forEach(function(k) {
                        if (k.charAt(0) === '$') persisted[k] = initial[k];
                        else persisted['$' + k] = initial[k];
                    });
                    this._store.initialize(decls, persisted);
                }
                this.reeval();
            },
            reeval: function() {
                if (!this.ready || !this._parseResult) return;
                var OpenUI = this._OpenUI;
                var res = this._parseResult;
                var errors = (res.meta && res.meta.errors) ? res.meta.errors.slice() : [];
                if (!this.streaming && this._qm) {
                    var evalCtx = this.evaluationContext();
                    var qStmts = res.queryStatements || [];
                    var evaluatedNodes = qStmts.map(function(qn) {
                        return {
                            statementId: qn.statementId,
                            toolName: qn.toolAST ? OpenUI.evaluate(qn.toolAST, evalCtx) : '',
                            args: qn.argsAST ? OpenUI.evaluate(qn.argsAST, evalCtx) : null,
                            defaults: qn.defaultsAST ? OpenUI.evaluate(qn.defaultsAST, evalCtx) : null,
                            refreshInterval: qn.refreshAST ? OpenUI.evaluate(qn.refreshAST, evalCtx) : undefined,
                            deps: qn.deps,
                            complete: qn.complete
                        };
                    });
                    this._qm.evaluateQueries(evaluatedNodes);
                    var mutStmts = res.mutationStatements || [];
                    this._qm.registerMutations(mutStmts.map(function(mn) {
                        return {
                            statementId: mn.statementId,
                            toolName: mn.toolAST ? OpenUI.evaluate(mn.toolAST, evalCtx) : ''
                        };
                    }));
                }
                if (!res.root) {
                    this.evaluatedRoot = null;
                    this.parseErrors = errors;
                    this.$emit('error', errors);
                    return;
                }
                var runtimeErrors = [];
                var evaluated = res.root;
                try {
                    evaluated = OpenUI.evaluateElementProps(res.root, {
                        ctx: this.evaluationContext(),
                        library: this.library,
                        store: this._store,
                        errors: runtimeErrors
                    });
                } catch (e) {
                    runtimeErrors.push({ source: 'runtime', code: 'runtime-error', message: (e && e.message) || String(e) });
                }
                this.evaluatedRoot = evaluated;
                var all = errors.concat(runtimeErrors);
                this.parseErrors = all;
                var ek = JSON.stringify(all);
                if (ek !== this._lastErrorKey) {
                    this._lastErrorKey = ek;
                    this.$emit('error', all);
                }
            },
            navGetLinkPath: function() {
                var r = this.$root;
                if (r && typeof r.getLinkPath === 'function') return r.getLinkPath.bind(r);
                return null;
            },
            triggerAction: function(userMessage, formName, action) {
                var OpenUI = this._OpenUI;
                var self = this;
                var formPayload = this.valuesMap();
                if (action && !action.steps) {
                    this.$emit('action', {
                        type: (action.type) || (OpenUI && OpenUI.BuiltinActionType.ContinueConversation) || 'continue_conversation',
                        params: action.params || {},
                        humanFriendlyMessage: userMessage,
                        formState: formPayload,
                        formName: formName
                    });
                    return;
                }
                var plan = action;
                if (plan && plan.steps && plan.steps.length) {
                    var i = 0;
                    function next() {
                        if (i >= plan.steps.length) return;
                        var step = plan.steps[i++];
                        if (step.type === 'run') {
                            if (step.refType === 'mutation') {
                                if (self.mode === 'agent') {
                                    self.$emit('action', {
                                        type: 'submit',
                                        params: {},
                                        humanFriendlyMessage: userMessage || 'Submit',
                                        formState: formPayload,
                                        formName: formName
                                    });
                                    return;
                                }
                                var mn = (self._parseResult && self._parseResult.mutationStatements || []).filter(function(m) {
                                    return m.statementId === step.statementId;
                                })[0];
                                var evaluatedArgs = {};
                                if (mn && mn.argsAST) evaluatedArgs = OpenUI.evaluate(mn.argsAST, self.evaluationContext()) || {};
                                self._qm.fireMutation(step.statementId, evaluatedArgs).then(function(ok) {
                                    if (ok) next();
                                });
                            } else {
                                if (self._qm) self._qm.invalidate([step.statementId]);
                                next();
                            }
                        } else if (step.type === 'continue_conversation') {
                            self.$emit('action', {
                                type: 'continue_conversation',
                                params: step.context ? { context: step.context } : {},
                                humanFriendlyMessage: step.message || userMessage,
                                formState: formPayload,
                                formName: formName
                            });
                        } else if (step.type === 'open_url') {
                            self.$emit('action', {
                                type: 'open_url',
                                params: { url: step.url },
                                humanFriendlyMessage: '',
                                formState: formPayload,
                                formName: formName
                            });
                        } else if (step.type === 'set') {
                            if (step.valueAST) {
                                var value = OpenUI.evaluate(step.valueAST, self.evaluationContext());
                                self._store.set(step.target, value);
                            }
                            next();
                        } else if (step.type === 'reset') {
                            var decls = (self._parseResult && self._parseResult.stateDeclarations) || {};
                            (step.targets || []).forEach(function(t) {
                                self._store.set(t, decls[t] != null ? decls[t] : null);
                            });
                            next();
                        } else next();
                    }
                    next();
                    return;
                }
                // No resolvable @Run (the model often @Run's the form name). Submit the form values.
                this.$emit('action', {
                    type: 'submit',
                    params: {},
                    humanFriendlyMessage: userMessage || 'Submit',
                    formState: formPayload,
                    formName: formName
                });
            }
        },
        template:
            '<div class="assist-openui">' +
                '<div v-if="loadError" class="text-negative q-pa-sm">{{ loadError }}</div>' +
                '<div v-else-if="!ready" class="text-grey-7 q-pa-sm">Loading OpenUI…</div>' +
                '<div v-else-if="isQueryLoading" class="text-caption text-grey-7 q-mb-sm">Loading data…</div>' +
                '<assist-openui-node v-if="evaluatedRoot" :node="evaluatedRoot"></assist-openui-node>' +
                '<div v-else-if="lang && !streaming" class="text-grey-7 q-pa-sm">Nothing to render yet.</div>' +
            '</div>'
    });

    root.AssistOpenUiReady = true;
})(typeof window !== 'undefined' ? window : this);
