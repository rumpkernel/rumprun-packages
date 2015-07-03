Overview
========

Using the following instructions, you will cross-compile python 3.4.3
for rumprun, compile a python program to C using `cython` and launch
the result as a rumprun guest.

We assume you are building for the "hw" platform.  If you are building
for Xen, substitute `bmk` for `xen` in the instructions.

Download
========

Fetch python 3.4.3 from
https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz

Strictly speaking, 3.4.3 is not required, but if you choose to use another
version, applying the cross-compile patch is left as an exercise _pour toi_.


Patches
=======

`patch-crosscompile`: crosscompilation patch for the configure script.
This patch should be upstreamed once our toolchain has stabilized.


Instructions
============

Untar, apply the patch, and run `autoreconf -iv`.

Copy `config.site` from this directory to your python source directory.

Run the configure script:

```
export AR=x86_64-rumprun-netbsd-ar
export RANLIB=x86_64-rumprun-netbsd-ranlib
export READELF=x86_64-rumprun-netbsd-readelf
export CONFIG_SITE=$(pwd)/config.site
x86_64-rumprun-netbsd-configure ./configure --disable-shared --build $(x86_64-rumprun-netbsd-gcc -dumpmachine) --disable-ipv6 --prefix $(pwd)/pythondist
```

Notably, --disable-ipv6 is required because python complains about
a broken `getaddrinfo`.  We'll fix that later.

Build & install python:

```
make
make install
```

Some modules will fail to build, ignore that for now (unless they are
important to your use case, in which case fix them ;).  It will also
try to install something to /usr/lib, so make sure you run "make install"
as non-root.

To run python, you currently need the python runtime modules in the
rumprun guest, along with a stubetc (see the `stubetc` package).
To generate a .iso containing the python runtime modules, go to the
pythondist/lib directory and run:

```
genisoimage -r -o python.iso python3.4
```

Examples
========

To use the simple `hw.py` test program, first install `cython` on
your development host.  Then run:

```
cython --embed hw.py
x86_64-rumprun-netbsd-gcc hw.c -I[...]/pythondist/include/python3.4m -L[...]/pythondist/lib -lpython3.4m -lutil -lm
rumpbake hw_generic a.bin a.out
```

To launch, `rumprun` it:

```
rumprun kvm -i -b python.iso,/python/lib/python3.4 -b stubetc.iso,/etc -e PYTHONHOME=/python a.bin
```

You should see the helloworld text printed.
