Overview
========

Using the following instructions, you will cross-compile python 3.4.3
for rumprun, compile a python program to C using `cython` and launch
the result as a rumprun guest.


Patches
=======

The build process will apply the patches required for cross-compilation support
and a static Python build. Patches are found in the `patches/` directory.

The patch for a static Python build will support many modules out of the box,
but not everything. If you have an ImportError while trying to import a module
you feel should exist, please examine the `build/Modules/Setup` file to make
sure it is compiled into Python.


Instructions
============

Run this `make` from a user account, *not the root account*. At the end of the
Python installation, the build will attempt to install packages in `/usr/lib/python3.4/site-packages/`
even though the install prefix doesn't point there.

The build script requires `genisoimage` to create the `stubetc.iso` and `python.iso` images.
The example program requires `cython` to compile the python script, and autotools to update the configure script.

Run `make` from the python package directory:

```
cd rumprun-packages/python
make
```

Errors
======

This build process will return clean ($?==0). However there are some errors that you will notice. One of
those errors is:

```
/usr/include/x86_64-linux-gnu/sys/cdefs.h:23:23: fatal error: features.h: No such file or directory
```

This means you are running on Debian and the build system added /usr/include/<platform tuple> to your
include path. cdefs.h is searching the netbsd target include dir for features.h, and it simply won't
find it. If we fix this problem, you will only run into linking errors because extensions just don't
seem to play well with cross compilation. Not to worry, these extensions will be statically linked
in your Unikernel anyway. The example will show this.

So this error remains because it is faster to fail at compile time than at linking time.

Another error happens while linking the Unikernel:

```
warning: RC5 is a patented algorithm; link against libcrypto_rc5
```

This is, of course, dependent on your crypto library. The warning is to be expected.


Examples
========

In order to run a Python program, you will need to use `cython` to compile one module. Cython
will provide a `main` function that will embed the python interpreter. This module can then import
and run pure python code.

```
cython --embed -v -3 -Werror -o examples/hw.c examples/hw.py
```

Next you need to compile the cython generated C file using the rumprun cross compiler. Be sure
to link any libraries required for the static modules you have built. When using crypto, you
may see some link errors related to rc5. This doesn't affect the example.

```
x86_64-rumprun-netbsd-gcc examples/hw.c \
	-o examples/hw \
	-Ibuild/pythondist/include/python3.4m \
	-Lbuild/pythondist/lib \
	-lpython3.4m -lutil -lm -lz -lssl -lcrypto
```

Now you've got a unikernel image. You just need to bake it. We'll use the hw_generic since
we don't have any additional needs.

```
rumpbake hw_generic examples/hw.bin examples/hw
```

You are now ready to run your first Python unikernel. To run the rumpkernel using KVM, the following will work:

```
rumprun kvm -i \
   -b images/python.iso,/python/lib/python3.4 \
   -b images/stubetc.iso,/etc \
   -e PYTHONHOME=/python \
   examples/hw.bin
```

You will have to replace `kvm` with `xen` to run under Xen.

You should see the `Welcome to rumprun` text printed to your screen. A few other modules
are imported in the test script simply to verify that they exist.
