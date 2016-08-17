#!/bin/sh
set -x
rumprun qemu -i -M 1024 \
    -N java \
    -b ../images/jre.iso,/jdk/jre/lib \
    -b ../images/jar.ffs,/jar \
    -e JAVA_HOME=/jdk \
    -e CLASS_PATH=/jar:/jdk/jre/lib \
    -- ../bin/java.bin -jar /jar/HelloWorld.jar
