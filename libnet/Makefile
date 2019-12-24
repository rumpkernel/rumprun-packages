include ../Makefile.inc
UPSTREAM=http://http.debian.net/debian/pool/main/libn/libnet/libnet_1.1.6+dfsg.orig.tar.gz
TARBALL=$(notdir $(UPSTREAM))

LIBNET_CONF_OPTS += \
	--disable-shared \
	--prefix=$(RUMPRUN_PKGS_DIR) \

all: bin/libnet

bin/libnet: build/Makefile
	$(MAKE) -C build
	$(MAKE) -C build install

build/Makefile: build/configure
	(cd build; \
	./configure $(LIBNET_CONF_OPTS) --host=$(RUMPRUN_TOOLCHAIN_TUPLE);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	-$(MAKE) -C build clean

.PHONY: distclean
distclean: clean
	rm -rf build
