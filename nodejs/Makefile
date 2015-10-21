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

$(NODE_BIN): build/node.gyp build/config.mk _third_party_main.js
	$(MAKE) -C build

build/config.mk: build/stamp_patch
	(cd build; ./configure --dest-cpu=$(CPU) --link-module=../_third_party_main.js)

build/stamp_patch: build/configure patches/*.patch | patches/$(PKGSRC_DIR)
	(cd build && ../../scripts/apply-patches.sh -p 0 ./ ../patches/$(PKGSRC_DIR)/patch-* ../patches/*.patch)
	touch $@

build/node.gyp build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh $(UPSTREAM) dl/$(TARBALL)

patches/$(PKGSRC_DIR):
	(cd patches && cvs -q -z2 -d anoncvs@anoncvs.NetBSD.org:/cvsroot checkout -r pkgsrc-2015Q3 -P $(PKGSRC_DIR))
	perl -pi -e 's/\@PYTHONBIN@/python/g' patches/$(PKGSRC_DIR)/patch-*

.PHONY: bake_hw_generic
bake_hw_generic:
	rumpbake hw_generic $(NODE_BIN).bin $(NODE_BIN)

.PHONY: clean
clean:
	$(MAKE) -C build clean
	rm -f $(NODE_BIN).bin

.PHONY: distclean
distclean:
	rm -rf build dl
