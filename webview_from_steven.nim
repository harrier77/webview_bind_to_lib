 
const WebView_NoDevTools* = 0
const WebView_DevTools* = 1
const WebView_Hint_None* = 0
const WebView_Hint_Min* = 1
const WebView_Hint_Max* = 2
const WebView_Hint_Fixed* = 3
const WebView_Return_Ok* = 0
const WebView_Return_Error* = 1

when defined windows:
    const libwebview = "./webview.dll"
    proc MoveWindow(nHandle, x, y, w, h: clong, repaint: cshort) {.stdcall, dynlib: "user32", importc: "MoveWindow".}
    proc ShowWindow(nHandle, mode: clong) {.stdcall, dynlib: "user32", importc: "ShowWindow".}
elif defined linux:
    const libwebview = "./libwebview.so"
    proc gtk_window_move(nHandle, x, y: clong) {.cdecl, dynlib: "libgtk-3.so", importc.}
    proc gtk_window_resize(nHandle, w, h: clong) {.cdecl, dynlib: "libgtk-3.so", importc.}
    proc gtk_window_maximize(nHandle: clong) {.cdecl, dynlib: "libgtk-3.so", importc.}
else:
    const libwebview = "./libwebview.dylib"

proc webview_create*(debugOn, windowid: clong): pointer {.cdecl, dynlib: libwebview, importc.}
proc webview_get_window*(webview: pointer): clong {.cdecl, dynlib: libwebview, importc.}
proc webview_destroy*(webview: pointer) {.cdecl, dynlib: libwebview, importc.}
proc webview_run*(webview: pointer) {.cdecl, dynlib: libwebview, importc.}
proc webview_terminate*(webview: pointer) {.cdecl, dynlib: libwebview, importc.}
proc webview_dispatch*(webview, fn, args: pointer) {.cdecl, dynlib: libwebview, importc.}
proc webview_set_html*(webview: pointer, html: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_set_title*(webview: pointer, title: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_set_size*(webview: pointer, width, height, hints: clong) {.cdecl, dynlib: libwebview, importc.}
proc webview_navigate*(webview: pointer, url: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_init*(webview: pointer, js: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_eval*(webview: pointer, js: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_bind*(webview: pointer, name: cstring, fn, args: pointer) {.cdecl, dynlib: libwebview, importc.}
proc webview_unbind*(webview: pointer, name: cstring) {.cdecl, dynlib: libwebview, importc.}
proc webview_return*(webview: pointer, seqno: cstring, status: clong, res: cstring) {.cdecl, dynlib: libwebview, importc.}

proc webview_maximize*(webview: pointer) =
    var hndl = webview_get_window(webview)
    when defined windows:
        ShowWindow(hndl, 3)
    elif defined linux:
        gtk_window_maximize(hndl)
    else:
        # TODO: Mac OS, so for now ...
        webview_set_size(webview, w, h, WebView_Hint_None)

proc webview_move_size*(webview: pointer, x, y, w, h: int) =
    var hndl = webview_get_window(webview)
    when defined windows:
        MoveWindow(hndl, w, y, w, h, 1)
    elif defined linux:
        gtk_window_move(hndl, x, y)
        gtk_window_resize(hndl, w, h)
    else:
        # ** TODO **, so for now ...
        webview_set_size(webview, w, h, WebView_Hint_None)

when isMainModule:
    var html = """
        <head><body>
        <button id='btn-test' >Click Me</button>
        <script>
        function test(evt) {
            var someData = { 'param1': 'Hello from JS!' };
            var s = window.rpc( evt.target.id, evt.type, someData )
            .then(s => {
                alert(s.result);
            })
        }
        document.getElementById('btn-test').addEventListener('click', test);
        </script>
        </head></body>
        """

    var w {.global.} = webview_create(WebView_DevTools, 0)

    proc js_rpc(seqid, req: cstring, args: clong): void =
        echo(req)
        webview_return(w, seqid, 0, "{ 'result': 'Hello from Nim!' }")

    webview_bind(w, "rpc", js_rpc, nil)

    # webview_move_size(w, 20, 20, 1000, 500)
    webview_maximize(w)
    webview_set_title(w, "Nim WebView Example")
    webview_set_html(w, html)
    # webview_navigate(w, "https://nim-lang.org")
    webview_run(w)
    webview_destroy(w)
