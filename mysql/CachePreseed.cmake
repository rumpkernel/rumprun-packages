#
# CMake cache pre-seeds for MySQL build.
#

# Provide result of TRY_RUN() test.
SET( HAVE_LLVM_LIBCPP_EXITCODE 
     "1"
     CACHE STRING "Result from TRY_RUN" FORCE)

# Need to force this as it is provided by libc headers but not present as a
# plain symbol in libc. If not set MySQL helpfully provides its own
# implementation which conflicts with ours.
SET( HAVE_SIGWAIT
     "1"
     CACHE STRING "Have sigwait()" FORCE)

# Don't try to use times(2) in my_timer routines.
SET( HAVE_TIMES
     "0"
     CACHE STRING "Have times()" FORCE)

# Disable pthread_attr_setstacksize(), not working yet.
SET( HAVE_PTHREAD_ATTR_SETSTACKSIZE
     "0"
     CACHE STRING "Have pthread_attr_setstacksize()" FORCE)

# Forcibly enable IPv6 support. The build checks for this fail for some
# as-yet-undebugged reason.
SET( HAVE_IPV6
     "1"
     CACHE STRING "IPv6, dammit" FORCE)

# rint() is not detected correctly due to CMake tests not linking -lm.
# Could use SET(CMAKE_REQUIRED_LIBRARIES m), but that would need a custom
# toolchain file.
SET( HAVE_RINT
     "1"
     CACHE STRING "Have rint()" FORCE)
