include ../Makefile.inc
UPSTREAM=http://download.redis.io/releases/redis-3.0.6.tar.gz
PERSISTENCE_SIZE=2048
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/redis-server images/data.iso

aof: all images/datapers.iso

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
	$(RUMPRUN_GENISOIMAGE) -o $@ images/data

images/datapers.iso:
	dd if=/dev/zero of=$@ bs=1024k seek=$(PERSISTENCE_SIZE) count=0
	mkfs.ext2 -q images/datapers.iso

.PHONY: clean
clean:	clean/build clean/bin
	
clean/build:
	rm -rf build

clean/bin:
	rm -rf bin
	rm -f images/data.iso
	rm -f images/datapers.iso
