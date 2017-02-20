include ../Makefile.inc

#Address:https://github.com/HBPVIS/Servus.git
UPSTREAM=https://github.com/HBPVIS/Servus.git

all: bin/servus

bin/servus: Servus/build/servus
	#Copying files to pkgs directory 
	(cd Servus/build && \
	 mkdir -p ../../../pkgs/lib && \
	 cp lib/*.a ../../../pkgs/lib/. && \
	 mkdir -p ../../../pkgs/include && \
	 cp -a include/servus ../../../pkgs/include/servus && \
	 cd .. && cp servus/*.h ../../pkgs/include/servus/.)

Servus/build/servus: Servus/build/Makefile
	$(MAKE) -C Servus/build

Servus/build/Makefile: build/CMakeLists.txt
	(mkdir -p Servus/build && \
	 cd Servus/build && \
	    cmake -DCMAKE_TOOLCHAIN_FILE=$(RUMPRUN_CMAKE_TOOLCHAIN_FILE) \
	          -DENABLE_XSLT=off \
		  -Wno-dev \
		  ..)

build/CMakeLists.txt:
	(git clone $(UPSTREAM))

.PHONY: clean
clean:
	$(MAKE) -C Servus/build clean
distclean: clean
	rm -rf Servus
