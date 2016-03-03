include ../Makefile.inc

UPSTREAM=http://de1.php.net/get/php-7.0.3.tar.bz2/from/this/mirror
TARBALL=php.tar.bz2

# "Minimal" build.
all: CONFIGURE_OPTS := --disable-all --enable-cli

all: bin/php-cgi bin/php images

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
images: images/data.iso

images/data.iso: images/data/www/* images/data/www/static/*
	$(RUMPRUN_GENISOIMAGE) -o images/data.iso images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/data.iso

.PHONY: distclean
distclean: clean
	rm -rf build/
