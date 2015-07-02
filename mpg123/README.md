Overview
========

Following the instructions will build and run mpg123 for the rumprun
_hw_ platform.  You could theoretically do the same for Xen platform
via PCI passthrough, but doing so is left as an exercise for the reader.


Download
========

Upstream source will be downloaded by the build process.



Instructions
============

Run `make`, setting `CC` to target architecture cross-compiler, e.g.

```
make CC=x86_64-rumprun-netbsd-cc
```

Note, if you want to compile a 32bit build, you also need to edit
`Makefile`.

Bake the final unikernel image:
```
rumpbake hw_generic bin/mpg123.bin bin/mpg123
```

Use `rumprun` as normal.


Examples
========

```
rumprun kvm -i -b ~/tosi.iso,/mp3 -g '-soundhw es1370' mpg123.bin -v -z -@ /mp3/allmp3.txt
```
(assumes `tosi.iso` contains mp3's along with a list of them)

```
rumprun kvm -i -I iftag,vioif,'-net user' -W iftag,inet,dhcp -g '-soundhw es1370' mpg123.bin -v 'http://10.0.0.10/test.mp3'
```
(tested working, but network configuration is left as an exercise to the reader.
if you want DNS, remember to provide a stub `/etc`)
