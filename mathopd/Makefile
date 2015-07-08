include ../Makefile.inc
UPSTREAM=http://www.mathopd.org/dist/mathopd-1.6b15.tar.gz

all: bin/mathopd images

bin/mathopd: build/src/mathopd
	mkdir -p bin
	cp $< $@

build/src/mathopd: build/src/Makefile
	$(MAKE) -C build/src CC=$(RUMPRUN_CC)

build/src/Makefile:
	mkdir -p build
	../scripts/fetch.sh $(UPSTREAM) build/mathopd.tar.gz
	(cd build && tar -xz --strip-components 1 -f mathopd.tar.gz)

.PHONY: images
images: images/stubetc.iso images/data.iso

images/stubetc.iso: ../stubetc/etc/*
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

images/data.iso: images/data/mathopd.conf images/data/www/*
	genisoimage -l -r -o images/data.iso images/data

.PHONY: clean
clean:
	-$(MAKE) -C build/src clean
	rm -f bin/*
	rm -f images/stubetc.iso images/data.iso
