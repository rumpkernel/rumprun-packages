include ../Makefile.inc
UPSTREAM=https://github.com/gcc-mirror/gcc
CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

all: bin/openmp

bin/openmp:	build/openmp
	mkdir -p include
	cp gcc-build/omp.h include/
	mkdir -p lib
	cp gcc-build/.libs/libgomp.a lib/

build/openmp:	build/configure
	cd gcc-build; $(MAKE)

build/configure:	build/getsource
	mkdir -p gcc-build
	cd gcc-build; ../gcc-source/libgomp/configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) --disable-multilib --disable-shared
	
build/getsource:	build/gcc-branch
	mkdir -p gcc-source
	$(eval RET_CODE=$(shell git clone -b $(GCC_BRANCH) $(UPSTREAM) gcc-source))
	$(if $(RET_CODE)==0,,$(error Clone of Git Repository failed!))
	
build/gcc-branch:
	
#Call Shell Script that determines GCC Version and exports it as gcc_branch variable
	$(eval GCC_BRANCH:=$(shell ./scripts/get_gcc_ver.sh $(CC)))
	$(if $(GCC_BRANCH),,$(error GCC_BRANCH variable is not set!))

.PHONY: clean
clean: clean/sources clean/build

clean/sources:
	rm -rf gcc-source
	rm -rf gcc-build
	
clean/build:
	rm -rf include
	rm -rf lib
