Overview
========

Packaging of the [Nanomsg](https://www.nanomsg.org/), a socket library written in C that provides several common communication patterns.


Maintainer
==========

* Marin Bek, github: [@marinbek](https://github.com/marinbek)


Instructions
============

Run `make`:

```
make
```

You might want to add rumprun packages include and pkgconfig paths to `C_INCLUDE_PATH` and `PKG_CONFIG_PATH`, respectively. Something like the following, depending on your setup:

```
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$HOME/rumprun-packages/pkgs/include
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/rumprun-packages/pkgs/lib/pkgconfig
```

Examples
========

This is a library.  It is used by other applications by linking with `libnanomsg`.
