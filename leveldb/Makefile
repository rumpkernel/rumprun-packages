include ../Makefile.inc
UPSTREAM=https://github.com/google/leveldb/archive/v1.18.tar.gz
INSTALL_PREFIX ?= $(shell pwd)
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/db_bench 

bin/db_bench: build/db_bench
	$(MAKE) -C build install PREFIX=${INSTALL_PREFIX}

build/db_bench: build/stamp_patch
	$(MAKE) -C build TARGET_OS=NetBSD

build/stamp_patch: build/Makefile patches/*
	../scripts/apply-patches.sh build/ patches/*
	touch $@

build/Makefile:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/leveldb.tar.gz
	(cd build && tar -xz --strip-components 1 -f leveldb.tar.gz)

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
