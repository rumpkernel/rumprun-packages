include ../Makefile.inc
UPSTREAM=http://pyyaml.org/download/libyaml/yaml-0.1.5.tar.gz
TARBALL=$(notdir $(UPSTREAM))

LIBYAML_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared


all: bin/libyaml

bin/libyaml: build/objs/libyaml

build/objs/libyaml: build/Makefile
	$(MAKE) -C build
	$(MAKE) -C build install

build/Makefile: build/configure
	(cd build; \
	./configure $(LIBYAML_CONF_OPTS) --host=$(RUMPRUN_TOOLCHAIN_TUPLE);)

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
