Rumprun-packages
================

Rumprun-packages is a work-in-progress repository for software running on the
[Rumprun unikernel](http://repo.rumpkernel.org/rumprun).

Packaging is done in a BSD ports-like fashion, with individual
packages as subdirectories of this repository.  Additionally, `stubetc`
provides a minimal `/etc` tree required by most applications (contains
e.g. `/etc/services`), and `scripts` provides helper scripts for the
the package build process.

__NOTE__ to users: check the license of each individual package to make
sure it suits your deployment needs.  Unlike everything else provided
by the rump kernel project, we do not guarantee a BSD, ISC or CC0 style
license for every piece of 3rd party software linked from here.

We are working towards choosing a real packaging system, with support for
versions and dependencies.  Until we reach that point, this repo is meant to
assemble the build scripts and patches for running various applications on
Rumprun unikernels.

Building packages
-----------------

To get started:

1. Build a Rumprun toolchain (with `build-rr.sh` in the rumprun repo).
2. Add destdir/bin from Step 1 to your `$PATH` (the default destdir
   _relative to rumprun repo working directory_ is `$(pwd)/rumprun/bin`).
3. Copy the `config.mk.dist` file to `config.mk` and set
   `RUMPRUN_TOOLCHAIN_TUPLE` to specify the compiler toolchain to use for
   building, for example, `x86_64-rumprun-netbsd` or `i486-rumprun-netbsdelf`.
4. Refer to the package-specific README file for build instructions.

Tutorials you may want to complete for more in-depth knowledge:

* http://wiki.rumpkernel.org/Tutorial%3A-Building-Rumprun-Unikernels
* http://wiki.rumpkernel.org/Tutorial%3A-Serve-a-static-website-as-a-Unikernel

Contributing new packages
-------------------------

New packages are contributed by creating the package and, after
sufficient testing, opening a pull request.  If you are a contributor
with push access to rumprun-packages, you may also push directly into
the repository instead of going the pull request route.

When creating new packages, include the following sections in the
package-specific README:

* Overview: name of the package, version number, and a sentence or two on how the package can be used
  + Maintainer: maintainer of the package (you!).  Required: github account.  Optional: name, email address, irc nick.
* Instructions [if an application and not e.g. library]: free-form description of how to bake the packaged software
* Examples [optional but highly recommended]: a few examples on how to run/use the resulting package

We require that new packages have a maintainer.  A maintainer should
generally be interested in the welfare of a package by answering
potential user questions, addressing problem reports, and updating
the package especially when security vulnerabilities are discovered.
All maintainers are given push access to the repository.  In case
you created a package but do not want to maintain it, submit a pull
request anyway; we will mark the pull request as `maintainer wanted`,
and if someone who needs the software comes along and is willing to be
maintainer, they potentially do not have to start from scratch.

If something is unclear, see existing packages for examples or ask
on the [mailing list or on irc](http://wiki.rumpkernel.org/Info:-Community).
