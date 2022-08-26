#
WASMTOOLS ?= /cygdrive/c/SDKS/llvm-wasm
CC        := $(WASMTOOLS)/clang
CXX       := $(WASMTOOLS)/clang -x c++
LD        := $(WASMTOOLS)/wasm-ld
OPT       := $(WASMTOOLS)/wasm-opt

EXPORTS   := square
LIBCROOT  ?= ../..
BUILD     ?= RELEASE
#########################
ifeq ($(BUILD),RELEASE)
  LDFLAGS   := --strip-all --gc-sections
  OPTFLAGS  := -O3
else
  LDFLAGS   :=
  OPTFLAGS  := -g -O0
endif
#########################
OUTDIR    := bin
OBJDIR    := obj
INCLUDES  :=
SOURCES   := main.c
OBJS      := $(addprefix $(OBJDIR)/, $(SOURCES:.c=.o))
WASM      := $(OUTDIR)/app.wasm
JS        := $(OUTDIR)/app.js

# Flags for wasm-ld.
LDFLAGS   += --no-entry --lto-O3
LDFLAGS   += $(addprefix --export=, $(EXPORTS))

all: $(OBJDIR) $(JS)

# wasm
$(WASM): $(OBJS)
	@$(LD) $(LDFLAGS) -o $@ $^
	@echo Generate $@
	@$(OPT) $(OPTFLAGS) -o $@ $@
	@echo Optimize $@

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
CCFLAGS     := -Ofast -std=c99

# Global compiler flags for Wasm targeting
CLANGFLAGS  := -target wasm32 -nostdinc++ -flto -D__EMSCRIPTEN__ -fshort-wchar
CLANGFLAGS  += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics
CLANGFLAGS  += -isystem"$(LIBCROOT)/include"

# lower-case vpath
vpath %.h c
vpath %.c c

$(OBJDIR)/%.o: %.c
	@$(CC) $(CCFLAGS) $(CLANGFLAGS) -o $@ -c $<
	@echo Compile $< TO $@

$(OBJDIR)/main.o: main.c
