Overview
========

This directory contains a `/etc` "distribution" required by many
applications.  Eventually we hope to make the contents automatically
present in rumprun unikernels, but for now you have to manually
supply an image to the rumprun launcher.


Instructions
============

Any supported file system format will do, but an iso is usually the
easiest choice:

```
genisoimage -r -o stubetc.iso etc
````

Then supply it to the rump kernel as:

```
rumrun [...] -b stubetc.iso,/etc [...]
```
