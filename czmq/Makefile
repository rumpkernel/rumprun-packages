include ../Makefile.inc
UPSTREAM=https://github.com/zeromq/czmq/archive/v3.0.2.tar.gz
TARBALL=$(notdir $(UPSTREAM))
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/czmq

bin/czmq: build/libczmq.a

build/libczmq.a: build/Makefile
	$(MAKE) -C build  MALLOC=libc
	$(MAKE) install -C build

CZMQ_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

build/Makefile: build/configure
	(cd build; \
	./autogen.sh; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(CZMQ_CONF_OPTS);)

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
	rm -rf .deps

