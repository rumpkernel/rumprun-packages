Overview
========

Using the following instructions, you will cross-compile python 3.5.2 for rumprun.

Maintainer
----------

* Ryan Day, rday@rumpkernel.org
* Github: @rday


Patches
=======

The build process will apply the patches required for cross-compilation support
and a static Python build. Patches are found in the `patches/` directory.

The patch for a static Python build will support many modules out of the box,
but not everything. If you have an ImportError while trying to import a module
you feel should exist, please examine the `build/Modules/Setup` file to make
sure it is compiled into Python.

[Greenlets](https://greenlet.readthedocs.io/en/latest/) support is built into this
package. Greenlets are like coroutines. The example script includes greenlets so
you can see how they operate.

Instructions
============

Run this `make` from a user account, *not the root account*. At the end of the
Python installation, the build will attempt to install packages in `/usr/lib/python3.5/site-packages/`
even though the install prefix doesn't point there.

The build script requires `genisoimage` to create the `python.iso` image.

Run `make` from the python package directory:

```
cd rumprun-packages/python3
make
```

Examples
========

In order to run a Python program, you will need to create one module that can be loaded by the
interpreter from the command line. One such module exists already in the examples/ directory. First, 
create an ISO containing that example module.

```
genisoimage -r -o examples/main.iso examples/main.py
```

Now you must bake the rumprun unikernel.

```
rumprun-bake hw_generic examples/python.bin build/python 
```

You are now ready to run the Python example. To run the rumpkernel using KVM, the following will work:

```
rumprun kvm -i \
   -b images/python.iso,/python/lib/python3.5 \
   -b examples/main.iso,/python/lib/python3.5/site-packages \
   -e PYTHONHOME=/python \
   -- examples/python.bin -m main
```

Please note that the *main.iso* file is being mounted in the *site-packages/* directory. This 
is what let's you import the *main* module from the command line and get your Python application
running.

You will have to replace `kvm` with `xen` to run under Xen.

You should see the `Welcome to rumprun` text printed to your screen. A few other modules
are imported in the test script simply to verify that they exist.
