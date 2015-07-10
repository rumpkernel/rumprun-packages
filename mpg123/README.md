Overview
========

Following the instructions will build and run mpg123 1.22.2 for the rumprun
_hw_ platform.  You could theoretically do the same for Xen platform
via PCI passthrough, but doing so is left as an exercise for the reader.


Instructions
============

Run `make`:

```
make
```

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
