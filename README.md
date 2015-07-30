rumprun-packages
================

rumprun-packages is a work-in-progress repository for software running on the
rumprun unikernel.

__NOTE__ to users: check the license of each individual package to make
sure it suits your deployment needs.  Unlike everything else provided
by the rump kernel project, we do not guarantee a BSD, ISC or CC0 style
license for every piece of 3rd party software linked from here.

We are working towards choosing a real packaging system, with support for
versions and dependencies.  Until we reach that point, this repo is meant to
assemble the build scripts and patches for running various applications on
rumprun unikernels.

Building packages
-----------------

To get started:

1. Build a rumprun toolchain.
2. Add the `app-tools` directory to your `$PATH`.
3. Copy the `config.mk.dist` file to `config.mk` and set
   `RUMPRUN_TOOLCHAIN_TUPLE` to specify the compiler toolchain to use for
   building, for example, `x86_64-rumprun-netbsd` or `i486-rumprun-netbsdelf`.
4. Refer to the package-specific README file for build instructions.

Tutorials you may want to complete for more in-depth knowledge:

* http://wiki.rumpkernel.org/Tutorial%3A-Building-Rumprun-Unikernels
* http://wiki.rumpkernel.org/Tutorial%3A-Serve-a-static-website-as-a-Unikernel

Contributing new packages
-------------------------

Packaging is done in a BSD ports-like fashion, with individual packages as
subdirectories of this repository. There is also a `stubetc/` directory which
provides a minimal `/etc` tree required by most applications, and a `scripts/`
directory with helper scripts which can be used to automate the package build
process.

When adding new packages, include the following sections in the
package-specific README:

* Overview: name of the package, version number, and a sentence or two on how the package can be used
* Instructions: how to build.  If this section is "run script/make", excellent!
* Examples: a few examples on how to run/use the resulting package
