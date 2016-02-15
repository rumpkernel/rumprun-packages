Ruby
====

Compiles MRI Ruby 2.2

Maintainer
----------

* Reuben Sutton, reuben.sutton@gmail.com
* Github: @reuben-sutton

Example
=======

make
make images/examples.iso
rumprun qemu -g'-nographic -vga none' -i -e GEM_HOME=/examples/gems/ruby/2.2.0 -b images/usr.iso,/usr -b images/examples.iso,/examples bin/ruby.bin -I/usr/lib/ruby/2.2.0/ -I/usr/lib/ruby/2.2.0/x86_64-netbsd/ /examples/test_sinatra.rb

Limitations
===========

* No native gem support
