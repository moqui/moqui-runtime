Generated screens (write_ui kind=vue-sfc) run in a sandboxed frame
===================================================================

Why
  A generated screen is code the model wrote, possibly steered by text in data it read. It must not be able to use the
  user's session. So it never runs in the Assist page. It runs in an iframe with an opaque origin that has no way out
  except one narrow message channel.

Pieces
  AssistSandboxFrame.js    Parent side. Registers the assist-sandbox-frame component that Assist.qvue uses. Builds the
                           frame document, owns the channel, validates every message, performs reads.
  AssistSandboxRuntime.js  Runs inside the frame. Compiles the generated component, provides this.$bridge and the six
                           m-* widget shims, reports size and errors.
  /llm/v1/read             Server endpoint behind $bridge.get. GET only. Runs the profile's request tool as the user and
                           refuses a path that resolves to a screen transition that changes data
                           (RequestTool.mutates), because Moqui runs a transition on GET.

What confines the code
  1. <iframe sandbox="allow-scripts"> with no allow-same-origin: opaque origin, so no access to the page DOM, cookies,
     localStorage or the session token; no top navigation, popups, forms or downloads.
  2. A CSP in the frame document: default-src 'none'; connect-src 'none' (no fetch/XHR/WebSocket/beacon); img-src data:
     only; form-action 'none'; script-src is this app's origin (written out, since 'self' does not match an opaque
     origin) plus 'unsafe-eval' (Vue's template compiler and httpVueLoader need it, and the frame is the place for it)
     and a per-frame nonce. Styles may be inline. Only fonts.googleapis.com and fonts.gstatic.com are allowed outside the
     app, so Roboto and Material Icons render, as on the main page.
  3. The channel. Nothing else leaves the frame.

Channel
  After the frame loads, the parent creates a MessageChannel and posts {t:'port', nonce} to the frame with port2
  transferred. The target origin has to be '*' because an opaque origin has no name. The nonce exists only in that frame's
  own document, and the frame accepts the port once, from window.parent only. Later messages use the port.

  parent -> frame
    init       {sfc, schema, mode, values}   compile and mount (one canvas per frame)
    values     {values}                      the page's field values changed
    getResult  {id, ok, status, json, text, error}
  frame -> parent
    ready                                    port accepted
    input      {payload}                     {name, value} or an object of values. Becomes the page's @input
    submit     {payload}   cancel            the page decides what these do, and the page owns the action buttons
    resize     {height}                      clamped to 40..4000
    error      {phase: compile|runtime, message}
    get        {id, path, query}             a read

  The parent drops a message that is not an object with a string type, is over 256 KB, or has an unknown type. A read must
  be a /apps/... or /rest/... path of safe characters (no host, scheme, '..' or '//'), with a flat query of at most 30
  short strings. Reads are limited to 6 at once and 60 per 10 seconds, and a result to about 1.5 MB.

What generated code can do
  Render, collect values, and read data through this.$bridge.get(path, query).then(function(r) {...}) where r is
  {status, json, text}. It cannot write: writes are the canvas actions[], which the page shows as buttons outside the
  frame and runs from a user click. A click inside the frame cannot arm a write, because the page cannot tell a real click
  from script-generated activity across the frame boundary.

Residual risks (accepted, worth knowing)
  - A read returns whatever the user can GET to the generated code. It cannot send it anywhere except by putting it in a
    field value or screen text the user then sees, and sees submitted.
  - DNS prefetch and similar browser behavior are not stopped by CSP in every browser.
  - A script that loops forever can use a CPU core and may freeze the tab. A sandboxed frame is isolated for security, not
    for resources, and the browser does not promise it a separate thread. The user closes the tab or starts a new chat.
  - 'unsafe-eval' is on inside the frame only.

The protocol names no Vue or Quasar type. A different frame runtime can replace AssistSandboxRuntime.js without changing
the parent side.

Tests: framework/test/vue_sfc_sandbox_browser_smoke.py (render, isolation probes, CSP network blocks, bridge reads and
refusals, events, compile errors, resize, widgets) and framework/src/test/groovy/LlmReadEndpointTests.groovy (the endpoint).
