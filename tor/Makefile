include ../Makefile.inc

UPSTREAM=https://www.torproject.org/dist/tor-0.2.7.6.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: $(RUMPRUN_PKGS_DIR)/lib/libevent.a build/tor

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
	--with-openssl-dir=$(RUMPRUN_SYSROOT) \
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
	dd if=/dev/zero of=tor.img bs=1M count=150
	newfs_ext2fs tor.img 2>/dev/null || mkfs.ext2 -F tor.img 2>/dev/null
	sudo mount -o loop tor.img /mnt
	cp build/src/config/geoip* image/conf
	tar -C ./image -czf - . | sudo tar -C /mnt -xvzf -
	sudo umount /mnt

.PHONY: clean
clean:  
	-$(MAKE) -C build clean
        
.PHONY: distclean
distclean: clean
	rm -rf dl
	rm -rf build
	rm -f tor.img
