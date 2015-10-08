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

If you give an argument to `node.bin` when running `rumprun`, then
`_third_party_main.js` treats it as a pathname and runs the script in that file.
If you don't give an argument, it just displays a message and exits. You can 
of course change this to do anything you like.

Most applications require code in separate modules, and you have two
options for running these.

The first option is to put your application's files into a filesystem (e.g.
using `genisoimage`) and attach it to `rumprun` using the `-b` option. You can
then give the path to the main file of your application as an argument to
`rumprun`, after `node.bin`.

For instance, assuming Express is checked out into the 'express' directory,
then to run the "Hello World" example:

```shell
(cd express; npm install --production)
genisoimage -l -r -o express.iso express/
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express.iso,/express build/out/Release/node.bin /express/examples/hello-world/index.js
```

The second option is to bundle your entire application into a single file,
and overwrite `_third_party_main.js`. You can do this using
[webpack](http://webpack.github.io/).

For instance, to run the same Express "Hello World" example:

```
npm install webpack json-loader
(cd express; npm install --production)
./node_modules/.bin/webpack --target node --module-bind json ./express/examples/hello-world/index.js _third_party_main.js
make
make bake_hw_generic
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i build/out/Release/node.bin
```

You can find a sample `Makefile` for both options in the `examples` directory.

Known Issues
============

1. I haven't tried Node modules with native addons yet. This will require
   getting `npm` to use rumprun's toolchain.

2. Although the Express "Hello World" example displays a message straight away
   that it's listening on port 3000, it seems to take 5 seconds from VM start
   before it's ready to respond.
