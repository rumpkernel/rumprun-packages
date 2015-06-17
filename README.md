rumprun-packages-wip
====================

rumprun-packages-wip is a work-in-progress repository for software
running on the rumprun unikernel.  We are working towards a real
packaging system, and until we reach that point, this repo is meant to
assemble the instructions and patches for running various applications
on rumprun unikernels.  This repo is not on the wiki so that we can
host any necessary patches and sources in the same place as the "package".

After we obtain a real packaging system, this repository will shift
purpose to hosting functional work which has not yet made it into
the packaging system.  In other words, it will become a repository for
work-in-progress packages instead of a repository for a work-in-progress
packaging system.

When adding new packages, include the following sections:

* Overview: a sentence or two on how the package can be used
* Download: where to obtain the upstream sources from
* Instructions: how to build and a few examples on how to run
