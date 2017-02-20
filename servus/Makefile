include ../Makefile.inc

#Address:https://github.com/HBPVIS/Servus.git
UPSTREAM=https://github.com/HBPVIS/Servus.git

all: bin/servus

bin/servus: Servus/build/servus
	#
	#Copying files to pkgs directory 
	#
	(cd Servus/build && \
	 mkdir -p ../../../pkgs/lib && \
	 cp lib/*.a ../../../pkgs/lib/. && \
	 mkdir -p ../../../pkgs/include && \
	 cp -a include/servus ../../../pkgs/include/servus && \
	 cd .. && cp -R servus/ ../../pkgs/include/.)

Servus/build/servus: Servus/build/Makefile
	$(MAKE) -C Servus/build

Servus/build/Makefile: build/CMakeLists.txt
	(mkdir -p Servus/build && \
	 cd Servus/build && \
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
	$(MAKE) -C Servus/build clean
distclean: clean
	rm -rf Servus
