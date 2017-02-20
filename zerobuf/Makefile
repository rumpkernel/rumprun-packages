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
	 cd .. && cp -R zerobuf ../../pkgs/include/.)

ZeroBuf/build/zerobuf: ZeroBuf/build/Makefile
	$(MAKE) -C ZeroBuf/build

ZeroBuf/build/Makefile: build/CMakeLists.txt
	(mkdir -p ZeroBuf/build && \
	 cd ZeroBuf/build && \
	 cmake -DCMAKE_TOOLCHAIN_FILE=$(RUMPRUN_CMAKE_TOOLCHAIN_FILE) -Wno-dev .. && \
	 pwd && cd .. && pwd && \
	 sed -i "/set(COMMON_CXX11_FEATURES/c\#set(COMMON_CXX11_FEATURES" \
	 CMake/common/CommonCompiler.cmake && \
	 sed -i "/  cxx_alias_templates cxx_nullptr cxx_override cxx_final)/c\#  cxx_alias_templates cxx_nullptr cxx_override cxx_final)" \
	 CMake/common/CommonCompiler.cmake && \
	 sed -i "/set(COMMON_LIBRARY_TYPE SHARED CACHE STRING/c\set(COMMON_LIBRARY_TYPE STATIC CACHE STRING" \
	 CMake/common/CommonLibrary.cmake)

build/CMakeLists.txt:
	(git clone $(UPSTREAM))

.PHONY: clean
clean:
	$(MAKE) -C ZeroBuf/build clean
distclean: clean
	rm -rf ZeroBuf
