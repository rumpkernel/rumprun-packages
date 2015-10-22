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

The files `_third_party_main.js` and `rumpmain.js` in this directory are bundled
 into `build/out/Release/node`. `_third_party_main.js` runs when you launch
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
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express.iso,/express build/out/Release/node.bin /express/examples/hello-world/index.js
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
rumprun kvm -M 160 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i build/out/Release/node.bin
```

You can find a sample `Makefile` for both options in the `examples` directory.
In the `examples` directory, type `make run_express_hello_world` to run the
filesystem (`.iso`) option. Type `make bundle_express_hello_world;
make -C .. bake_hw_generic; make run_kvm` to run the bundled version.

Please note it's best to use a version of `npm` in the 4.1.x series when
installing your application's dependencies on your build system.

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

1. Add the Addon's source file(s) to `build/node.gyp`, under
   `targets`&rarr;`sources`.
2. If the Addon includes header files, add the location of the header files to
   `build/node.gyp`, under `targets`&rarr;`include_dirs`.
3. Run `make`.

The Addon is now compiled into the Node binary (`build/out/Release/node`),
which you can bake and run as normal.

I've added an example of using an Addon in `examples/ursa/test.js`:

1. In the `examples` directory, run `make ursa.iso`. This installs the
   [`ursa`](https://github.com/quartzjer/ursa) module and adds it to a `.iso`
   file.
2. Next, you have to add `ursa`'s Addon to `build/node.gyp` by hand:
  1. In `sources` (under `targets`), add `'../examples/ursa/node_modules/ursa/src/ursaNative.cc'`.
  2. In `include_dirs` (under `targets`), add `'../examples/ursa/node_modules/ursa/node_modules/nan'`.
3. Run `make`.
4. Bake the Node binary (`make bake_hw_generic`)
5. In the `examples` directory, run `make run_ursa`. You should see a
   PEM-formatted public key displayed.

If you don't want to modify `build/node.gyp` by hand, it should be pretty easy
to script. Alternatively, look at
[`nad`](https://github.com/thlorenz/nad), which is "a tool to inject your addon
code into a copy of the node codebase".

Known Issues
============

- Although the Express "Hello World" example displays a message straight away
  that it's listening on port 3000, it seems to take 5 seconds from VM start
  before it's ready to respond. This occurs for DHCP only and is probably due
  to Rumprun performing duplication address detection. Please see the
  [Rumprun issue](https://github.com/rumpkernel/rumprun/issues/56) for more
  information.
