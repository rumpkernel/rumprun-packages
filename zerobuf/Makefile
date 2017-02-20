include ../Makefile.inc

#Address:https://github.com/HBPVIS/ZeroBuf.git
UPSTREAM=https://github.com/HBPVIS/ZeroBuf.git

all: bin/zerobuf

bin/zerobuf: ZeroBuf/build/zerobuf
	#Copying files to pkgs directory
	(cd ZeroBuf/build && \
	 mkdir -p ../../../pkgs/lib && \
	 cp lib/*.a ../../../pkgs/lib/. && \
	 mkdir -p ../../../pkgs/include && \
	 cp -a include/zerobuf ../../../pkgs/include/zerobuf && \
	 cd .. && cp zerobuf/*.h ../../pkgs/include/zerobuf/.)

ZeroBuf/build/zerobuf: ZeroBuf/build/Makefile
	$(MAKE) -C ZeroBuf/build

ZeroBuf/build/Makefile: build/CMakeLists.txt
	(mkdir -p ZeroBuf/build && \
	 cd ZeroBuf/build && \
	    cmake -DCMAKE_TOOLCHAIN_FILE=$(RUMPRUN_CMAKE_TOOLCHAIN_FILE) \
	          -DENABLE_XSLT=off \
		  -Wno-dev \
		  ..)

build/CMakeLists.txt:
	(git clone $(UPSTREAM))

.PHONY: clean
clean:
	$(MAKE) -C ZeroBuf/build clean
distclean: clean
	rm -rf ZeroBuf
