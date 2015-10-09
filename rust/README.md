Overview
========

This document explains how to build a Rust cross-compiler and the cargo package
manager for rumprun. The Rust compiler version is a 1.5.0-dev snapshot
(the first version that supports Rumprun), cargo and cargo-rumpbake are
version 0.5.0.

This package also fetches and builds a copy of
[cargo-rumpbake](https://github.com/gandro/cargo-rumpbake), a small wrapper
around `cargo build` and `rumpbake` which simplifies building and baking when
using `cargo` as a build tool.

Instructions
============

Running `make` will build a Rust cross-compiler for Rumprun, including the
standard library. The cargo package manager and the cargo-rumpbake subcommand
are also included by default. To build Rust without cargo, run `make rust`.

Make sure the `app-tools` folder of your Rumprun build is in `$PATH`.

    cd rumprun-packages/rust
    make -j4

Rust and cargo have the following host dependencies:

   * `g++` 4.7 or `clang++` 3.x
   * `ld` 2.25
   * `python` 2.6 or later (but not 3.x)
   * GNU `make` 3.81 or later
   * `curl`
   * `git`
   * `cmake` (for cargo only)
   * OpenSSL headers (`libssl-dev` on Ubuntu, for cargo only)

You will also need a decent Internet connection, at least 1.5 GB of RAM and
at least 6 GB of disk space. Be aware, compiling Rust can easily take two
hours or more.

The toolchain will be installed in `build/destdir`. In order to use it, you
will need to set `LD_LIBRARY_PATH`. The following command sets the appropriate
environment variables to invoke `rustc` and `cargo` directly:

    . ./rustenv.sh

> **Tip**: If you are using [multirust](https://github.com/brson/multirust), 
> you can configure a custom toolchain instead of using rustenv.sh.
> `multirust update rumprun --link-local $(readlink -f build/destdir/)`

Examples
========

To cross-compile for Rumprun, always make sure you have `app-tools` in your
path, because `rustc` will invoke `x86_64-rumprun-netbsd-{gcc,ar}`.

When compiling manually with `rustc` or `cargo build`, make sure to compile
for the Rumprun target with `--target=x86_64-rumprun-netbsd`. For example:

    cd examples/hello
    rustc --target=x86_64-rumprun-netbsd hello.rs
    rumpbake hw_virtio hello.img hello
    rumprun qemu -i hello.img

If you don't have a display attached, you can run:

    rumprun qemu -g "-curses" -i hello.img

to have `qemu` display output on your terminal instead.

### cargo rumpbake

When building with cargo, you can use `cargo rumpbake`, a tool which invokes
rumpbake automatically. To build the example TCP/IP server, proceed as follows:

    cd examples/hello-tcp
    cargo rumpbake hw_virtio

This will build and bake a `hello-tcp.img` unikernel image. To run it, make sure
you configure the network correctly. For example on Linux:

    sudo ip tuntap add tap0 mode tap
    sudo ip addr add 10.0.23.2/24 dev tap0
    sudo ip link set dev tap0 up
    rumprun qemu \
       -I if,vioif,'-net tap,script=no,ifname=tap0' \
       -W if,inet,static,10.0.23.1/24 \
       -i hello-tcp.img

You can connect to the server with telnet:

    telnet 10.0.23.1 9023
