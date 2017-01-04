Overview
========

mpg123 is an mp3 decoder/player.  If you want to use it for playering,
you need a guest environment with audio capability.  Currently, audio
capability is most easily provided by an emulator such as QEMU.

Maintainer
----------

github: anttikantee


Instructions
============

Run `make`.

The bakeable binary will be available in `bin/mpg123`.


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
