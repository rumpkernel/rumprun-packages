include ../Makefile.inc
UPSTREAM=http://github.com/lloyd/yajl/tarball/2.1.0
TARBALL=lloyd-yajl-2.1.0-0-ga0ecdde.tar.gz

all: bin/libyajl

bin/libyajl: build/objs/libyajl

build/objs/libyajl: build/Makefile
	$(MAKE) -C build/build
	$(MAKE) -C build/build install

build/Makefile: build/CMakeLists.txt
	mkdir -p build/build
	(cd build/build &&  \
		cmake -DCMAKE_TOOLCHAIN_FILE=$(RUMPRUN_CMAKE_TOOLCHAIN_FILE) \
		-DCMAKE_INSTALL_PREFIX="$(RUMPRUN_PKGS_DIR)" \
		..;)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/CMakeLists.txt: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	-$(MAKE) -C build/build clean

.PHONY: distclean
distclean:
	rm -rf build

