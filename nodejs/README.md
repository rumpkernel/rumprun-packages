Overview
========

This is Node.js 4.2.4 LTS for Rumprun. Use any of the thousands of npm packages
or run your own Javascript modules on the Rumprun unikernel.

Maintainer
----------

* David Halls, dahalls@gmail.com
* Github: @davedoesdev

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

Run `make`. This will produce `build-4.2.4/out/Release/node`, which you can then pass
to `rumprun-bake`. If you're using the generic configuration, you can use
`make bake_hw_generic` to generate `build-4.2.4/out/Release/node.bin`.

You can then run Node using something like this:

```shell
rumprun kvm -M 160 -i build-4.2.4/out/Release/node.bin
```

Examples
========

The files `_third_party_main.js` and `rumpmain.js` in this directory are bundled
 into `build-4.2.4/out/Release/node`. `_third_party_main.js` runs when you launch
Node using `rumprun`.

If you give an argument to `node.bin` when running `rumprun`, then
`_third_party_main.js` treats it as a pathname and runs the script in that file.
If you don't give an argument, it runs `rumpmain.js`, which just displays a
message and exits. You can of course change `rumpmain.js` to do anything you
like.

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
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express.iso,/express build-4.2.4/out/Release/node.bin /express/examples/hello-world/index.js
```

The second option is to bundle your entire application into a single file,
and overwrite `rumpmain.js`. You can do this using
[webpack](http://webpack.github.io/).

For instance, to run the same Express "Hello World" example:

```
npm install webpack json-loader
(cd express; npm install --production)
./node_modules/.bin/webpack --target node --module-bind json ./express/examples/hello-world/index.js rumpmain.js
make
make bake_hw_generic
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i build-4.2.4/out/Release/node.bin
```

You can find a sample `Makefile` for both options in the `examples` directory.
In the `examples` directory, type `make run_express_hello_world` to run the
filesystem (`.iso`) option. Type `make bundle_express_hello_world;
make -C .. bake_hw_generic; make run_kvm` to run the bundled version.

Please note it's best to use Node 4.2.4 (and associated `npm` version) on your
build system when installing you application's dependencies.

Native Addons
=============

Some Node modules use Node.js native
[Addons](https://nodejs.org/api/addons.html). These are compiled from C++ into
shared libraries, which Node loads at runtime.

Rumprun doesn't support dynamic loading of shared libraries so you'll see a
stacktrace like this if one of your modules tries to load an Addon:

```
Error: Service unavailable
    at Error (native)
    at Module.load (module.js:355:32)
    at Function.Module._load (module.js:310:12)
    at Module.require (module.js:365:17)
    at require (module.js:384:17)
```

The solution is to compile the Addon into the Node binary itself. Whilst this
isn't something you usually do, it's quite simple:

1. Add the full pathnames of the Addon's source and header files to `build-4.2.4/node.gyp`.
  - Either do this by hand:
    1. Add the source files to `targets`&rarr;`sources` 
    2. Add the header files to `targets`&rarr;`include_dirs`
  - Or use [`nad`](https://github.com/thlorenz/nad):
    1. `npm install -g nad`
    2. `cd /path/to/addon`
    2. `nad configure --nodedir /path/to/rumprun-packages/nodejs/build-4.2.4`
    3. `nad inject`
2. Run `NODE_PATH=/path/to/addon/node_modules make`

The Addon is now compiled into the Node binary (`build-4.2.4/out/Release/node`),
which you can bake and run as normal.

I've added an example of using an Addon in `examples/ursa/test.js`:

1. In the `examples` directory, run `make ursa.iso`. This installs the
   [`ursa`](https://github.com/quartzjer/ursa) module and adds it to a `.iso`
   file.
2. Next, you have to add `ursa`'s Addon to `build-4.2.4/node.gyp`.
  - Either modify `build-4.2.4/node.gyp` by hand:
    1. In `sources` (under `targets`), add `'../examples/ursa/node_modules/ursa/src/ursaNative.cc'`
    2. In `include_dirs` (under `targets`), add `'../examples/ursa/node_modules/ursa/node_modules/nan'`
    3. Run `make`
  - Or run `make inject_ursa` in the `examples` directory. This uses `nad` to
    modify `build-4.2.4/node.gyp` and then runs `make` with `NODE_PATH` set.
3. Bake the Node binary (`make bake_hw_generic`)
4. In the `examples` directory, run `make run_ursa`. You should see a
   PEM-formatted public key displayed.

Node 5
======

Node 5.3.0 is known to build successfully. Change the first two lines of
`Makefile.inc` to:

```make
NODE_VERSION=5.3.0
PKGSRC=nodejs
```

Known Issues
============

- If you use `nad` to inject more than one Addon into `build-4.2.4/node.gyp`,
  you might run into problems. You'll end up with conflicting definitions for
  `module_root_dir`, so if both the Addons rely on its value then one will
  fail to compile.
