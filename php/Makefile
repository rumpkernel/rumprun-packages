include ../Makefile.inc

UPSTREAM=http://de1.php.net/get/php-5.6.12.tar.bz2/from/this/mirror
TARBALL=php.tar.bz2

# "Kitchen sink" build. Depends on libxml2 being built.
# Fileinfo, iconv and opcache are disabled for now (patches needed).
all: CONFIGURE_OPTS := --with-libxml-dir=$(RUMPRUN_PKGS_DIR) \
        --with-openssl=$(RUMPRUN_SYSROOT) \
        --with-zlib=$(RUMPRUN_SYSROOT) \
        --with-mysql --with-pdo-mysql \
        --disable-fileinfo --disable-opcache --without-iconv

all: $(RUMPRUN_PKGS_DIR)/lib/libxml2.a bin/php-cgi bin/php images

# "Minimal" build.
minimal: CONFIGURE_OPTS := --disable-all --enable-cli

minimal: bin/php-cgi bin/php images

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libxml2.a
$(RUMPRUN_PKGS_DIR)/lib/libxml2.a:
	$(MAKE) -C ../libxml2

bin/php-cgi: build/sapi/cgi/php-cgi
	mkdir -p bin
	cp $< $@

bin/php: build/sapi/cli/php
	mkdir -p bin
	cp $< $@

build/sapi/cgi/php-cgi: build/Makefile
	$(MAKE) -C build sapi/cgi/php-cgi

build/sapi/cli/php: build/Makefile build/sapi/cgi/php-cgi
	$(MAKE) -C build sapi/cli/php

build/Makefile: build/configure
	(cd build && ./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	    --disable-shared $(CONFIGURE_OPTS))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xj --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: images
images: images/stubetc.iso images/data.iso

images/stubetc.iso: ../stubetc/etc/*
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

images/data.iso: images/data/conf/* images/data/www/* images/data/www/static/*
	genisoimage -l -r -o images/data.iso images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/stubetc.iso images/data.iso

.PHONY: distclean
distclean: clean
	rm -rf build/
