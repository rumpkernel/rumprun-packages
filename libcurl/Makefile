include ../Makefile.inc
UPSTREAM=http://curl.haxx.se/download/curl-7.46.0.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: bin/libcurl

bin/libcurl: build/objs/libcurl

build/objs/libcurl: build/Makefile
	LIBS="-lssl -lcrypto"
	$(MAKE) -C build
	$(MAKE) install -C build

libcurl_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--with-ssl \
	--with-zlib \
	--enable-shared=no
	
build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(libcurl_CONF_OPTS);)

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

