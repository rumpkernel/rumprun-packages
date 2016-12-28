# Overview

This is zeromq 4.2.1 for Rumprun. 

## Maintainer

* Bela Berde, bela.berde@gmail.com
* Github: @kvart2006

## Instructions

## Examples

In order to run an example application on rumprun, you have to provide the paths to the ```zmq.h``` header file and library during compilation: 

```
$ x86_64-rumprun-netbsd-gcc <filename>  -I <path-to-zeromq-package>/include \
-L <path-to-zeromq-package>/lib -lpthread -lzmq -o <filename-output>
```
Example (testing):
```
<path-to-zeromq-package>/lib = /root/git/rumprun-packages/pkgs/lib
<path-to-zeromq-package>/include = /root/git/rumprun-packages/pkgs/include

x86_64-rumprun-netbsd-g++ example1.cpp  -I/root/git/rumprun-packages/pkgs/include -L/root/git/rumprun-packages/pkgs/lib -lpthread -lzmq -o example1-rr

rumprun-bake hw_generic example1-rr.bin example1-rr

rumprun qemu -i example1-rr.bin
```
All other steps (baking,running) remain the same.

### Example 1
A simple one-way zeromq messaging using ZMQ_REQ and ZMQ_REP. 

### Example 2
A simple one-way zeromq messaging using ZMQ_DEALER (asynchronos). 
