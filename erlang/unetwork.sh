#!/bin/sh
ip link list dev tap0 >/dev/null 2>/dev/null && {
  sudo ip link set dev tap0 down
  sudo ip tuntap del dev tap0 mode tap
}
