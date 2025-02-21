#
WASMTOOLS ?= /cygdrive/c/SDKS/llvm-wasm
CC        := $(WASMTOOLS)/clang
CXX       := $(WASMTOOLS)/clang -x c++
LD        := $(WASMTOOLS)/wasm-ld
OPT       := $(WASMTOOLS)/wasm-opt

LIBCROOT  ?= ../..
BUILD     ?= RELEASE
#########################
ifeq ($(BUILD),RELEASE)
  LDFLAGS   := --strip-all --gc-sections
  OPTFLAGS  := -O3 --enable-simd
else
  LDFLAGS   :=
  OPTFLAGS  := -g -O0 --enable-simd
endif
#########################
OUTDIR    := bin
OBJDIR    := obj
INCLUDES  :=
SOURCES   := main.c
OBJS      := $(SOURCES:%.c=$(OBJDIR)/%.o)
WASM      := $(OUTDIR)/app.wasm
JS        := $(OUTDIR)/app.js

# Flags for wasm-ld.
LDFLAGS   += --no-entry --lto-O3
LDFLAGS   += -L"$(LIBCROOT)/lib" -lwasmc
LDFLAGS   += $(addprefix --export=, $(EXPORTS))

all: $(OBJDIR) $(JS)

# wasm
$(WASM): $(OBJS)
	@$(LD) $(LDFLAGS) -o $@ $^
	@echo Generate $@
#	@$(OPT) $(OPTFLAGS) -o $@ $@
#	@echo Optimize $@

# js
$(JS): $(WASM) build.hxml $(wildcard src/*.hx src/**/*.hx)
	haxe build.hxml

$(OBJDIR):
	@mkdir -p $@

clean:
	rm -rf $(OBJS) $(WASM) $(JS)

.PHONY: clean all

# Global compiler flags
# CXXFLAGS    := -Ofast -std=c++11 -fno-rtti -Wno-writable-strings -Wno-unknown-pragmas
CFLAGS      := -Ofast -std=c99

# Global compiler flags for Wasm targeting
CLANGFLAGS  := -target wasm32 -msimd128 -nostdinc++ -flto -D__EMSCRIPTEN__ -fshort-wchar
CLANGFLAGS  += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics
CLANGFLAGS  += -isystem"$(LIBCROOT)/include"

# lower-case vpath
vpath %.h c
vpath %.c c

$(OBJDIR)/%.o: %.c
	@$(CC) $(CFLAGS) $(CLANGFLAGS) -o $@ -c $<
	@echo Compile $< TO $@

$(OBJDIR)/main.o: main.c
