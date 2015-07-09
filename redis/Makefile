include ../Makefile.inc
UPSTREAM=http://download.redis.io/releases/redis-3.0.2.tar.gz
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/redis-server images/data.iso

bin/redis-server: build/redis-server
	mkdir -p bin
	cp build/src/redis-server bin/

build/redis-server: build/Makefile
	$(MAKE) -C build MALLOC=libc redis-server

build/Makefile:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/redis.tar.gz
	(cd build && tar -xz --strip-components 1 -f redis.tar.gz)

images/data.iso: images/data/conf/*
	genisoimage -l -r -o $@ images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/data.iso
