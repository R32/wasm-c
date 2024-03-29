# config your WASMTOOLS path
WASMTOOLS ?= /cygdrive/c/SDKS/llvm-wasm
CC        := $(WASMTOOLS)/clang.exe
CXX       := $(CC) -x c++
AR        := $(WASMTOOLS)/llvm-ar.exe

LIBDIR    := lib
OBJDIR    := obj
INCLUDES  := -Iinclude
SOURCES   := ctype.c errno.c locale.c string.c time.c stdlib.c wchar.c
SOURCES   += _ucs2.c _malloc.c rand.c strtol.c
SOURCES   += stdio.c printf.c
OBJS      := $(SOURCES:%.c=$(OBJDIR)/%.o)

# for simple c++, don't put the cpp objs together with OBJS
CXXOBJS   := $(OBJDIR)/new.oo
TARGET    := $(LIBDIR)/libwasmc.a

# entry
all: $(OBJDIR) $(LIBDIR) $(TARGET)

# libwasmc
$(TARGET): $(OBJS) $(CXXOBJS)
	@$(AR) rcs $@ $?
	@echo Archived $@

$(LIBDIR):
	@mkdir -p $@

$(OBJDIR):
	@mkdir -p $@

clean:
	rm -rf $(OBJS) $(CXXOBJS) $(TARGET)

.PHONY: clean all

# Global compiler flags
CFLAGS      := -O3 -std=c99 -nostdinc
CXXFLAGS    := -O3 -std=c++11 -nostdinc++ -fno-rtti -Wno-writable-strings -Wno-unknown-pragmas

# Global compiler flags for Wasm targeting
CLANGFLAGS  := $(INCLUDES) -target wasm32 -nostdlib -flto -D__EMSCRIPTEN__ -fshort-wchar
CLANGFLAGS  += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics

# lower-case vpath
vpath %.h include
vpath %.c src

$(OBJDIR)/%.o: %.c
	@$(CC) $(CFLAGS) $(CLANGFLAGS) -o $@ -c $<
	@echo Compile $< TO $@

$(OBJDIR)/ctype.o: ctype.c ctype.h
$(OBJDIR)/errno.o: errno.c errno.h
$(OBJDIR)/locale.o: locale.c locale.h
$(OBJDIR)/string.o: string.c string.h
$(OBJDIR)/time.o: time.c time.h
$(OBJDIR)/wchar.o: wchar.c wchar.h
# stdlib
$(OBJDIR)/stdlib.o: stdlib.c stdlib.h
$(OBJDIR)/_malloc.o: _malloc.c _malloc.h
$(OBJDIR)/_ucs2.o: _ucs2.c _ucs2.h
$(OBJDIR)/rand.o: rand.c
$(OBJDIR)/strtol.o: strtol.c
# stdio
$(OBJDIR)/stdio.o: stdio.c stdio.h
$(OBJDIR)/printf.o: printf.c printf.h stdarg.h stddef.h stdint.h stdbool.h

# new.cpp
$(OBJDIR)/new.oo: src/new.cpp stddef.h _javascript_call.h _malloc.h
	@$(CXX) $(CXXFLAGS) $(CLANGFLAGS) -o $@ -c $<
	@echo Compile $< TO $@