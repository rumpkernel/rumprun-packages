include ../Makefile.inc
UPSTREAM=http://www.openssl.org/source/openssl-1.0.1t.tar.gz
TARBALL=$(notdir $(UPSTREAM))

# BSD-generic64, BSD-x86, BSD-generic32 or something else?
# use "openssl/Configure LIST" to get the complete list
#
# Dont know if we can use linux-armv4 or android-armv7 for arm platform?
# So, lets stick with BSD-generic32 in the meantime
ifneq (,$(findstring x86_64,$(RUMPRUN_TOOLCHAIN_TUPLE)))
	TARGET=BSD-x86_64
else ifneq (,$(findstring x86,$(RUMPRUN_TOOLCHAIN_TUPLE)))
	TARGET=BSD-x86
else
	TARGET=BSD-generic32
endif

CC=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc
RANLIB=$(RUMPRUN_TOOLCHAIN_TUPLE)-ranlib
LD=$(RUMPRUN_TOOLCHAIN_TUPLE)-ld
MAKEDEPPROG=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc

all: build/openssl

build/openssl: build/Makefile
	$(MAKE) CC=$(CC) RANLIB=$(RANLIB) LD=$(LD) MAKEDEPPROG=$(MAKEDEPPROG) -C build depend
	$(MAKE) CC=$(CC) RANLIB=$(RANLIB) LD=$(LD) MAKEDEPPROG=$(MAKEDEPPROG) -C build
	$(MAKE) install -C build

# The current set of options are not well thought out though somewhat
# inspired from what I've worked with earlier. This is something which needs
# to be thought out and aligned with its larger purpose and be changed
# accordingly. I believe there would be intellectual property attached
# to some of the options as well.
libopenssl_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--openssldir=$(RUMPRUN_PKGS_DIR)/bin \
	zlib enable-cms enable-tlsext enable-camellia enable-seed \
	enable-md2 enable-rfc3779 no-idea \
	no-mdc2 no-rc5 \
	no-shared $(TARGET)

build/Makefile: build/Configure
	(cd build; \
	./Configure \
		$(libopenssl_CONF_OPTS);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/Configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	rm -rf build
