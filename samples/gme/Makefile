# target
OUTDIR     := bin
GMEDIR     := lib
LIBGME     := $(GMEDIR)/libgme.a
TARGET     := $(OUTDIR)/gme.wasm
JS         := $(OUTDIR)/app.js

# check out src/Gme.hx
EXPORTS    := gme_load_data gme_track_count gme_start_track gme_play
EXPORTS    += gme_delete gme_set_fade gme_track_ended gme_tell gme_seek
EXPORTS    += gme_set_tempo gme_set_stereo_depth

# wasmc + openlibm
LIBCROOT   ?= ../..

# tools
WASMTOOLS  ?= /cygdrive/c/SDKS/llvm-wasm
CC         := $(WASMTOOLS)/clang.exe
CXX        := $(CC) -x c++
AR         := $(WASMTOOLS)/llvm-ar.exe
LD         := $(WASMTOOLS)/wasm-ld
OPT        := $(WASMTOOLS)/wasm-opt

BUILD      ?= RELEASE
#########################
ifeq ($(BUILD),RELEASE)
  LDFLAGS  := --strip-all --gc-sections
  OPTFLAGS := -O3
else
  LDFLAGS  :=
  OPTFLAGS := -g -O0
endif
#########################

# Flags for wasm-ld.
# --initial-memory=$$((1024*64*12))
# -z stack-size=$$((1024*64*8))
LDFLAGS    += -L"$(LIBCROOT)/lib" -lwasmc -lopenlibm
LDFLAGS    += --no-entry --lto-O3 --initial-memory=$$((1024*64*8))
LDFLAGS    += $(addprefix --export=, $(EXPORTS))

SOURCES    := $(GMEDIR)/game-music-emu-0.6.2/gme
INCLUDES   := -I$(SOURCES)

OBJDIR     := $(GMEDIR)/obj
CXXFILES   := $(notdir $(wildcard $(SOURCES)/*.cpp))
CXXOBJS    := $(CXXFILES:%.cpp=$(OBJDIR)/%.o)

CFLAGS     := -Ofast -std=c99 -nostdinc
CXXFLAGS   := -Ofast -std=c++11 -nostdinc++ -fno-rtti -Wno-writable-strings -Wno-unknown-pragmas
CLANGFLAGS := $(INCLUDES) -target wasm32 -nostdlib -flto -fshort-wchar
CLANGFLAGS += -fvisibility=hidden -fno-builtin -fno-exceptions -fno-threadsafe-statics
# -D
CLANGFLAGS += -D__EMSCRIPTEN__ -DNDEBUG
CLANGFLAGS += -isystem"$(LIBCROOT)/include"

all: $(OBJDIR) $(TARGET) $(JS)

clean:
	@echo clean ...
	@rm -fr $(OBJDIR)/** $(LIBGME) $(TARGET) $(JS)

.PHONY: all clean

# gme.wasm
$(TARGET): $(OBJDIR)/glue.o $(LIBGME)
	@$(LD) $(LDFLAGS) -o $@ $^
	@echo Generate $@
	@$(OPT) $(OPTFLAGS) -o $@ $@
	@echo Optimize $@

# js
$(JS): build.hxml $(wildcard src/*.hx src/**/*.hx)
	haxe build.hxml

# libgme.a
$(LIBGME): $(CXXOBJS)
	@$(AR) rcs $@ $?
	@echo Archived $@

# mkdir
$(OBJDIR):
	mkdir -p $@

# lower-case vpath
vpath %.cpp $(SOURCES)

$(OBJDIR)/%.o: %.cpp
	@$(CXX) $(CLANGFLAGS) $(CXXFLAGS) -c $< -o $@
	@echo Compile $(notdir $<) TO $@

$(OBJDIR)/glue.o: $(GMEDIR)/glue.c
	@$(CC) $(CLANGFLAGS) $(CFLAGS) -c $< -o $@
	@echo Compile $(notdir $<) TO $@
