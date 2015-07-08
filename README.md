rumprun-packages
================

rumprun-packages is a work-in-progress repository for software running on the
rumprun unikernel.

We are working towards choosing a real packaging system, with support for
versions and dependencies.  Until we reach that point, this repo is meant to
assemble the build scripts and patches for running various applications on
rumprun unikernels.

Building packages
-----------------

To get started:

1. Build a rumprun toolchain.
2. Add the `app-tools` directory to your `$PATH`.
3. Edit the `config.mk` file to specify the target of the rumprun toolchain you
   want to build packages for.
4. Refer to the package-specific README file for build instructions.

Contributing new packages
-------------------------

Packaging is done in a BSD ports-like fashion, with individual packages as
subdirectories of this repository. There is also a `stubetc/` directory which
provides a minimal `/etc` tree required by most applications, and a `scripts/`
directory with helper scripts which can be used to automate the package build
process.

When adding new packages, include the following sections in the
package-specific README:

* Overview: a sentence or two on how the package can be used
* Download: where to obtain the upstream sources from
* Instructions: how to build.  If this section is "run script/make", excellent!
* Examples: a few examples on how to run/use the resulting package
