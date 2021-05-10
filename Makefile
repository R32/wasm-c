# config your WASMTOOLS path
WASMTOOLS ?= /cygdrive/e/SDKS/wasm
CC        := $(WASMTOOLS)/clang.exe
AR        := $(WASMTOOLS)/llvm-ar.exe

LIBDIR    := lib
OBJDIR    := obj
INCLUDES  := -Iinclude
SOURCES   := ctype.c errno.c locale.c string.c time.c stdlib.c wchar.c
SOURCES   += _ucs2.c _malloc.c rand.c strtol.c
SOURCES   += stdio.c printf.c
OBJS      := $(addprefix $(OBJDIR)/, $(SOURCES:.c=.o))
TARGET    := $(LIBDIR)/libwasmc.a

# entry
all: $(OBJDIR) $(LIBDIR) $(TARGET)

# libwasmc
$(TARGET): $(OBJS)
	@$(AR) rcs $@ $^
	@echo Archived $@

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
CLANGFLAGS  := $(INCLUDES) -target wasm32 -nostdinc++ -flto -D__EMSCRIPTEN__ -fshort-wchar
CLANGFLAGS  += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics

# lower-case vpath
vpath %.h include
vpath %.c src

$(OBJDIR)/%.o: %.c
	@$(CC) $(CCFLAGS) $(CLANGFLAGS) -o $@ -c $<
	@echo Compile $< TO $@

$(OBJDIR)/ctype.o: ctype.c ctype.h
$(OBJDIR)/errno.o: errno.c errno.h
$(OBJDIR)/locale.o: locale.c locale.h
$(OBJDIR)/string.o: string.c string.h
$(OBJDIR)/time.o: time.c time.h
$(OBJDIR)/wchar.o: wchar.c wchar.h
#stdlib
$(OBJDIR)/stdlib.o: stdlib.c stdlib.h
$(OBJDIR)/_malloc.o: _malloc.c _malloc.h
$(OBJDIR)/_ucs2.o: _ucs2.c _ucs2.h
$(OBJDIR)/rand.o: rand.c
$(OBJDIR)/strtol.o: strtol.c
#stdio
$(OBJDIR)/stdio.o: stdio.c stdio.h
$(OBJDIR)/printf.o: printf.c printf.h stdarg.h stddef.h stdint.h stdbool.h
