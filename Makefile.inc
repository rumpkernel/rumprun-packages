#
# Makefile.inc should be included first thing by each package-specific Makefile.
#

-include ../config.mk

# If the user has not setup config.mk, complain.
ifeq ($(RUMPRUN_PLATFORM),)
$(error Please set RUMPRUN_PLATFORM in the top-level config.mk)
endif

# Set convenience variables for use by package-specific Makefiles.
RUMPRUN_CC=$(RUMPRUN_PLATFORM)-gcc
RUMPRUN_CXX=$(RUMPRUN_PLATFORM)-g++
RUMPRUN_CMAKE_TOOLCHAIN=$(dir$(shell which $(RUMPRUN_CC)))$(RUMPRUN_PLATFORM)-toolchain.cmake
