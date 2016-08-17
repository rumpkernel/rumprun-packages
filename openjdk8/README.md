Overview
========

Packaging of the [OpenJDK8](http://openjdk.java.net/projects/bsd-port/) BSD Port for rumprun.

Maintainer
----------

* Myungho Jung, mhjungk@gmail.com
* Github: @myunghoj

Patches
=======

Lots of patches are required to build java binary. Most of the them are for changing shared libraries to static libraries. Also, problems in cross compiling on Linux and mmap flags are modified for Rump.

Instructions
============

`Makefile` will automatically clone repositories, update changeset, apply patches, and build them.

```
make
```

Basically, only java binary will be built. If you want to build other binaries, just remove comments in `build/jdk/make/CompileLaunchers.gmk`.

And bake the image like below:

```
rumprun-bake xen bin/java.bin bin/java
```

Replace the platfrom with yours.

Examples
========

`HelloWorld.jar` is included in this package for test. To run java application, `JAVA_HOME` and `CLASS_PATH` should be set.

````
rumprun qemu -i -M 512 \
    -N java \
    -b ../images/jre.iso,/jdk/jre/lib \
    -b ../images/jar.ffs,/jar \
    -e JAVA_HOME=/jdk \
    -e CLASS_PATH=/jar:/jdk/jre/lib \
    -- ../bin/java.bin -jar /jar/HelloWorld.jar
````

You will see `Hello World!` message on qemu window.

jetty
-----

One of the objectives of this project is to run `jetty` web server on Rump. `jetty` package is not included so you can download it from (http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.3.11.v20160721/jetty-distribution-9.3.11.v20160721.tar.gz) and extract files to `/jar/jetty`. Most of java web applications are needed to extract and write files on image. So, you need to create writable image with `jetty`.

````
make images/jar
````

It makes a writeable file system image with files in `jar/*` to `images/jar.ffs`.

A bridge should be created to access the internet. You can make one using Linux bridge or Open vSwitch like below.

````
sudo ovs-vsctl add-br xenbr0
sudo ifconfig xenbr0 up
sudo ifconfig xenbr0 10.0.0.5/24
````

You can run `jetty` demo application by following command below.

````
rumprun xen -i -M 1024 \
    -N java \
    -I xen0,xenif,script=vif-openvswitch,bridge=xenbr0 \
    -W xen0,inet,static,10.0.0.11/24 \
    -b ../images/jre.iso,/jdk/jre/lib \
    -b ../images/jar.ffs,/jar \
    -e JAVA_HOME=/jdk \
    -e CLASS_PATH=/jar/jetty:/jdk/jre/lib \
    -- ../bin/java.bin \
    -Djava.io.tmpdir=/jar -jar /jar/jetty/start.jar \
    jetty.home=/jar/jetty jetty.base=/jar/jetty/demo-base
````

Change `xen` to kvm or qemu depending on your VM hypervisor.

`java.io.tmpdir` should be set as writable path because `jetty` extracts war file to the path.


Known issues
============

For now, only main libraries to execute java applications are included, so some of them such as jdb and hprof cannot be used.

Java looks for libraries based on the location of java binary. But java binary is not included in the image so it will search from `JAVA_HOME/jre/lib`.

Jsig library is not used which makes directly send all signals to Rump instead of signal chaining.

X11, freetype, and alsa libraries are not necessary and it only works as headless. It may be a problem because some of the headless java server applications need packages for serving to clients.

Hotspot VM is only working properly as zero and it needs libffi. It can also be built as Server but there are bugs related to page fault errors. It may be caused by assembly code jumping to garbage address but it is hard to debug because of limited debugging environment.

`dlopen` and `dlsym` cannot be used because 'Rump' doesn't support shared libraries. So, those are changed to customized functions looking up symbols in binary. `dlopen` will return `0xdeadbeef` to avoid checking null. It may be a problem later. `dlsym` looks for symbol name defined in `nativeSymbolMap.h` which is manually added using `grep` and `sed`.
