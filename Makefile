# config your WASMTOOLS path
WASMTOOLS ?= /cygdrive/e/SDKS/wasm
CC        := $(WASMTOOLS)/clang.exe
LD        := $(WASMTOOLS)/wasm-ld.exe

OUTDIR    := lib
OBJDIR    := obj
INCLUDES  := -Iinclude
SOURCES   := ctype.c
OBJS      := $(addprefix $(OBJDIR)/, $(SOURCES:.c=.o))
TARGET    := $(OUTDIR)/wasm-libc.bc

# Flags for wasm-ld. 
LDFLAGS   := --lto-O3

all: $(OBJDIR) $(TARGET)

# wasm-libc.bc
$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -r -o $@ $^

$(OBJDIR):
	@mkdir -p $@

clean:
	rm -rf $(OBJS) $(TARGET)

.PHONY: clean all

# Global compiler flags
CCFLAGS     := -Ofast -std=c99

# Global compiler flags for Wasm targeting
CLANGFLAGS  := $(INCLUDES) -target wasm32 -nostdinc++ -flto -D__EMSCRIPTEN__
CLANGFLAGS  += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics

# lower-case vpath
vpath %.h include
vpath %.c src

$(OBJDIR)/%.o: %.c
	$(CC) $(CCFLAGS) $(CLANGFLAGS) -o $@ -c $<

ctype.c: ctype.h
