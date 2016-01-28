include ../Makefile.inc
UPSTREAM=http://download.zeromq.org/zeromq-4.1.4.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: bin/zeromq4

bin/zeromq4: build/libzmq.a

build/libzmq.a: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

ZEROMQ_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(ZEROMQ_CONF_OPTS);)

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

