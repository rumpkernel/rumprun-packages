include ../Makefile.inc
UPSTREAM=https://gcc.gnu.org/pub/libffi/libffi-3.2.1.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/libffi

build/libffi: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

LIBFFI_CONF_OPTS += \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared \
	--with-sysroot=$(RUMPRUN_PKGS_DIR)

build/Makefile: build/stamp_patch
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(LIBFFI_CONF_OPTS);)

build/stamp_patch: build/configure
	../scripts/apply-patches.sh build/ patches/*
	touch $@

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	rm -rf build
