Overview
========

A Portable Foreign Function Interface Library for OpenJDK8
https://sourceware.org/libffi/


Maintainer
----------

* Myungho Jung, mhjungk@gmail.com
* Github: @myunghoj

Patches
=======

Libffi has a bug that memory may be corrupted in multithreading if memory is deallocated by moving stack pointer. This patch apllies to `unix64.S` assembly code which fixes page fault error. This bug is found while testing `jetty` web server on `OpenJDK8` package.

Instructions
============

Run `make`.
