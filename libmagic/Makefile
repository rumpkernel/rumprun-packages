include ../Makefile.inc
UPSTREAM=ftp://ftp.astron.com/pub/file/file-5.26.tar.gz
TARBALL=$(notdir $(UPSTREAM))
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

LIBMAGIC_CONF_OPTS += \
	--disable-shared \
	--enable-static \
	--prefix=$(RUMPRUN_PKGS_DIR)

all: bin/libmagic

bin/libmagic: build/Makefile
	$(MAKE) -C build install-exec

build/Makefile: build/configure
	(cd build; \
	./configure $(LIBMAGIC_CONF_OPTS) --host=$(RUMPRUN_TOOLCHAIN_TUPLE);)

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
