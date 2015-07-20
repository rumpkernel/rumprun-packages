include ../Makefile.inc
UPSTREAM=ftp://xmlsoft.org/libxml2/libxml2-2.7.2.tar.gz

all: bin/libxml2

bin/libxml2: build/objs/libxml2

build/objs/libxml2: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

LIBXML2_CONF_OPTS += \
	--with-html-subdir=libxml2 \
	--with-gnu-ld \
	--without-threads \
	--without-python \
	--without-lzma \
	--without-iconv \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(LIBXML2_CONF_OPTS);)

build/configure:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/libxml2-2.7.2.tar.gz
	(cd build && tar -zxv --strip-components 1 -f libxml2-2.7.2.tar.gz)

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -rf build

