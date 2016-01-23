include ../Makefile.inc
VERSION=3.0.6
TARBALL=redis-${VERSION}.tar.gz
UPSTREAM=http://download.redis.io/releases/${TARBALL}
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/redis-server images/data.iso

bin/redis-server: build/redis-server
	mkdir -p bin
	cp build/src/redis-server bin/

build/redis-server: build/Makefile
	$(MAKE) -C build MALLOC=libc redis-server

build/Makefile: build/${TARBALL}
	(cd build && tar -xz --strip-components 1 -f ${TARBALL})

build/${TARBALL}:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/${TARBALL}

images/data.iso: images/data/conf/*
	$(RUMPRUN_GENISOIMAGE) -o $@ images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/data.iso
