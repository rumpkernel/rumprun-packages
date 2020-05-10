include ../Makefile.inc
UPSTREAM=https://github.com/h2o/h2o/archive/v2.0.4.tar.gz

all: libssl bin/h2o images

bin/h2o: build/build/h2o
	mkdir -p bin
	cp $< $@

build/build/h2o: build/build/Makefile
	$(MAKE) -C build/build

build/build/Makefile: build/stamp_patch
	mkdir -p build/build
	(cd build/build && \
	    cmake -DCMAKE_TOOLCHAIN_FILE=${RUMPRUN_CMAKE_TOOLCHAIN_FILE} \
		  -DOPENSSL_INCLUDE_DIR=${RUMPRUN_PKGS_DIR}/include \
		  -DOPENSSL_SSL_LIBRARY=${RUMPRUN_PKGS_DIR}/lib/libssl.a \
		  -DOPENSSL_CRYPTO_LIBRARY=${RUMPRUN_PKGS_DIR}/lib/libcrypto.a \
		  ..)

build/stamp_patch: build/CMakeLists.txt
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)
	touch $@

build/CMakeLists.txt:
	mkdir -p build
	../scripts/fetch.sh $(UPSTREAM) build/h2o.tar.gz
	(cd build && tar -xz --strip-components 1 -f h2o.tar.gz)

.PHONY: images
images: images/data.iso

images/data.iso: images/data/conf/* images/data/www/*
	$(RUMPRUN_GENISOIMAGE) -o images/data.iso images/data

.PHONY: clean
clean:
	$(MAKE) -C build/build clean
	rm -f bin/*
	rm -f images/data.iso
distclean: clean
	rm -rf build/build

include ../Makefile.deps
