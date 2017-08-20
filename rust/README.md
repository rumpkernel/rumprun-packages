Overview
========

> Rust is a systems programming language that runs blazingly fast, prevents
> segfaults, and guarantees thread safety.
>                              — [rust-lang.org](https://www.rust-lang.org)

This document explains how to obtain a Rust cross-compiler and the cargo package
manager for Rumprun. The Rust compiler built by the Makefile is a 1.9.0-dev
snapshot, cargo is version 0.9.0.

Maintainer
----------

* Sebastian Wicki, gandro@rumpkernel.org
* Github: @gandro


Instructions
============

To build Rust binaries for Rumprun, you need to install a Rust cross-compiler
targeting Rumprun. You can either use the pre-built compiler and standard
library from the official Rust distribution, or you can use the provided
Makefile to build Rust from source.

## Using the Rust Binary Distribution

The Rust distribution offers daily updated builds of the standard
library for the Rumprun target. You can obtain them using
[rustup](https://www.rustup.rs/).

    rustup install nightly
    rustup default nightly
    rustup target add x86_64-rumprun-netbsd

This will set up a Rust cross-compiler which is able to compile binaries
for Rumprun. The cargo package manager will also be installed, so you should
be able to follow the examples below.

> **Note**: Currently only the nightly channel has support for the Rumprun
> cross-std installation.

## Building from Source

Running `make` will build a Rust cross-compiler and the Rust standard library
for Rumprun. The cargo package manager is also included by the default target.
To build Rust without cargo, run `make rust`.

Make sure the `bin` folder of your Rumprun destdir is in `$PATH`.

    cd rumprun-packages/rust
    make -j4

Rust and cargo have the following host dependencies:

   * `g++` 4.7 or `clang++` 3.x
   * GNU `ld` 2.25
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

To cross-compile for Rumprun, always make sure you have the
tools (destdir/bin) in your path, because `rustc` will invoke
`x86_64-rumprun-netbsd-{gcc,ar}`.

When compiling manually with `rustc` or `cargo build`, make sure to compile
for the Rumprun target with `--target=x86_64-rumprun-netbsd`. For example:

    cd examples/hello
    rustc --target=x86_64-rumprun-netbsd hello.rs
    rumprun-bake hw_virtio hello.img hello
    rumprun qemu -i hello.img

If you don't have a display attached, you can run:

    rumprun qemu -g "-curses" -i hello.img

to have `qemu` display output on your terminal instead.

### Using cargo

When building with cargo, you need to specify the `--target` flag as well. The
generated binary in the target directory needs to be baked as usual.
To build the example TCP/IP server with cargo, proceed as follows:

    cd examples/hello-tcp
    cargo build --target=x86_64-rumprun-netbsd
    rumprun-bake hw_virtio hello-tcp.img target/x86_64-rumprun-netbsd/debug/hello-tcp

This will build and bake a `hello-tcp.img` unikernel image. To run the binary,
make sure to configure the network correctly. For example on Linux:

    sudo ip tuntap add tap0 mode tap
    sudo ip addr add 10.0.23.2/24 dev tap0
    sudo ip link set dev tap0 up
    rumprun qemu \
       -I if,vioif,'-net tap,script=no,ifname=tap0' \
       -W if,inet,static,10.0.23.1/24 \
       -i hello-tcp.img

You can connect to the server with telnet:

    telnet 10.0.23.1 9023
