#
# CMake Toolchain file suitable for cross-compiling MySQL on rumprun-xen
#

SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_C_COMPILER rumprun-xen-cc)
SET(CMAKE_CXX_COMPILER rumprun-xen-c++)
# Must be set in environment and point to rumprun-xen/rump directory
SET(CMAKE_FIND_ROOT_PATH "${RUMP_ROOT}")
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Not normally needed in a toolchain file; required for CMake to find symbols
# in libm (see the tests for log2, rint)
SET(CMAKE_REQUIRED_LIBRARIES m)
# There is no test I can find in the MySQL CMake code for this; yet it needs to
# be defined otherwise in_addr_t gets redefined for each source file. Possibly
# left over from the days of an autoconf build?
ADD_DEFINITIONS("-DHAVE_IN_ADDR_T=1")
