include ../Makefile.inc
UPSTREAM=http://openvswitch.org/releases/openvswitch-2.6.1.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: libssl build/ovs images

build/ovs: build/patched_ovs
	$(MAKE) -C build
	$(MAKE) install -C build

CROSS_DIR=$(abspath ./build-cross)

ovs_CONF_OPTS += \
	--prefix=$(CROSS_DIR)/ovs/

build/patched_ovs: build/Makefile
	( cd build; patch -p0 < ../patches/fork-umake-permission.patch )
	( cd build; patch -p0 < ../patches/undefine-netdev.patch )

build/Makefile: build/source
	mkdir -p $(CROSS_DIR)
	(cd build; \
	./boot.sh; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) ${ovs_CONF_OPTS};)

build/source: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

.PHONY: images
images: images/ovs.ffs

images/ovs.ffs :$(CROSS_DIR)/ovs/
	(../mysql/scripts/rumprun-makefs.sh -u 1 -g 1 images/ovsdb.ffs ${CROSS_DIR}/ovs)
	(../mysql/scripts/rumprun-makefs.sh -u 1 -g 1 images/ovs-vswitchd.ffs ${CROSS_DIR}/ovs)


.PHONY: clean
clean: clean
	rm -rf build
	rm -rf $(CROSS_DIR)
	rm -f images/*.ffs
	rm -rf *.bin

include ../Makefile.deps
