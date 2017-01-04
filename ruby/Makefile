include ../Makefile.inc
UPSTREAM=https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz
#export CFLAGS="-static"
ifeq ($(shell uname),Darwin)
ISO_OPTIONS=-joliet
else
ISO_OPTIONS=
endif

all: bin/ruby images/usr.iso

bin/ruby: build/rubydist/usr/bin/ruby
	mkdir -p bin
	cp $< $@

build/rubydist/usr/bin/ruby: build/Makefile
	(cd build; \
	./configure --enable-static --disable-shared --host=$(RUMPRUN_TOOLCHAIN_TUPLE) --with-static-linked-ext --prefix=/usr --disable-install-doc --with-out-ext=-test* LDFLAGS="-Bstatic -static"; \
	$(MAKE) --debug; make install DESTDIR=rubydist)

build/Makefile:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/ruby.tar.gz
	(cd build && tar -xz --strip-components 1 -f ruby.tar.gz)
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)

images/usr.iso: bin/ruby
	mkdir -p images
	$(RUMPRUN_GENISOIMAGE) ${ISO_OPTIONS} -o images/usr.iso build/rubydist/

images/examples.iso:
	cd examples && bundle install --path=gems
	$(RUMPRUN_GENISOIMAGE) ${ISO_OPTIONS} -o images/examples.iso examples/
	
.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/*
