Overview
========

This packages [Erlang/OTP](http://erlang.se/) for 18.3 the
development environment for building distributed real-time
high-availability systems.

Patches
=======

The patches within the `patches/` sub-directory is primarily to get
ssl working, although in future it'll host some optimizations as
discussed in [Unoptimized Memory Allocation](#unoptimized-memory-allocation) subsection.

Maintainer
----------

github: neeraj9, igalic


Instructions
============

> The Erlang build is tested (though limited) with both openssl and libressl.
> Needless to say the official Erlang document does not mention libressl,
> although from a cursory look at the api of both it appears compatible
> and safe to be used with Erlang.
> The default setting in the rumprun-packages is libressl and in case you
> want to change then edit
> ../config.mk and set RUMPRUN_SSL to openssl.

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
rumprun-bake hw_virtio beam.hw.bin bin/beam
```

The above can be either used in qemu or kvm. In case you
want to use xen then the following commands can be used towards the same.

> Note that the build commands in turn use *rumprun-bake* internally, so be
> sure that you have built the appropriate platform for it to work.
> Additionally rumprun-bake with xen_pv is used in the Makefile.

```
rumprun-bake xen_pv bin/beam.xen_pv.bin bin/beam
```

Now you've got a baked unikernel image.

Setup the networking as follows (if not done already). You can also use our
`network.sh` script:

```shell
$ sudo ./network.sh
```

You are now ready to run your first erlang unikernel. To run the rumpkernel
using qemu, `erlrun.sh`:

```shell
$ ./erlrun.sh --virt=kvm
```

Please peruse the top part of the shell-script for further options.

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

You can do clustering by using an alternative form of the rumprun command.
Notice that when passing `--epmd`, "-no_epmd" is removed and few more arguments
are added ("-s erlpmd_ctl start -s setnodename start ${name}@${ip} ${cookie}".

***n.b.:*** Because erlang is operating in rumprun, a restricted environment,
we cannot simply pass `-name ${name}@${ip} -setcookie ${cookie}` in our
`erlrun.sh` script, and have to resort to using the simple wrapper module
`example/setnodename`.  

It is important to note the name (`--name`) given along with the ip address
(`--ip`).  The ip address must be the same as given to the guest vm otherwise
things will not work. Additionally, the `--cookie` and `--name` are important
as well, as you can see the workflow to connect to this new node (running in
rumprun unikernel).


```shell
$ ./erlrun.sh --epmd --cookie=mycookie
```

Please peruse the top part of the shell-script for further options.

The node "rumprun@10.0.120.101" is now ready, which also runs the echo server.
The following sequence of steps demonstrate it's workability.
Note that while building the target, a local copy of erlang is also built
which can be used for testing on the host. Having said that you can always
install erlang on your host and use it as well (in fact that is better
because then your ctrl-keys and other completion will work which
are disabled in local copy).

> Assuming you are in rumprun-packages/erlang subdirectory.

Start the erlang shell.

```
./build/bin/erl

Eshell V7.3.1 (abort with ^G)
1>

```

And start a local epmd, so that you can talk to the remote (rumprun) node.

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


Now connect to the local instance of epmd while setting name and
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

Or, alternatively, use your own erlang installation and its convenient `erl`
options:

```
$ erl -setcookie mycookie -name linux@10.0.120.100

Starlng/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10] [kernel-poll:false]

Eshell V7.1  (abort with ^G)
(linux@10.0.120.100)1>
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
(linux@10.0.120.100)5> net_adm:ping('rumprun@10.0.120.101').
pong

(linux@10.0.120.100)6> inet:gethostname().
{ok,"linuxhost"}

(linux@10.0.120.100)7> rpc:multicall(['rumprun@10.0.120.101'], inet, gethostname, []).
{[{ok,"rumprun"}],[]}

(linux@10.0.120.100)8> erlang:system_info(system_architecture).
"x86_64-unknown-linux-gnu"

(linux@10.0.120.100)9> rpc:multicall(['rumprun@10.0.120.101'], erlang, system_info, [system_architecture]).
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


(linux@10.0.120.100)11> rpc:multicall(['rumprun@10.0.120.101'], erlang, memory, []).
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
