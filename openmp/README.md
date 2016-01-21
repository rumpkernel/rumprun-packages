Overview
========

This package provides the OpenMP (libgomp) library for rumprun. 
For cross-compiling the OpenMP library for rumprun the installed version
of gcc on your machine will be determined and the 
version specific source branch cloned to cross-compile the library.


Maintainer
----------

* Vincent Schwarzer, vincent.schwarzer@yahoo.de
* Github: @vincents

Notes
=====

Only GCC Version 4.x and 5.x are supported by the installer script.


Instructions
============

Run this `make` file. Please make sure that you have set the RUMPRUN_TOOLCHAIN_TUPLE in config.mk! 
When the compilation was succesfull you will find two folders in the package with the OpenMP header file and the library.


Usage
========

In order to run a OpenMP program on rumprun you have to provide the paths to the OpenMP header file and library during 
compilation. 

```
x86_64-rumprun-netbsd-gcc <filename>  -I <path-to-openmp-package>/include
-L <path-to-openmp-package>/lib -lpthread -lgomp -o <filename-output>
```

All other steps (baking,running) remain the same.