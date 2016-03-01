#!/bin/bash
# Build and install rumprun toolchain from source
RUMPRUN_PLATFORM=${RUMPRUN_PLATFORM:-hw}
RUMPRUN_TOOLCHAIN_TUPLE=${RUMPRUN_TOOLCHAIN_TUPLE:-x86_64-rumprun-netbsd}

git clone https://github.com/rumpkernel/rumprun /tmp/rumprun
(
	cd /tmp/rumprun
	git submodule update --init
	./build-rr.sh -d /usr/local -o ./obj -qq ${PLATFORM} build
	sudo ./build-rr.sh -d /usr/local -o ./obj ${PLATFORM} install
)
echo RUMPRUN_TOOLCHAIN_TUPLE=${RUMPRUN_TOOLCHAIN_TUPLE} >config.mk
