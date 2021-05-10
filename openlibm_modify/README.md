Copy and overwrite
---------

These two files are used to cut unnecessary functions for wasm

```c
// openlibm_math.h  ---> openlibm-master/include/
// Make.files       ---> openlibm-master/src/
```

In order to compile openlibm, You still need to modify the `openlibm-master/Makefile` for cygwin

```makefile
OPENLIBM_HOME= .
```

And add the following code in the corresponding place in `openlibm-master/Make.inc`

```makefile
## ifeq ($(ARCH),wasm32)

WASMTOOLS  := /cygdrive/e/SDKS/wasm
CC         := $(WASMTOOLS)/clang.exe
AR         := $(WASMTOOLS)/llvm-ar.exe
CFLAGS_add += -fno-builtin -fno-strict-aliasing -fvisibility=hidden -fno-exceptions -fno-threadsafe-statics
CFLAGS_add += -target wasm32 -flto -D__EMSCRIPTEN__ -fshort-wchar
```

Use `make ARCH=wasm32` to build the wasm32 library

for you project

Add `-DOPENLIBM` for `clang.exe`

Add .`-lopenlibm` for `wasm-ld.exe`
