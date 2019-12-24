include ../Makefile.inc
UPSTREAM=http://luajit.org/download/LuaJIT-2.0.4.tar.gz
TARBALL=$(notdir $(UPSTREAM))
PERSISTENCE_SIZE=2048
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

LUAJIT_CONF_OPTS += \
	PREFIX=$(RUMPRUN_PKGS_DIR)

all: bin/luajit

bin/luajit: build/luajit

build/luajit: build/Makefile
	$(MAKE) $(LUAJIT_CONF_OPTS) -C build
	$(MAKE) $(LUAJIT_CONF_OPTS) -C build install

build/Makefile: dl/${TARBALL}
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/${TARBALL})

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

.PHONY: clean
clean:
	-$(MAKE) -C build clean

.PHONY: distclean
distclean: clean
	rm -rf build
