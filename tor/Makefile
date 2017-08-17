include ../Makefile.inc

UPSTREAM=https://archive.torproject.org/tor-package-archive/tor-0.2.7.6.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: libssl $(RUMPRUN_PKGS_DIR)/lib/libevent.a build/tor

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libevent.a
$(RUMPRUN_PKGS_DIR)/lib/libevent.a:
	$(MAKE) -C ../libevent

build/tor: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

TOR_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-asciidoc \
	--disable-systemd \
	--enable-static-libevent \
	--with-libevent-dir=$(RUMPRUN_PKGS_DIR) \
	--enable-static-openssl \
	--with-openssl-dir=$(RUMPRUN_PKGS_DIR) \
	--enable-static-zlib \
	--with-zlib-dir=$(RUMPRUN_SYSROOT) \
	--enable-static-tor

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(TOR_CONF_OPTS);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: image
image: image/tor.img

image/tor.img:
	cp build/src/config/geoip* image/conf
	genext2fs -b 153600 -i 1024 -m 0 -q -d image tor.img

.PHONY: clean
clean:  
	-$(MAKE) -C build clean
        
.PHONY: distclean
distclean: clean
	rm -rf dl
	rm -rf build
	rm image/conf/geoip*
	rm -f tor.img

include ../Makefile.deps
