include ../Makefile.inc
UPSTREAM=http://download.redis.io/releases/redis-3.0.6.tar.gz
TARBALL=$(notdir $(UPSTREAM))
PERSISTENCE_SIZE=2048
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/redis-server images/data.iso images/datapers.img

cache: bin/redis-server images/data.iso

bin/redis-server: build/redis-server
	mkdir -p bin
	cp build/src/redis-server bin/

build/redis-server: build/Makefile
	$(MAKE) -C build MALLOC=libc redis-server

build/Makefile: dl/${TARBALL}
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/${TARBALL})

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

images/data.iso: images/data/conf/*
	$(RUMPRUN_GENISOIMAGE) -o $@ images/data

images/datapers.img:
	dd if=/dev/zero of=$@ bs=1024k seek=$(PERSISTENCE_SIZE) count=0
	mkfs.ext2 -F -q $@

.PHONY: clean
clean:	clean/build clean/bin
	
clean/build:
	rm -rf build

clean/bin:
	rm -rf bin
	rm -f images/data.iso
	rm -f images/datapers.iso
