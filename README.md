# webview_bind_to_lib
How to use webview linked to dynamic library webview.so or webview.dll.

<p>I found the nim code <a href="https://forum.nim-lang.org/t/10301#68798">on this post on nim forum</a> and
I think it is very useful. It is possible to call a nim proc from a javascript function inside webview html page.</p>
<p>
  
</p>Compiled libraries can be found on github, for example here:<br/>
https://github.com/PierceNg/fpwebview/tree/master/dll/x86_64<br/>
or here:<br/>
https://github.com/webview/webview_csharp/tree/master</p>
Compiling on Linux worked with the first library downloaded from github. In Windows I had to compile a dll library myself, from the original source of Serge WebView <a href="https://github.com/webview/webview"> on Github here.</a>