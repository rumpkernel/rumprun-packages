rumprun-packages
================

rumprun-packages is a work-in-progress repository for software running on the
rumprun unikernel.

We are working towards choosing a real packaging system, with support for
versions and dependencies.  Until we reach that point, this repo is meant to
assemble the build scripts and patches for for running various applications on
rumprun unikernels in a BSD ports-like fashion.

When adding new packages, include the following sections in the
package-specific README:

* Overview: a sentence or two on how the package can be used
* Download: where to obtain the upstream sources from
* Instructions: how to build.  If this section is "run script/make", excellent!
* Examples: a few examples on how to run/use the resulting package
