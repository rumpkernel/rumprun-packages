include ../Makefile.inc

NODE_VERSION=4.1.1
NODE_BIN=build/out/Release/node
 
UPSTREAM=https://github.com/nodejs/node/archive/v$(NODE_VERSION).tar.gz
TARBALL=$(notdir $(UPSTREAM))

PKGSRC_DIR=pkgsrc/lang/nodejs/patches

CPU=$(shell echo $(RUMPRUN_TOOLCHAIN_TUPLE) | cut -d - -f 1)
ifeq ($(CPU),x86_64)
	CPU=x64
endif

export CC=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc
export CXX=$(RUMPRUN_TOOLCHAIN_TUPLE)-g++
export AR=$(RUMPRUN_TOOLCHAIN_TUPLE)-ar
export RANLIB=$(RUMPRUN_TOOLCHAIN_TUPLE)-ranlib
export LINK=$(CXX)
export GYP_DEFINES="OS=netbsd"

all: $(NODE_BIN)

$(NODE_BIN): build/config.mk _third_party_main.js
	$(MAKE) -C build

build/config.mk: build/stamp_patch
	(cd build; ./configure --dest-cpu=$(CPU) --link-module=../_third_party_main.js)

build/stamp_patch: build/configure patches/* | dl/$(PKGSRC_DIR)
	(cd build && ../../scripts/apply-patches.sh '' ../dl/$(PKGSRC_DIR)/patch-* ../patches/*)
	touch $@

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh $(UPSTREAM) dl/$(TARBALL)

dl/$(PKGSRC_DIR):
	mkdir -p dl
	rm -rf dl/$(PKGSRC_DIR)
	(cd dl && cvs -q -z2 -d anoncvs@anoncvs.NetBSD.org:/cvsroot checkout -r pkgsrc-2015Q3 -P $(PKGSRC_DIR))
	perl -pi -e 's/\@PYTHONBIN@/python/g' dl/$(PKGSRC_DIR)/patch-*

.PHONY: bake_hw_generic
bake_hw_generic: $(NODE_BIN).bin

$(NODE_BIN).bin: $(NODE_BIN)
	rumpbake hw_generic $(NODE_BIN).bin $(NODE_BIN)

.PHONY: clean
clean:
	$(MAKE) -C build clean
	rm -f $(NODE_BIN).bin

.PHONY: distclean
distclean:
	rm -rf build dl
