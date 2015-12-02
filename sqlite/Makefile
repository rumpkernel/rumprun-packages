include ../Makefile.inc
UPSTREAM=https://www.sqlite.org/2015/sqlite-autoconf-3090200.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: bin/sqlite3

bin/sqlite3: build/libsqlite3.a

build/libsqlite3.a: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

SQLITE_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(SQLITE_CONF_OPTS);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	-$(MAKE) -C build clean

.PHONY: distclean
distclean: clean
	rm -rf build
	rm -rf .deps

