include ../Makefile.inc

#
# Cross-build script for MySQL on rumprun-xen
#

UPSTREAM=http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.29.tar.gz
TARBALL=$(notdir $(UPSTREAM))
PACKAGE_DIR=$(abspath .)

all: mysql images

mysql: build/mysql_cross_build_stamp

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh $(UPSTREAM) dl/$(TARBALL)

#
# 1. Extract mysql distribution tarball
#
BUILD_DIR=$(abspath build/mysql)
build/mysql_extract_stamp: dl/$(TARBALL)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip=1 -xzf $<
	touch $@

#
# 2. Patches:
#
# CMakeLists.txt - there is no way to disable MySQL use of libreadline and we
# don't need it as we are only building the server.
#
# my_global.h - broken logic tries to define __func__ even though this is
# already provided.
#
# sql_table.cc - fixes a bug introducted in 5.6.24 which breaks the build when
# the partition storage engine is disabled.
#
build/mysql_patch_stamp: patches/* build/mysql_extract_stamp
	( cd $(BUILD_DIR); patch -p0 < ../../patches/CMakeLists.txt.patch )
	( cd $(BUILD_DIR); patch -p0 < ../../patches/my_global.h.patch )
	( cd $(BUILD_DIR); patch -p0 < ../../patches/sql_table.cc.patch )
	touch $@

#
# 3. Build native binaries used by cross-build and bootstrap.
#
NATIVE_DIR=$(abspath $(BUILD_DIR)/build-native)
build/mysql_native_stamp: build/mysql_patch_stamp
	mkdir -p $(NATIVE_DIR)
	cd $(NATIVE_DIR) && cmake \
	    -DWITH_SSL=bundled \
	    -DWITH_ZLIB=bundled \
	    -DDISABLE_SHARED=ON \
	    -DFEATURE_SET=small \
	    -DWITHOUT_PERFSCHEMA_STORAGE_ENGINE=1 \
	    ..
	$(MAKE) -C $(NATIVE_DIR)/sql gen_lex_hash gen_lex_token
	$(MAKE) -C $(NATIVE_DIR)/scripts
	$(MAKE) -C $(NATIVE_DIR)/extra
	$(MAKE) -C $(NATIVE_DIR) mysqld
	mkdir -p $(NATIVE_DIR)/bin
	cp $(NATIVE_DIR)/sql/gen_lex_hash \
	    $(NATIVE_DIR)/sql/gen_lex_token \
	    $(NATIVE_DIR)/scripts/comp_sql \
	    $(NATIVE_DIR)/extra/comp_err \
	    $(NATIVE_DIR)/bin/
	mkdir -p bin
	cp $(NATIVE_DIR)/sql/mysqld bin/mysqld-bootstrap
	touch $@

#
# 4. Cross-build mysqld (CMake step)
#
CROSS_DIR=$(abspath $(BUILD_DIR)/build-cross)
build/mysql_cross_cmake_stamp: build/mysql_native_stamp
	mkdir -p $(CROSS_DIR)
	cd $(CROSS_DIR) && cmake \
	    -C $(PACKAGE_DIR)/CachePreseed.cmake \
	    -DCMAKE_TOOLCHAIN_FILE=$(RUMPRUN_CMAKE_TOOLCHAIN_FILE) \
	    -DSTACK_DIRECTION=-1 \
	    -DDISABLE_SHARED=ON \
	    -DWITH_ZLIB=system \
	    -DWITH_SSL=system \
	    -DFEATURE_SET=small \
	    -DWITHOUT_PERFSCHEMA_STORAGE_ENGINE=1 \
	    ..
# my_net.h insists on redefining in_addr_t, and nothing in the CMake build
# files sets HAVE_IN_ADDR_T. TODO: Report this upstream.
	echo '#define HAVE_IN_ADDR_T 1' >> $(CROSS_DIR)/include/config.h
	echo '#define HAVE_IN_ADDR_T 1' >> $(CROSS_DIR)/include/my_config.h
	touch $@

#
# 5. Cross-build mysqld (build step)
#
build/mysql_cross_build_stamp: build/mysql_cross_cmake_stamp
	export PATH=$(NATIVE_DIR)/bin:$$PATH; \
	$(MAKE) -C $(CROSS_DIR) mysqld
	mkdir -p bin
	cp $(CROSS_DIR)/sql/mysqld bin/mysqld
	touch $@

#
# 6. Bootstrap MySQL server using the native mysqld.
#
DATA_DIR=$(abspath images/data)
images/data: build/mysql_native_stamp
	mkdir -p $(DATA_DIR)
	scripts/mysql-bootstrap.sh $(DATA_DIR)
	touch $@

#
# Disk images
#
images: images/data.ffs

images/data.ffs: images/data
	scripts/rumprun-makefs.sh -u 1 -g 1 images/data.ffs images/data

#
# Re-link mysqld, used during development
#
.PHONY: relink
relink:
	rm -f $(CROSS_DIR)/sql/mysqld
	rm -f build/mysql_cross_build_stamp
	$(MAKE) mysql
	mkdir -p bin
	cp $(CROSS_DIR)/sql/mysqld bin/mysqld

#
# Force re-build images from scratch, used during development
#
.PHONY: reimage
reimage: clean-images images

.PHONY: clean-images
clean-images:
	rm -rf images/data images/*.iso images/*.ffs

.PHONY: clean
clean: clean-images
	rm -rf build
	rm -rf bin/*
