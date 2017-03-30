include ../Makefile.inc

UPSTREAM_HTTPD=http://archive.apache.org/dist/httpd/httpd-2.4.23.tar.gz
TARBALL_HTTPD=dl/$(notdir $(UPSTREAM_HTTPD))
UPSTREAM_APR=http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
TARBALL_APR=dl/$(notdir $(UPSTREAM_APR))
UPSTREAM_APR_UTIL=http://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
TARBALL_APR_UTIL=dl/$(notdir $(UPSTREAM_APR_UTIL))
TARBALLS=$(TARBALL_HTTPD) $(TARBALL_APR) $(TARBALL_APR_UTIL)

ARCH=$(shell $(HOST_CC) -dumpmachine)

all: libssl $(RUMPRUN_PKGS_DIR)/lib/libpcre.a bin/httpd images

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libpcre.a
$(RUMPRUN_PKGS_DIR)/lib/libpcre.a:
	$(MAKE) -C ../pcre

bin/httpd: build/httpd
	mkdir -p bin
	cp $< $@

build/httpd: build/Makefile
	$(MAKE) -C build

APACHE_CONF_ENV += \
		   ap_cv_void_ptr_lt_long=no \
		   ac_cv_sizeof_struct_iovec=1 \
		   ac_cv_func_setpgrp_void=yes \
		   ac_cv_file__dev_zero=no \
		   apr_cv_tcp_nodelay_with_cork=no \
		   ac_cv_define_SO_ACCEPTFILTER=no \
		   CC=$(RUMPRUN_CC)

APACHE_CONF_OPTS += \
		    --host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
		    --build=$(ARCH) \
		    --with-included-apr \
		    --with-pcre="$(RUMPRUN_PKGS_DIR)/bin/pcre-config" \
		    --with-ssl="$(RUMPRUN_PKGS_DIR)/bin" \
		    --with-z=$(RUMPRUN_SYSROOT) \
		    --prefix=/none \
		    --sbindir=/none \
		    --disable-shared \
		    --disable-dso \
		    --disable-util-dso \
		    --disable-unique-id \
		    --disable-auth-digest \
		    --enable-ipv6 \
		    --enable-static-support \
		    --enable-mods-shared=none \
		    --sysconfdir=/data/conf

build/Makefile: build/make_patch
	(cd build; $(APACHE_CONF_ENV) ./configure $(APACHE_CONF_OPTS))

build/make_patch: build/configure build/srclib/apr/configure build/srclib/apr-util/configure patches/*
	../scripts/apply-patches.sh build/ patches/*
	touch $@

$(TARBALLS):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM_HTTPD} $(TARBALL_HTTPD)
	../scripts/fetch.sh ${UPSTREAM_APR} $(TARBALL_APR)
	../scripts/fetch.sh ${UPSTREAM_APR_UTIL} $(TARBALL_APR_UTIL)

build/srclib/apr/configure: build/configure
	mkdir -p build/srclib/apr
	(cd build/srclib && tar -x --strip-components 1 -f ../../$(TARBALL_APR) -C apr)

build/srclib/apr-util/configure: build/configure
	mkdir -p build/srclib/apr-util
	(cd build/srclib && tar -x --strip-components 1 -f ../../$(TARBALL_APR_UTIL) -C apr-util)

build/configure: $(TARBALLS)
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../$(TARBALL_HTTPD))

.PHONY: images
images: images/data.iso

images/data.iso: images/data/www/* images/data/conf/*
	$(RUMPRUN_GENISOIMAGE) -o images/data.iso images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/data.iso

.PHONY: distclean
distclean: clean
	rm -rf build

include ../Makefile.deps
