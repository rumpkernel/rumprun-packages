Overview
========

This document will enable you to bake erlang on rumprun and launch
it within qemu, while running in xen falls on the same lines.

Patches
=======

The patches within the `patches/` sub-directory is primarily to get
ssl working, although in future it'll host some optimizations as
discussed in `Unoptimized Memory Allocation`_ subsection.

Instructions
============

Run this `make` from a user account, *not the root account*. At the end of the
installation, the Makefile will build two variants of the build. One is
required for a host, so that the erlang code can be compiled on this
host (.erl) to .beam. There is another one which can be baked for rumprun
kernel.

The build script requires `genisoimage` to create `erlang.iso` image.

Run `make` from the erlang package directory:

```
cd rumprun-packages/erlang
make
```

Examples
========

There are sample erlang applications (echoserver and helloworld) which can
be built via the `make examples`. The details of the build are captured in
the Makefile.

```
make examples
```

Next you'll need a baked image which can be run on qemu (or kvm or xen).

The following build command will generate an image for non-smp, while using
`hw` as the platform.

```
rumpbake hw_virtio beam.hw.bin bin/beam
```

The above can be either used in qemu or kvm. In case you
want to use xen then the following commands can be used towards the same.

> Note that the build commands in turn use *rumpbake* internally, so
> be sure that you have built the appropriate platform for it
> to work. Additionally rumpbake with xen_pv is used in the Makefile.

```
rumpbake xen_pv bin/beam.xen_pv.bin bin/beam
```

Now you've got a baked unikernel image.

Setup the networking as follows (if not done already).

```
sudo ip tuntap add tap0 mode tap
sudo ip addr add 10.0.120.100/24 dev tap0
sudo ip link set dev tap0 up
```

You are now ready to run your first erlang unikernel. To run the rumpkernel using qemu, the following will work:

```
ERLAPP_PATH=/apps/erlang
ERLHOME=/tmp
ERLPATH=/opt/erlang

rumprun qemu \
   -I if,vioif,'-net tap,script=no,ifname=tap0' \
   -W if,inet,static,10.0.120.101/24 \
   -e ERL_INETRC=$ERLPATH/erl_inetrc \
   -b images/erlang.iso,$ERLPATH \
   -b examples/app.iso,$ERLAPP_PATH \
   -i beam.hw.bin \
     "-- -no_epmd -root $ERLPATH/lib/erlang -progname erl -- -home $ERLHOME -noshell -pa $ERLAPP_PATH -s echoserver start"
```

You should see `Echo server started` text printed to your screen.

Now you can connect to the server via telnet as shown below:

```
$ telnet 10.0.120.101 8080
Trying 10.0.120.101...
Connected to 10.0.120.101.
Escape character is '^]'.
GET /
GET /
hello there!
hello there!
^]

telnet> quit
Connection closed.
```

You should replace `qemu` with `kvm` to run under kvm. For xen there will be
equivalent variation and additionally use xen baked unikernel as well.


EPMD (clustering)
-----------------

You can do clustering simply by using an alternative form of the
rumprun command (notice that "-no_epmd" is removed and few more
arguments are added ("-s erlpmd_ctl start -s setnodename ${NAME}@${IP}").

It is important to note the name ($NAME) given along with the ip address ($IP).
The ip address must be the same as given to the guest vm otherwise things will
not work. Additionally, the COOKIE and NAME are important as well, as you can
see the workflow to connect to this new node (running in rumprun unikernel).


```
ERLAPP_PATH=/apps/erlang
ERLHOME=/tmp
ERLPATH=/opt/erlang
NAME=sample
IP=10.0.120.101
COOKIE=mycookie

rumprun qemu \
   -I if,vioif,'-net tap,script=no,ifname=tap0' \
   -W if,inet,static,$IP/24 \
   -e ERL_INETRC=$ERLPATH/erl_inetrc \
   -b images/erlang.iso,$ERLPATH \
   -b examples/app.iso,$ERLAPP_PATH \
   -i beam.hw.bin \
     "-- -root $ERLPATH/lib/erlang -progname erl -- -home $ERLHOME -noshell -pa $ERLAPP_PATH -s erlpmd_ctl start -s setnodename ${NAME}@${IP} $COOKIE -s echoserver start"
```

The node "sample@10.0.120.101" is now ready, which also runs the echo server.
The following sequence of steps demonstrate it's workability.
Note that while building the target, a local copy of erlang is also built
which can be used for testing on the host. Having said that you can always
install erlang on your host and use it as well (in fact that is better
because then your ctrl-keys and other completion will work which
are disabled in local copy).

> Assuming you are in rumprun-packages/erlang subdirectory.

Start the erlang shell.

```
./build/bootstrap/bin/erl -pa build/lib/epmd/ebin

Eshell V7.0  (abort with ^G)
1>

```

Start local empd, so that you can talk to the remote (rumprun) node.

```
erlpmd_ctl:start().
```

You would see the following traces indicating that epmd started
successfully.

```
=INFO REPORT==== 4-Sep-2015::09:21:10 ===
ErlPMD: started.

=WARNING REPORT==== 4-Sep-2015::09:21:10 ===
ErlPMD: info: notify_init while {argv,[{0,0,0,0}],4369,false,false,0,0,0}.

=INFO REPORT==== 4-Sep-2015::09:21:10 ===
ErlPMD listener: started at Ip: 0.0.0.0:4369
```

Now connect to the local instance of empd while setting name and
cookie, which is required for authentication with the remote
rumprun erlang node. Notice that the cookie used is the same
here as well.

> The local ip address is 10.0.120.100, which is as per
> the initial configuration when the tap0 interface
> was created. In case your configuration is different then
> use that ip address instead.


```
net_kernel:start(['linux@10.0.120.100', longnames]).
true = erlang:set_cookie(node(), mycookie).
```

You will see some more traces.

```
=INFO REPORT==== 4-Sep-2015::09:21:21 ===
ErlPMD: alive request from 127.0.0.1:18262 PortNo: 9156, NodeType: 77, Proto: 0, HiVer: 5, LoVer: 5, NodeName: 'linux', Extra: <<>>, Creation: 2.
{ok,<0.40.0>}
```

The node is now ready to talk to the remote rumprun erlang node.
The following sequence of steps demonstrate the connection,
where the rpc:multicall() is used to run commands on
nodes, while local commands are run directly. Additionally, the
first command *ping*, is needless to say very important and
must return "pong" as the reply otherwise there is an issue
in the connection/configuration. Also notice that the erlang
shell prompt is different now indicating distribution mode.


```
(linux@10.0.120.100)5> net_adm:ping('sample@10.0.120.101').
pong

(linux@10.0.120.100)6> inet:gethostname().
{ok,"linuxhost"}

(linux@10.0.120.100)7> rpc:multicall(['sample@10.0.120.101'], inet, gethostname, []).
{[{ok,"rumprun"}],[]}

(linux@10.0.120.100)8> erlang:system_info(system_architecture).
"x86_64-unknown-linux-gnu"

(linux@10.0.120.100)9> rpc:multicall(['sample@10.0.120.101'], erlang, system_info, [system_architecture]).
{["x86_64-rumprun-netbsd"],[]}

(linux@10.0.120.100)10> erlang:memory().
[{total,29547272},
 {processes,3967984},
 {processes_used,3967984},
 {system,25579288},
 {atom,202481},
 {atom_used,188308},
 {binary,30744},
 {code,4690909},
 {ets,292808}]


(linux@10.0.120.100)11> rpc:multicall(['sample@10.0.120.101'], erlang, memory, []).
{[[{total,10866312},
   {processes,4211520},
   {processes_used,4211520},
   {system,6654792},
   {atom,194289},
   {atom_used,161956},
   {binary,33528},
   {code,3908903},
   {ets,249320}]],
 []}
```

Now you can quit the shell as follows, unless you'd like to play more.

```
q().
```

You can start multiple Erlang-rumprun unikernels and play if you like.

There are tons of things that you could do, but then this is just a
small demonstration to show that distributed erlang cluster will
work on rumprun unikernel now.

Customizations
==============

The /opt/erlang
---------------

In case you want to change the /opt/erlang path then
you'll have to change the Makefile, erl_inetrc and all
the manual instructions mentioned in this document.

Notes
=====

DNS
---

At present the erlang configuration inet configuration is tuned
to use file and DNS as a source of resolving ip/host, though untested.

Shortcomings
============

Huge Erlang Support ISO Size
----------------------------

The generated erlang iso is huge (~152MB), which can easily be cut down and
is planned as well in the spirit of rumprun unikernel.

Unoptimized Memory Allocation
-----------------------------

At present there is an unoptimal allocation of memory as a consequence of
erlang alloc interacting with rumprun. This will be fixed in the near
future, but something to be aware of in case you care. The exact amount
of memory wasted is not quantified, because it needs to be fixed anyways.

Unsupported SMP
---------------

SMP binary though available is useless, since rumprun doesn't support it.

The rumpkernel supports SMP, but since rumprun won't support in the forceable
future, so it wont't work.
