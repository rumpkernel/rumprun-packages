include ../Makefile.inc

UPSTREAM=https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz
TARBALL=$(notdir $(UPSTREAM))
ARCH=$(shell $(RUMPRUN_CC) -dumpmachine)

all: build/python images

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
	touch $@

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))
	cp config.site build/

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
	rm -f examples/hw.c examples/hw.bin examples/hw

.PHONY: distclean
distclean: clean
	rm -rf build
