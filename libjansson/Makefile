include ../Makefile.inc
UPSTREAM=http://www.digip.org/jansson/releases/jansson-2.7.tar.gz
TARBALL=$(notdir $(UPSTREAM))

LIBJANSSON_CONF_OPTS += \
	--disable-shared \
	--disable-urandom \
	--disable-windows-cryptoapi \
	--prefix=$(RUMPRUN_PKGS_DIR) \

all: bin/libjansson

bin/libjansson: build/Makefile
	$(MAKE) -C build
	$(MAKE) -C build install

build/Makefile: build/configure
	(cd build; \
	./configure $(LIBJANSSON_CONF_OPTS) --host=$(RUMPRUN_TOOLCHAIN_TUPLE);)

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
