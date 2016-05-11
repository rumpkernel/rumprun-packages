include ../Makefile.inc

UPSTREAM=http://nginx.org/download/nginx-1.8.0.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: libssl $(RUMPRUN_PKGS_DIR)/lib/libpcre.a bin/nginx images

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libpcre.a
$(RUMPRUN_PKGS_DIR)/lib/libpcre.a:
	$(MAKE) -C ../pcre

bin/nginx: build/objs/nginx
	mkdir -p bin
	cp $< $@

build/objs/nginx: build/Makefile
	$(MAKE) -C build

NGINX_CONF_ENV += \
	ngx_force_c_compiler=yes \
	ngx_force_c99_have_variadic_macros=yes \
	ngx_force_gcc_have_variadic_macros=yes \
	ngx_force_gcc_have_atomic=yes \
	ngx_force_have_libatomic=no \
	ngx_force_sys_nerr=100 \
	ngx_force_have_map_anon=yes \
	ngx_force_have_map_devzero=no \
	ngx_force_have_timer_event=yes \
	ngx_force_have_posix_sem=yes

NGINX_CONF_OPTS += \
	--crossbuild=NetBSD \
	--with-cc=$(RUMPRUN_CC) \
	--with-cc-opt="-I $(RUMPRUN_PKGS_DIR)/include" \
	--with-ld-opt="-L $(RUMPRUN_PKGS_DIR)/lib" \
	--prefix=/none \
	--conf-path=/data/conf/nginx.conf \
	--sbin-path=/none \
	--pid-path=/tmp/nginx.pid \
	--lock-path=/tmp/nginx.lock \
	--error-log-path=/tmp/error.log \
	--http-log-path=/tmp/access.log \
	--http-client-body-temp-path=/tmp/client-body \
	--http-proxy-temp-path=/tmp/proxy \
	--http-fastcgi-temp-path=/tmp/fastcgi \
	--http-scgi-temp-path=/tmp/scgi \
	--http-uwsgi-temp-path=/tmp/uwsgi \
	--with-http_ssl_module \
	--with-ipv6 \
	--with-pcre

build/Makefile: build/stamp_patch
	(cd build; $(NGINX_CONF_ENV) ./configure $(NGINX_CONF_OPTS))

build/stamp_patch: build/configure patches/*
	../scripts/apply-patches.sh build/ patches/*
	touch $@

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: images
images: images/data.iso

images/data.iso: images/data/conf/* images/data/www/*
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
