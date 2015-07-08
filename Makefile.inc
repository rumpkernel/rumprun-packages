#
# Makefile.inc should be included first thing by each package-specific Makefile.
#

-include ../config.mk

# If the user has not setup config.mk, complain.
ifeq ($(RUMPRUN_TOOLCHAIN_TUPLE),)
$(error Please set RUMPRUN_TOOLCHAIN_TUPLE in the top-level config.mk)
endif

# Set convenience variables for use by package-specific Makefiles.
RUMPRUN_CC=$(RUMPRUN_TOOLCHAIN_TUPLE)-gcc
RUMPRUN_CXX=$(RUMPRUN_TOOLCHAIN_TUPLE)-g++
RUMPRUN_CMAKE_TOOLCHAIN=$(dir$(shell which $(RUMPRUN_CC)))$(RUMPRUN_TOOLCHAIN_TUPLE)-toolchain.cmake
