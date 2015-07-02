UPSTREAM=http://de1.php.net/get/php-5.6.10.tar.bz2/from/this/mirror

HOST=$(subst -cc,,$(notdir $(CC)))

all: bin/php-cgi images

bin/php-cgi: build/sapi/cgi/php-cgi
	mkdir -p bin
	cp $< $@

build/sapi/cgi/php-cgi: build/Makefile
	$(MAKE) -C build sapi/cgi/php-cgi

build/Makefile: build/configure
	(cd build && ./configure --host=$(HOST) --disable-shared --disable-all)

build/configure:
	mkdir -p build
	../scripts/fetch.sh $(UPSTREAM) build/php.tar.bz2
	(cd build && tar -xj --strip-components 1 -f php.tar.bz2)

.PHONY: images
images: images/stubetc.iso images/data.iso

images/stubetc.iso: ../stubetc/etc/*
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

images/data.iso: images/data/conf/* images/data/www/* images/data/www/static/*
	genisoimage -l -r -o images/data.iso images/data

.PHONY: clean
clean:
	$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/stubetc.iso images/data.iso
