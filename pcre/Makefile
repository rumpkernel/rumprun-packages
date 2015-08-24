include ../Makefile.inc
UPSTREAM=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: bin/pcre

bin/pcre: build/libpcre.la

build/libpcre.la: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

PCRE_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(PCRE_CONF_OPTS);)

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

