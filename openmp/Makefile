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
	rm -rf gcc-build
	rm -rf gcc-source

build/openmp:	build/configure
	cd gcc-build; $(MAKE)

build/configure:	build/getsource
	mkdir -p gcc-build
	cd gcc-build; ../gcc-source/libgomp/configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) --disable-multilib --disable-shared
	
build/getsource:	build/gcc-branch
	mkdir -p gcc-source
	sh ./scripts/git_clone.sh $(UPSTREAM) gcc-source $(GCC_BRANCH)
	
build/gcc-branch:
	
#Call Shell Script that determines GCC Version and exports it as gcc_branch variable
	$(eval GCC_BRANCH:=$(shell ./scripts/get_gcc_ver.sh))
	$(if $(GCC_BRANCH),,$(error gcc_branch is not set))

.PHONY: clean
clean:
	rm -rf gcc-source
	rm -rf gcc-build
	rm -rf include
	rm -rf lib
