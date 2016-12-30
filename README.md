Rumprun-packages [![Build Status](https://travis-ci.org/rumpkernel/rumprun-packages.svg?branch=master)](https://travis-ci.org/rumpkernel/rumprun-packages)
================

Rumprun-packages is a work-in-progress repository for software running on the
[Rumprun unikernel](http://repo.rumpkernel.org/rumprun).

Packaging is done in a BSD ports-like fashion, with individual
packages as subdirectories of this repository.

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
2. Add destdir/bin from Step 1 to your `$PATH` by `. "$(pwd)/obj-amd64-<arch>/config-PATH.sh"`.
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
the repository instead of going the pull request route. __If you push
directly, make sure you push only the commit(s) you meant to push.__
Opening a pull request and merging it from the GitHub web interface
gives you an extra review step, so it is safer in that regard.

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

__When creating new packages, renaming or removing existing packages,__
please update `.travis.yml` to reflect your changes, and
`.travis-install.sh` if your package has any build dependencies not
installed in the Travis CI environment we use (`dist: trusty`).

If something is unclear, see existing packages for examples or ask
on the [mailing list or on irc](http://wiki.rumpkernel.org/Info:-Community).

Travis CI integration
---------------------

Due to the time taken for a complete build of all packages (3+ hours as of
this writing) we do not use the traditional model of triggering a build on
each commit. Instead, full builds of all packages are triggered twice a
day, currently at 6am and 6pm CET.

Pull requests are not currently built as there is no straightforward way to
get Travis to build only the subset of packages affected by a pull request.
