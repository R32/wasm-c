#
OUTDIR     := ../
JS         := $(OUTDIR)/main.js
CSS        := $(OUTDIR)/style.css


BUILD      ?= RELEASE
#########################
ifeq ($(BUILD),RELEASE)
  CSSFLAGS := --minify
  JSFLAGS  :=
else
  CSSFLAGS := --sourcemap
  JSFLAGS  :=
endif
#########################

all: $(JS) $(CSS)

clean:
	rm -f $(CSS) $(JS)

.PHONY: all clean

# main.js + work.js
$(JS): build.hxml $(wildcard src/*.hx src/**/*.hx)
	haxe $(JSFLAGS) build.hxml

# chokidar hss/style.hss -c "hss -output ../ hss/style.hss"
$(CSS): hss/style.hss
	hss -output $(OUTDIR) $(CSSFLAGS) $<
