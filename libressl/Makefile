include ../Makefile.inc
# ftp.openbsd.org doesn't support https.  ironic?
UPSTREAM=http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.4.2.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/libressl

build/libressl: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

liblibressl_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--enable-shared=no
	
build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(liblibressl_CONF_OPTS);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	rm -rf build
