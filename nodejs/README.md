# Overview

This is Node.js 4.3.0 LTS for Rumprun. Use any of the thousands of npm packages
or run your own Javascript modules on the Rumprun unikernel.

## Maintainer

* David Halls, dahalls@gmail.com
* Github: @davedoesdev

# Patches

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

# Instructions

Run `make`. This will produce `build-4.3.0/out/Release/node-default`, which you
can then pass to `rumprun-bake` &mdash; for example:

```shell
rumprun-bake hw_generic build-4.3.0/out/Release/node-default.bin build-4.3.0/out/Release/node-default
```

You can then run Node using something like this:

```shell
rumprun kvm -M 256 -i build-4.3.0/out/Release/node-default.bin
```

# Examples

The files `_third_party_main.js` and `rumpmain.js` in this directory are bundled
into `build-4.3.0/out/Release/node-default`. `_third_party_main.js` runs when
you launch Node using `rumprun`.

If you give an argument to `node-default.bin` when running `rumprun`, then
`_third_party_main.js` treats it as a pathname and runs the script in that file.
If you don't give an argument, it runs `rumpmain.js`, which just displays a
message and exits.

`rumpmain.js` ships as a symbolic link to `default.js`. You can of course link
`rumpmain.js` to a different file. Please note this will change the name of the
output binary too, based on the name of the file you link to. For example,
if you link `rumpmain.js` to `foo.js` then `make` will produce
`build-4.3.0/out/Release/node-foo`.

Most applications require code in separate modules, and you have four options
for running these.

## Separate filesystem

The first option is to put your application's files into a filesystem (e.g.
using `genisoimage`) and attach it to `rumprun` using the `-b` option. You can
then give the path to the main file of your application as an argument to
`rumprun`, after `node-default.bin`.

This is the most flexible option but doesn't give you a single image to
distribute.

For instance, assuming [Express](http://expressjs.com/) is checked out into the
`examples/express-4.13.3` directory, then to run the "Hello World" example:

```shell
cd examples
(cd express-4.13.3; npm install --production)
genisoimage -l -r -o express-4.13.3.iso express-4.13.3
rumprun kvm -M 256 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i -b express-4.13.3.iso,/express ../build-4.3.0/out/Release/node-default.bin /express/examples/hello-world/index.js
```

Or use the supplied `make` target:

```shell
cd examples
make run_express_hello_world
```

Point your browser to [http://localhost:3000](http://localhost:3000).

## Baked-in filesystem

The second option is similar to the first except you create your application's
filesystem using Rumprun's `cookfs` tool. You then bake the filesystem image
into the Rumpkernel using `rumprun-bake`:

```shell
cd examples
(cd express-4.13.3; npm install --production)
x86_64-rumprun-netbsd-cookfs express-4.13.3.fs express-4.13.3
rumprun-bake -m "add express-4.13.3.fs" hw_generic ../build-4.3.0/out/Release/node-express-4.13.3.bin ../build-4.3.0/out/Release/node-default
rumprun kvm -M 256 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i ../build-4.3.0/out/Release/node-express-4.13.3.bin /express-4.13.3/examples/hello-world/index.js
```

This gives you a single image with everything in. Bear in mind the files will
end up uncompressed in the image, so if you have a large application then the
image will be large and take longer to load.

## Webpack/Browserify

The third option is to bundle your entire application into a single file,
and link `rumpmain.js` to it. You can do this using
[webpack](http://webpack.github.io/) or [browserify](http://browserify.org/).

For instance, to run the same Express "Hello World" example:

```shell
cd examples
npm install webpack json-loader
(cd express-4.13.3; npm install --production)
./node_modules/.bin/webpack --target node --module-bind json ./express-4.13.3/examples/hello-world/index.js hello-world.js
ln -sf examples/hello-world.js ../rumpmain.js
make -C ..
rumprun-bake hw_generic ../build-4.3.0/out/Release/node-hello-world.bin ../build-4.3.0/out/Release/node-hello-world
rumprun kvm -M 256 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i ../build-4.3.0/out/Release/node-hello-world.bin
```

This approach does produce a single image and is fine for applications which are
compatible with Webpack or Browserify. However, larger applications can require
quite a bit of tweaking.

## Ziploader

I've implemented a fourth option which works better than Webpack/Browserify for
larger applications. Actually, it's probably better for small applications too.

First you Zip up your application. Then you run `zipload.sh`, passing the Zip
file as standard input and the name of the script inside the Zip file to run
as a parameter. `zipload.sh` will write a completely self-contained script to
standard output, which you can then redirect to a file and use as the link
target for `rumpmain.js`.

For example:

```shell
cd examples
(cd express-4.13.3; npm install --production)
zip -r express-4.13.3.zip express-4.13.3
./zipload.sh /express-4.13.3/examples/hello-world/index.js < express-4.13.3.zip > hello-world.js
ln -sf examples/hello-world.js ../rumpmain.js
make -C ..
rumprun-bake hw_generic ../build-4.3.0/out/Release/node-hello-world.bin ../build-4.3.0/out/Release/node-hello-world
rumprun kvm -M 256 -I 'nic,vioif,-net user,hostfwd=tcp::3000-:3000' -W nic,inet,dhcp -i ../build-4.3.0/out/Release/node-hello-world.bin
```

Behind the scenes, Node's `fs` module is monkey-patched to load modules and
files from the Zip file. The Zip file is written into the script as a
base64-encoded string and accessed using
[JSZip](https://stuk.github.io/jszip/), which is also bundled into the script.

This option produces a smaller single image than the baked-in filesystem option
but does incur an overhead in decompressing modules before they're loaded.

# Native Addons

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
isn't something you usually do, it's quite simple. You need to add the full
pathnames of the Addon's source and header files to `build-4.3.0/node.gyp`.

- Either do this by hand:
  1. Add the source files to `targets`&rarr;`sources` 
  2. Add the header files to `targets`&rarr;`include_dirs`
  3. Run `make`
- Or use [`nad`](https://github.com/thlorenz/nad):
  1. `npm install -g nad`
  2. `cd /path/to/addon`
  2. `nad configure --nodedir /path/to/rumprun-packages/nodejs/build-4.3.0`
  3. `nad inject`
  4. Run `NODE_PATH=/path/to/addon/node_modules make`

The Addon is now compiled into the Node binary, which you can bake and run as
normal. Remember the Node binary will be `build-4.3.0/out/Release/node-default`
unless you've linked `rumpmain.js` to something other than `default.js`.

I've added an example of using an Addon in `examples/ursa/test.js`:

1. In the `examples` directory, run `make ursa.iso`. This installs the
   [`ursa`](https://github.com/quartzjer/ursa) module and adds it to a `.iso`
   file.
2. Next, you have to add `ursa`'s Addon to `build-4.3.0/node.gyp`.
  - Either modify `build-4.3.0/node.gyp` by hand:
    1. In `sources` (under `targets`), add `'../examples/ursa/node_modules/ursa/src/ursaNative.cc'`
    2. In `include_dirs` (under `targets`), add `'../examples/ursa/node_modules/ursa/node_modules/nan'`
    3. Run `make`
  - Or run `make inject_ursa` in the `examples` directory. This uses `nad` to
    modify `build-4.3.0/node.gyp` and then runs `make` with `NODE_PATH` set.
3. Bake the Node binary (e.g. `rumprun-bake hw_generic build-4.3.0/out/Release/node-default.bin build-4.3.0/out/Release/node-default`, depending on what `rumpmain.js` is linked to)
4. In the `examples` directory, run `make run_ursa`. You should see a
   PEM-formatted public key displayed.

A Bigger Example
================

I've got the [Ghost](https://ghost.org/) blogging platform running under
Rumprun:

```shell
cd examples
make ghost_data.img
zip -r ghost-0.7.8.zip Ghost-0.7.8
./zipload.sh /Ghost-0.7.8/index.js < ghost-0.7.8.zip > ghost-0.7.8.js
ln -sf examples/ghost-0.7.8.js ../rumpmain.js
make inject_ghost
rumprun-bake hw_generic ../build-4.3.0/out/Release/node-ghost-0.7.8.bin ../build-4.3.0/out/Release/node-ghost-0.7.8
qemu-system-x86_64 -enable-kvm -m 1024 -kernel ../build-4.3.0/out/Release/node-ghost-0.7.8.bin -drive if=virtio,file=ghost_data.img -net nic,model=virtio -net user,hostfwd=tcp::2368-:2368 -append '{"net": {"if": "vioif0",, "type": "inet",,  "method":"dhcp"},, "blk": {"source": "dev",, "path": "/dev/ld0a",, "fstype": "blk",, "mountpoint": "/ghost_data"},, "env": "GHOST_CONFIG=/ghost_data/config.js",, "cmdline": "node --code-range-size=64"}'
```

Point your browser to [http://localhost:2368](http://localhost:2368).

Ghost's configuration and  persistent data is kept in `ghost_data.img`.

Some Fun Examples
=================

Here are instructions for running a couple of Node.js multiplayer games on
Rumprun.

[Nodekick](https://github.com/amirrajan/nodekick)
-------------------------------------------------

```shell
cd examples
git clone --depth=1 https://github.com/amirrajan/nodekick.git
(cd nodekick; npm install)
genisoimage -l -r -o nodekick.iso nodekick
qemu-system-x86_64 -enable-kvm -m 256 -kernel ../build-4.3.0/out/Release/node-default.bin -drive if=virtio,file=nodekick.iso -net nic,model=virtio -net user,hostfwd=tcp::3000-:3000 -append '{"net": {"if": "vioif0",, "type": "inet",, "method":"dhcp"},, "blk": {"source": "dev",, "path": "/dev/ld0a",, "fstype": "blk",, "mountpoint": "/nodekick"},, "cmdline": "/nodekick/node /nodekick/server.js"}'
```

Point your browser to [http://localhost:3000](http://localhost:3000).

[Chess](https://github.com/thebinarypenguin/socket.io-chess)
------------------------------------------------------------

```shell
cd examples
git clone --depth=1 https://github.com/thebinarypenguin/socket.io-chess.git
(cd socket.io-chess; npm install)
genisoimage -l -r -o socket.io-chess.iso socket.io-chess
qemu-system-x86_64 -enable-kvm -m 512 -kernel ../build-4.3.0/out/Release/node-default.bin -drive if=virtio,file=socket.io-chess.iso -net nic,model=virtio -net user,hostfwd=tcp::3000-:3000 -append '{"net": {"if": "vioif0",, "type": "inet",, "method":"dhcp"},, "blk": {"source": "dev",, "path": "/dev/ld0a",, "fstype": "blk",, "mountpoint": "/chess"},, "cmdline": "node /chess/server.js"}'
```

Point your browser to [http://localhost:3000](http://localhost:3000).

Node 5
======

Node 5.6.0 is known to build successfully:

```shell
make NODE_VERSION=5.6.0 PKGSRC=nodejs
```

Known Issues
============

- If you use `nad` to inject more than one Addon into `build-4.3.0/node.gyp`,
  you might run into problems. You'll end up with conflicting definitions for
  `module_root_dir`, so if both the Addons rely on its value then one will
  fail to compile.
- It's best to use Node 4.3.0 (and associated `npm` version) on your build
  system when installing your application's dependencies.
