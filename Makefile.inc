#
# Makefile.inc should be included first thing by each package-specific Makefile.
#

# Clean up rogue environment variables
unexport CC
unexport CXX
unexport CPP
unexport CFLAGS
unexport CPPFLAGS
unexport CXXFLAGS
unexport LDFLAGS

-include ../config.mk

# If the user has not setup config.mk, complain.
ifeq ($(RUMPRUN_TOOLCHAIN_TUPLE),)
$(error Please set RUMPRUN_TOOLCHAIN_TUPLE in the top-level config.mk)
endif

# Set convenience variables for use by package-specific Makefiles.
RUMPRUN_CC=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc
RUMPRUN_CXX=$(RUMPRUN_TOOLCHAIN_TUPLE)-g++
RUMPRUN_SYSROOT:=$(shell ${RUMPRUN_CC} -print-sysroot)
RUMPRUN_CMAKE_TOOLCHAIN_FILE:=$${RUMPRUN_SYSROOT}/${RUMPRUN_TOOLCHAIN_TUPLE}-toolchain.cmake

RUMPRUN_PKGS_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/pkgs

CPPFLAGS+=-I$(RUMPRUN_PKGS_DIR)/include
LDFLAGS+=-I$(RUMPRUN_PKGS_DIR)/lib
export CPPFLAGS
export LDFLAGS
