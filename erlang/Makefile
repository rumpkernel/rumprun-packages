include ../Makefile.inc

PKG_VERSION=18.0
UPSTREAM=http://www.erlang.org/download/otp_src_$(PKG_VERSION).tar.gz
TARBALL=$(notdir $(UPSTREAM))
ARCH=$(shell $(RUMPRUN_CC) -dumpmachine)
RUMP_INSTALL_LOCATION=/opt/erlang

LOCAL_INSTALL_DESTINATION=$(shell pwd)/build/erlangdist

# use "make V=1" for getting verbose build of erlang, which
# is very useful for debugging build issues
ifneq ($(V), 1)
  V=0
endif

all: build/erlang examples images

build/erlang: build/Makefile
	$(MAKE) -C build V=$(V)
	$(MAKE) -C build V=$(V) DESTDIR=$(LOCAL_INSTALL_DESTINATION) install
	mkdir -p bin
	cp build/bin/$(RUMPRUN_TOOLCHAIN_TUPLE)/beam bin/

ERLANG_CONF_OPTS += \
	--prefix=$(RUMP_INSTALL_LOCATION) \
	--disable-shared \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--build=$(ARCH) \
	erl_xcomp_sysroot=$(RUMPRUN_SYSROOT) \
	--without-termcap \
	--without-odbc \
	--without-wx \
	--disable-shared \
	--enable-static \
	--disable-dynamic-ssl-lib

build/Makefile: build/bootstrap_complete
	(cd build; ./configure $(ERLANG_CONF_OPTS))

build/bootstrap_complete: build/stamp_patch build/configure
	(cd build; ./configure --enable-bootstrap-only)
	(cd build; make)
	touch $@

# only needed when building from a git repo
build/configure: build/stamp_patch
	(cd build; ./otp_build autoconf)

build/stamp_patch: build/untar_sources patches/*
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)
	touch $@

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/untar_sources: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))
	touch $@

examples: examples/app.iso

examples/app.iso:
	$(MAKE) -C examples all

.PHONY: images
images: images/erlang.iso


images/erlang.iso: build/Makefile
	mkdir -p images
	cp erl_inetrc build/erlangdist/$(RUMP_INSTALL_LOCATION)/
	cp hosts.template build/erlangdist/$(RUMP_INSTALL_LOCATION)/hosts
	genisoimage -l -r -o images/erlang.iso build/erlangdist/$(RUMP_INSTALL_LOCATION)

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/erlang.iso
	-$(MAKE) -C examples clean

.PHONY: distclean
distclean: clean
	rm -rf build
