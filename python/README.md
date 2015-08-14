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

The build script requires `genisoimage` to create the `scrubetc.iso` and `python.iso` images.
The example program requires `cython` to compile the python script, and autotools to update the configure script.

Run `make` from the python package directory:

```
cd rumprun-packages/python
make
```

You will notice several errors and warnings fly by during the static module compilation. These
won't be a problem for the example application (and many others). If they are important for your
application, you'll find out soon enough.


Examples
========

The make process will get you as far as an hw_generic baked binary `examples/hw.bin`.
After that, you have to decide how you want to run the rumpkernel.

To run the rumpkernel using KVM, the following will work:

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
