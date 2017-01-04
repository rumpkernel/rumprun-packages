include ../Makefile.inc

UPSTREAM=https://github.com/erlang/otp/archive/OTP-18.3.4.tar.gz
TARBALL=$(notdir $(UPSTREAM))
ARCH=$(shell $(HOST_CC) -dumpmachine)
RUMP_INSTALL_LOCATION=/opt/erlang

# This trickery is required to enable a complete build of Erlang
# for the host operating system. This host version can be used
# subsequently for building user applications and even running
# them without a separate installation of Erlang.
#
# save original values as set by Makefile.inc for cross compilation
ORIGINAL_CPPFLAGS=$(CPPFLAGS)
ORIGINAL_LDFLAGS=$(LDFLAGS)
# cleanup values set by Makefile.inc
unexport CPPFLAGS
unexport LDFLAGS

# This is the location where the host version of Erlang shall
# be archived.
HOST_ARCHIVE_LOCATION=$(shell pwd)/build/host_erlangdist
# This location is the value of the prefix set while configuring
# the host version of Erlang
HOST_PREFIX_LOCATION=/opt/erlang

LOCAL_INSTALL_DESTINATION=$(shell pwd)/build/erlangdist
LOCAL_BUILD_LOCATION=$(shell pwd)/build

# use "make V=1" for getting verbose build of erlang, which
# is very useful for debugging build issues
ifneq ($(V), 1)
  V=0
endif

.NOTPARALLEL: all
all: libssl build_erlang examples images

build_erlang: bin/beam

build/erlang_build_complete: build/Makefile
	$(MAKE) -C build V=$(V)
	$(MAKE) -C build V=$(V) DESTDIR=$(LOCAL_INSTALL_DESTINATION) install
	touch $@

bin/beam: build/erlang_build_complete
	mkdir -p bin
	cp build/bin/$(RUMPRUN_TOOLCHAIN_TUPLE)/beam bin/

beam.hw.bin: bin/beam
	rumprun-bake hw_virtio beam.hw.bin bin/beam

# Need to disable debugger and et because they depend on wx, which is
# disabled, so we need to disable those two as well.
# The cos* are disabled because corba is no longer relevant.
BASIC_DISABLED_ERLANG_APPS_CONF_OPTS = \
	--without-odbc \
	--without-wx --without-debugger --without-et \
	--without-javac \
	--without-edoc \
	--without-erl_docgen \
	--without-hipe \
	--without-ic \
	--without-orber \
	--without-pman \
	--without-toolbar \
	--without-tv \
	--without-webtool \
	--without-typer \
	--without-observer \
	--without-cosEvent --without-cosEventDomain \
	--without-cosFileTransfer --without-cosNotification \
	--without-cosProperty --without-cosTime --without-cosTransactions

# Autoconf guesses (default behavior) that kqueue needs to
# be disabled due to cross compilation, but it is an incorrect
# assumption because Rumprun unikernel supports it (thanks to NetBSD).
# Hence, set erl_xcomp_kqueue to yes (because it defaults to no).
# see http://erlang.org/doc/installation_guide/INSTALL-CROSS.html
# for details.
ERLANG_CONF_OPTS += \
	--prefix=$(RUMP_INSTALL_LOCATION) \
	--with-ssl=$(RUMPRUN_PKGS_DIR) \
	--disable-shared \
	--enable-static \
	--enable-static-nifs=$(LOCAL_BUILD_LOCATION)/lib/crypto/priv/lib/$(RUMPRUN_TOOLCHAIN_TUPLE)/crypto.a,$(LOCAL_BUILD_LOCATION)/lib/asn1/priv/lib/$(RUMPRUN_TOOLCHAIN_TUPLE)/asn1rt_nif.a \
	--enable-static-drivers \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--build=$(ARCH) \
	erl_xcomp_sysroot=$(RUMPRUN_SYSROOT) \
	erl_xcomp_kqueue=yes \
	--without-termcap \
	$(BASIC_DISABLED_ERLANG_APPS_CONF_OPTS) \
	--disable-dynamic-ssl-lib


build/Makefile: build/bootstrap_complete
	(cd build; LIBS="$(RUMPRUN_PKGS_DIR)/lib/libcrypto.a" \
		CPPFLAGS="$(ORIGINAL_CPPFLAGS)" LDFLAGS="$(ORIGINAL_LDFLAGS)" \
		./configure $(ERLANG_CONF_OPTS))

# Need to reset CPPFLAGS LDFLAGS because they are set for cross compilation
# to rumprun-packages/pkg for including dependencies.
# Alternatively, setting --enable-bootstrap-only as configure flag
# will also suffice, but we need complete installation of host version
# of Erlang, so this trickery is required.
build/bootstrap_complete: build/stamp_patch build/configure
	(cd build; \
		LIBS="" CPPFLAGS="" LDFLAGS="" \
		./configure \
			--prefix=$(HOST_PREFIX_LOCATION) \
			$(BASIC_DISABLED_ERLANG_APPS_CONF_OPTS))
	(cd build; $(MAKE) bootstrap; \
		$(MAKE); \
		$(MAKE) DESTDIR=$(HOST_ARCHIVE_LOCATION) install)
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

.PHONY: examples
examples: examples/app.iso

examples/app.iso: build/bootstrap_complete
	$(MAKE) -C examples all

.PHONY: images
images: images/erlang.iso


images/erlang.iso: build/erlang_build_complete
	mkdir -p images
	cp erl_inetrc build/erlangdist/$(RUMP_INSTALL_LOCATION)/
	cp hosts.template build/erlangdist/$(RUMP_INSTALL_LOCATION)/hosts
	cp resolv.conf.template build/erlangdist/$(RUMP_INSTALL_LOCATION)/resolv.conf
	$(RUMPRUN_GENISOIMAGE) -o images/erlang.iso build/erlangdist/$(RUMP_INSTALL_LOCATION)

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/erlang.iso
	-$(MAKE) -C examples clean

.PHONY: distclean
distclean: clean
	rm -rf build

include ../Makefile.deps
