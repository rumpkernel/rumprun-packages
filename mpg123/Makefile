include ../Makefile.inc
UPSTREAM=http://downloads.sourceforge.net/project/mpg123/mpg123/1.22.2/mpg123-1.22.2.tar.bz2

all: bin/mpg123

bin/mpg123: build/src/mpg123
	mkdir -p bin
	cp $< $@

build/src/mpg123: build/Makefile
	$(MAKE) -C build

MPG123_CONF_OPTS += \
	--enable-modules=no \
	--enable-static=yes \
	--enable-shared=no \
	--enable-buffer=no \
	--with-default-audio=sun

ifeq (i486-rumprun-netbsdelf,$(RUMPRUN_TOOLCHAIN_TUPLE))
MPG123_CONF_OPTS += --with-cpu=i486
endif

build/Makefile: build/configure
	(cd build; ./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(MPG123_CONF_OPTS))

build/configure:
	mkdir -p build
	../scripts/fetch.sh ${UPSTREAM} build/mpg123.tar.bz2
	(cd build && tar -xj --strip-components 1 -f mpg123.tar.bz2)

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*

.PHONY: distclean
distclean:
	-$(MAKE) -C build distclean
