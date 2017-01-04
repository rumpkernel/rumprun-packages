Overview
========

This package provides the OpenMP (libgomp) library for rumprun. 
For cross-compiling the OpenMP library for rumprun the installed version
of gcc on your machine will be determined and the 
version specific source branch cloned to cross-compile the library.


Maintainer
==========

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

In order to run a OpenMP application on rumprun you have to provide the paths to the OpenMP header file and library during 
compilation. 

```
$ x86_64-rumprun-netbsd-gcc <filename>  -I <path-to-openmp-package>/include \
-L <path-to-openmp-package>/lib -lpthread -lgomp -o <filename-output>
```

All other steps (baking,running) remain the same.


Example
=========
This short tutorial explains how to build the OpenMP application `omp_hello.c` and run it with Rumprun.
If you are new to Rumprun you should do the following tutorial (https://github.com/rumpkernel/wiki/wiki/Tutorial:-Building-Rumprun-Unikernels) first.
We assume that you have conducted all initial steps to compile the Rumprun Unikernel as described in the tutorial before.

First you have to make sure that `RUMPRUN_TOOLCHAIN_TUPLE` is set and the path to the Rumprun build utilites is exported before executing the Makefile:
```
$ make
```
The Makefile determines your currently installed GCC version and fetches the proper GCC sources branch required to build libgomp (OpenMP library) for Rumprun.

When the build/fetch process was successful you will find two new directories named `include` and `lib`  with the OpenMP header file and the OpenMP static library. To build an OpenMP application for Rumprun you have to compile the application supplying additional the path to the two directories mentioned above as arguments.

```
$ x86_64-rumprun-netbsd-gcc ./example/omp_hello.c -I ./include \
-L ./lib -lpthread -lgomp -o omp_hello_rumprun.bin
```
After the compilation you have to bake the created binary for your target platform:
```
$ rumprun-bake <target_platform> omp_hello_rumprun omp_hello_rumprun.bin
```
Now you can run the Rumprun Unikernel with the `omp_hello_rumprun` application with:
```
$ rumprun <target_platform> -i omp_hello_rumprun
```
If all steps were successful you should see following output on your terminal now:
```
Hello World from thread = 0
Number of threads = 1
```

Further Resources
===================
- Great OpenMP tutorial (https://computing.llnl.gov/tutorials/openMP/)
- Rodinia Benchmark Suite (uses OpenMP) (https://www.cs.virginia.edu/~skadron/wiki/rodinia/index.php/Rodinia:Accelerating_Compute-Intensive_Applications_with_Accelerators)

