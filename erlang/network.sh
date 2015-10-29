#!/bin/sh
ip link list dev tap0 >/dev/null 2>/dev/null || {
  sudo ip tuntap add tap0 mode tap
  sudo ip addr add 10.0.120.100/24 dev tap0
  sudo ip link set dev tap0 up
}
