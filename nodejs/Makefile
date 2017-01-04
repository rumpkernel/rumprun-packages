include ../Makefile.inc
include Makefile.inc

UPSTREAM=https://github.com/nodejs/node/archive/v$(NODE_VERSION).tar.gz
TARBALL=$(notdir $(UPSTREAM))

PKGSRC_DIR=pkgsrc/lang/$(PKGSRC)/patches

RUMPRUN_TOOLCHAIN_ARCH=$(shell echo $(RUMPRUN_TOOLCHAIN_TUPLE) | cut -d - -f 1)
ifeq ($(RUMPRUN_TOOLCHAIN_ARCH),x86_64)
	CPU=x64
endif
ifeq ($(RUMPRUN_TOOLCHAIN_ARCH),i486)
	CPU=x86
endif
ifndef CPU
	$(error Unsupported CPU architecture)
endif

export CC=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc
export CXX=$(RUMPRUN_TOOLCHAIN_TUPLE)-g++
export AR=$(RUMPRUN_TOOLCHAIN_TUPLE)-ar
export RANLIB=$(RUMPRUN_TOOLCHAIN_TUPLE)-ranlib
export LINK=$(CXX)
export GYP_DEFINES="OS=netbsd"

NODE_OUT=$(BUILD_DIR)/out/Release/node

all: $(NODE_BIN)

$(NODE_BIN): $(NODE_OUT)
	cp $^ $@

$(NODE_OUT): $(BUILD_DIR)/node.gyp $(BUILD_DIR)/config.mk _third_party_main.js rumpmain.js
	$(MAKE) -C $(BUILD_DIR)

$(BUILD_DIR)/config.mk: $(BUILD_DIR)/stamp_patch
	(cd $(BUILD_DIR); ./configure --without-snapshot --dest-cpu=$(CPU) --link-module=../_third_party_main.js --link-module=../rumpmain.js)

$(BUILD_DIR)/stamp_patch: $(BUILD_DIR)/configure patches/*.patch | patches/$(PKGSRC_DIR)
	(cd $(BUILD_DIR) && ../../scripts/apply-patches.sh -p 0 ./ ../patches/$(PKGSRC_DIR)/patch-* ../patches/*.patch)
	touch $@

$(BUILD_DIR)/node.gyp $(BUILD_DIR)/configure: | dl/$(TARBALL)
	mkdir -p $(BUILD_DIR)
	(cd $(BUILD_DIR) && tar -x --strip-components 1 -f ../dl/$(TARBALL))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh $(UPSTREAM) dl/$(TARBALL)

patches/$(PKGSRC_DIR):
	(cd patches && cvs -q -z2 -d anoncvs@anoncvs.NetBSD.org:/cvsroot checkout -r HEAD -P $(PKGSRC_DIR))
	perl -pi -e 's/\@PYTHONBIN@/python/g' patches/$(PKGSRC_DIR)/patch-*

.PHONY: clean
clean:
	if [ -d $(BUILD_DIR) ]; then $(MAKE) -C $(BUILD_DIR) clean; rm -f $(NODE_BIN) $(NODE_BIN).bin; fi
	ln -sf default.js rumpmain.js
	$(MAKE) -C examples clean

.PHONY: distclean
distclean:
	rm -rf build-* dl
