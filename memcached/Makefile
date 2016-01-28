include ../Makefile.inc

UPSTREAM=http://www.memcached.org/files/memcached-1.4.25.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: $(RUMPRUN_PKGS_DIR)/lib/libevent.a images

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libevent.a
$(RUMPRUN_PKGS_DIR)/lib/libevent.a:
	$(MAKE) -C ../libevent

MEMCACHED_CONF_ENV += \
	LIBS=-lc \
	CC=$(RUMPRUN_CC)

MEMCACHED_CONF_OPTS += \
	--prefix=$(shell pwd)/build/dist \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--with-libevent=$(shell pwd)/../../pkgs

build/stamp_patch:
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)
	touch $@

.PHONY: build/Makefile
build/Makefile: build/stamp_patch
	(cd build; $(MEMCACHED_CONF_ENV) ./configure $(MEMCACHED_CONF_OPTS); make)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: images
images: images/stubetc.iso

images/stubetc.iso: build/configure build/Makefile ../stubetc/etc/*
	mkdir -p images
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

.PHONY: clean
clean:
	(cd build; make clean)
	rm -f images/stubetc.iso
	rm build/stamp_patch

.PHONY: distclean
distclean: clean
	rm -rf build
