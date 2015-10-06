Overview
========

This is Node.js 4.1.1 for Rumprun. Use any of the thousands of npm packages or run your own Javascript modules on the Rumprun unikernel.

Patches
=======

The build process first applies the NetBSD pkgsrc patches for Node.js and then
applies patches from the `patches` directory.

There are a couple of changes worth noting:

- Rumprun doesn't have `execinfo.h` or `backtrace` so C stack traces for
  exceptions won't be printed.

- Rumprun doesn't support the `mmap(MAP_NORESERVE)` ... `mmap(MAP_FIXED)`
  combination for allocating code range memory so this has to be fixed when
  Node is launched. 16Mb is allocated for your code by default, which should
  be enough for small programs. If you need more, use the `--code-range-size`
  argument when you use `rumprun` to launch Node (e.g. `--code-range-size=64`).

Instructions
============

Run `make`. This will produce `build/out/Release/node`, which you can then pass
to `rumpbake`. If you're using the generic configuration, you can use
`make bake_hw_generic` to generate `build/out/Release/node.bin`.

You can then run Node using something like this:

```shell
rumprun kvm -M 160 -i build/out/Release/node.bin
```

Examples
========

The file `_third_party_main.js` in this directory is bundled into
`build/out/Release/node` and runs when you launch Node.

At the moment this file is just a one-liner, and you can of course change it
and run `make` again.

I hope to supply a utility soon which can bundle a whole application into
`_third_party_main.js` and give some examples.
