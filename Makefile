# config your WASMTOOLS path
WASMTOOLS ?= /cygdrive/e/SDKS/wasm
CC        := $(WASMTOOLS)/clang.exe
AR        := $(WASMTOOLS)/llvm-ar.exe

LIBDIR    := lib
OBJDIR    := obj
INCLUDES  := -Iinclude
SOURCES   := ctype.c errno.c
OBJS      := $(addprefix $(OBJDIR)/, $(SOURCES:.c=.o))
TARGET    := $(LIBDIR)/libwasmc.a

# entry
all: $(OBJDIR) $(LIBDIR) $(TARGET)

# libwasmc
$(TARGET): $(OBJS)
	$(AR) rcs $@ $^

$(LIBDIR):
	@mkdir -p $@

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

$(OBJDIR)/ctype.o: ctype.c ctype.h
$(OBJDIR)/errno.o: errno.c errno.h
