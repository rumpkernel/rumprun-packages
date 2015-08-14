include ../Makefile.inc

UPSTREAM=https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz
TARBALL=$(notdir $(UPSTREAM))
ARCH=$(shell $(RUMPRUN_CC) -dumpmachine)
CYTHON=$(shell which cython)
AUTORECONF=$(shell which autoreconf)

ifeq (, $(CYTHON))
$(error "Cython not found in PATH, but needed to build python example")
endif

ifeq (, $(AUTORECONF))
$(error "autoreconf not found in PATH, but needed to build configure script (install GNU autotools)")
endif

ifeq (, $(shell which $(RUMPRUN_CC)))
$(error "cross compiler not found in PATH, is app-tools/ in your path?")
endif

all: build/python images examples

build/python: build/Makefile
	$(MAKE) -C build
	$(MAKE) -C build install

PYTHON_CONF_ENV += \
	LDFLAGS="-static -static-libgcc" \
	CPPFLAGS="-static" \
	CC=$(RUMPRUN_CC) \
	CONFIG_SITE=config.site

PYTHON_CONF_OPTS += \
	--prefix=$(shell pwd)/build/pythondist \
	--disable-shared \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--build $(ARCH) \
	--disable-ipv6

build/Makefile: build/stamp_patch
	(cd build; $(PYTHON_CONF_ENV) ./configure $(PYTHON_CONF_OPTS))

build/stamp_patch: build/configure patches/*
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)
	(cd build && autoreconf -iv)
	touch $@

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))
	cp config.site build/

.PHONY: examples
examples:
	$(CYTHON) --embed -v -3 -Werror -o examples/hw.c examples/hw.py
	$(RUMPRUN_CC) examples/hw.c -Ibuild/pythondist/include/python3.4m -Lbuild/pythondist/lib -lpython3.4m -lutil -lm -lz -lssl -lcrypto -o examples/hw
	$(RUMPRUN_APPTOOLS_DIR)rumpbake hw_generic examples/hw.bin examples/hw

.PHONY: images
images: images/stubetc.iso images/python.iso

images/stubetc.iso: ../stubetc/etc/*
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

images/python.iso: build/Makefile
	genisoimage -l -r -o images/python.iso build/pythondist/lib/python3.4

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/stubetc.iso images/python.iso
	rm -rf dl/
	rm -f examples/hw.c examples/hw.bin examples/hw

.PHONY: distclean
distclean: clean
	rm -rf build
