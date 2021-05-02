something about wasm
--------

**experimental**

### Reference

[webassembly-without-emscripten](http://schellcode.github.io/webassembly-without-emscripten)

[c-to-webassembly](https://surma.dev/things/c-to-webassembly/)

### Tools

Win7x64 + cygwin(for gnu make)

* clang.exe, wasm-ld.exe: Both of them are extracted from [the official LLVM releases page] by 7zip
* wasm-opt.exe: [WebAssembly binaryen]
* wasm2wat.exe: (optional) [WebAssembly wabt]
* haxe 4+

### TODO

* [ ] looking for an archive tool(like wasm-ar?) for `wasm-ld`

[emscripten]:https://github.com/emscripten-core/emscripten
[WebAssembly binaryen]:https://github.com/WebAssembly/binaryen
[WebAssembly wabt]:https://github.com/WebAssembly/wabt
[the official LLVM releases page]:https://releases.llvm.org/download.html
