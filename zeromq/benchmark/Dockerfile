FROM ubuntu:16.04

MAINTAINER ZeroMQ Project <zeromq@imatix.com>

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git build-essential libtool autoconf automake pkg-config unzip libkrb5-dev

RUN cd /tmp && git clone --depth 1 https://github.com/zeromq/libzmq.git && cd libzmq && ./autogen.sh && ./configure && make

# RUN cd /tmp/libzmq && make check

RUN cd /tmp/libzmq && make install && ldconfig

ADD example1 /bin/example1

ENTRYPOINT ["/bin/example1"]

RUN rm /tmp/* -rf
