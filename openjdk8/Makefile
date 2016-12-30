include ../Makefile.inc
JRE_DIR=$(wildcard build/javadist/jvm/openjdk-1.8.0-internal*/jre)
JAVA_BIN=$(wildcard build/javadist/bin/java)
SUB_MODULES=build/corba build/jaxp build/jaxws build/langtools build/jdk build/hotspot build/nashorn

OPENJDK_HG=http://hg.openjdk.java.net/bsd-port/jdk8
JDK8_VER=5fef56ef47c7
CORBA_VER=56b133772ec1
HOTSPOT_VER=d208cc11392a
JAXP_VER=1f032000ff4b
JAXWS_VER=81f2d81a48d7
JDK_VER=18007ac912e3
LANGTOOLS_VER=357800aef413
NASHORN_VER=4195ebe2576e

export COMPILER_WARNINGS_FATAL=false

all: $(RUMPRUN_PKGS_DIR)/lib/libffi.a bin/java images/jre.iso images/jar.ffs

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libffi.a
$(RUMPRUN_PKGS_DIR)/lib/libffi.a:
	$(MAKE) -C ../libffi

bin/java: build/javadist/bin/java
	mkdir -p bin
	cp $(JAVA_BIN) $@

build/javadist/bin/java: build/Makefile
	$(MAKE) -C build JOBS=2
	$(MAKE) -C build install

OPENJDK_CONF_ENV += \
	CC=$(RUMPRUN_CC) \
	CXX=$(RUMPRUN_CXX) \
	LIBFFI_CFLAGS="$(shell pkg-config $(RUMPRUN_PKGS_DIR)/lib/pkgconfig/libffi.pc --cflags)" \
	LIBFFI_LIBS="$(shell pkg-config $(RUMPRUN_PKGS_DIR)/lib/pkgconfig/libffi.pc --libs)" \
	ALT_OBJCOPY=$(RUMPRUN_TOOLCHAIN_TUPLE)-objcopy \

OPENJDK_CONF_OPTS += \
	--prefix=$(shell pwd)/build/javadist \
	--openjdk-target=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--disable-headful \
	--enable-static-build \
	--enable-static-libjli \
	--disable-debug-symbols \
	--with-jvm-variants=zero \
	--with-extra-cflags="-I${RUMPRUN_PKGS_DIR}/include -I${RUMPRUN_SYSROOT}/include \
       	-I$(shell pwd)/build/common/include" \
	--with-extra-cxxflags="-Wno-literal-suffix -Wno-narrowing -I${RUMPRUN_SYSROOT}/include/c++" \
	--without-freetype \
	--without-x

build/Makefile: build/stamp_patch 
	(cd build; $(OPENJDK_CONF_ENV) $(SHELL) ./configure $(OPENJDK_CONF_OPTS))

build/stamp_patch: $(SUB_MODULES) patches/*
	../scripts/apply-patches.sh build/ patches/*
	touch $@

$(SUB_MODULES): build/get_source.sh
	(cd build && $(SHELL) ./get_source.sh \
	    && hg update $(JDK8_VER) \
	    && cd corba && hg update $(CORBA_VER) && cd .. \
	    && cd hotspot && hg update $(HOTSPOT_VER) && cd .. \
	    && cd jaxp && hg update $(JAXP_VER) && cd .. \
	    && cd jaxws && hg update $(JAXWS_VER) && cd .. \
	    && cd jdk && hg update $(JDK_VER) && cd .. \
	    && cd langtools && hg update $(LANGTOOLS_VER) && cd .. \
	    && cd nashorn && hg update $(NASHORN_VER))

build/get_source.sh:
	(mkdir -p build && hg clone $(OPENJDK_HG) build)

images/jre.iso: build/javadist
	mkdir -p images
	$(RUMPRUN_GENISOIMAGE) -o images/jre.iso $(JRE_DIR)/lib
	
jar/HelloWorld.jar:
	mkdir -p jar
	(cd examples; javac HelloWorld.java \
	&& jar cfe ../jar/HelloWorld.jar HelloWorld HelloWorld.class)

images/jar.ffs: jar/HelloWorld.jar
	mkdir -p images
	../mysql/scripts/rumprun-makefs.sh -u 1 -g 1 images/jar.ffs jar

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f examples/HelloWorld.class
	rm -f jar/HelloWorld.jar
	rm -f images/*

.PHONY: distclean
distclean: clean
	rm -rf build

include ../Makefile.deps
