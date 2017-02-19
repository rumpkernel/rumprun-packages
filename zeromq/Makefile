include ../Makefile.inc
#Address:https://github.com/zeromq/libzmq.git
UPSTREAM=https://github.com/zeromq/libzmq.git

CC=$(RUMPRUN_CC)
CXX=$(RUMPRUN_CXX)
export CC CXX

#All - start here
all: bin/zmq

ZMQMSG_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--disable-shared

# rumprun-packages/pkgs/lib/libzmq.a
bin/zmq: build/zmq

build/zmq: build/Makefile
	$(MAKE) -C build/libzmq
	$(MAKE) install -C build/libzmq

build/Makefile: build/configure
	(cd build/libzmq && \
		./autogen.sh && \
		./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(ZMQMSG_CONF_OPTS);)

build/configure:
	mkdir -p build
	(cd build && \
		git clone $(UPSTREAM))

.PHONY: clean
clean:
	-$(MAKE) -C build clean

.PHONY: distclean
distclean: clean
	rm -rf build
	rm -rf .deps

