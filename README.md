something about wasm
--------

**experimental**

### Reference

[webassembly-without-emscripten](http://schellcode.github.io/webassembly-without-emscripten)

[c-to-webassembly](https://surma.dev/things/c-to-webassembly/)

[wasm instructions]

[clang Basic TokenKinds.def]

[clang Basic Builtins.def]

[BuiltinsWebAssembly.def]

### Tools

Win7x64 + cygwin(for gnu make)

* clang.exe, wasm-ld.exe, llvm-ar.exe: all of them are extracted from [the official LLVM releases page] by 7zip
* wasm-opt.exe: [WebAssembly binaryen]
* ~~wasm2wat.exe~~: run `wasm-opt --print file.wasm`
* haxe 4+

### TODO


[WebAssembly binaryen]:https://github.com/WebAssembly/binaryen
[the official LLVM releases page]:https://releases.llvm.org/download.html
[wasm instructions]:https://webassembly.github.io/spec/core/appendix/index-instructions.html
[BuiltinsWebAssembly.def]:https://github.com/llvm/llvm-project/blob/main/clang/include/clang/Basic/BuiltinsWebAssembly.def
[clang Basic TokenKinds.def]:https://github.com/llvm/llvm-project/blob/main/clang/include/clang/Basic/TokenKinds.def
[clang Basic Builtins.def]:https://github.com/llvm/llvm-project/blob/main/clang/include/clang/Basic/Builtins.def
