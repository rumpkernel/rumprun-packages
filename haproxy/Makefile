include ../Makefile.inc

UPSTREAM=http://www.haproxy.org/download/1.6/src/haproxy-1.6.4.tar.gz
TARBALL=$(notdir $(UPSTREAM))

HAPROXY_BIN=build/haproxy
ISO=conf.iso
HAPROXY_CONF += PCRE_LIB=$(RUMPRUN_PKGS_DIR)/lib PCRE_INC=$(RUMPRUN_PKGS_DIR)/include USE_PCRE=1 USE_PCRE_JIT=1

all: $(RUMPRUN_PKGS_DIR)/lib/libpcre.a $(HAPROXY_BIN)

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libpcre.a
$(RUMPRUN_PKGS_DIR)/lib/libpcre.a:
	$(MAKE) -C ../pcre

$(HAPROXY_BIN): untar
	$(MAKE) -C build TARGET=netbsd CC=$(RUMPRUN_CC) $(HAPROXY_CONF)

untar: dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xz --strip-components 1 -f ../dl/$(TARBALL))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)


.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f images/$(ISO)

.PHONY: bake_hw_generic
bake_hw_generic: all
	rumprun-bake hw_generic $(HAPROXY_BIN).bin $(HAPROXY_BIN)

images/$(ISO) :
	$(RUMPRUN_GENISOIMAGE) -o images/$(ISO) images/conf

.PHONY: run
run: all bake_hw_generic images/$(ISO)
	rumprun qemu -I 'qnet0,vioif,-net user' -g '-redir tcp:8080::1936' -W qnet0,inet,dhcp -i -b images/conf.iso,/conf -- $(HAPROXY_BIN).bin -f /conf/haproxy.conf

.PHONY: distclean
distclean: clean
	rm -rf build
