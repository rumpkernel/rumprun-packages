#!/usr/bin/env bash

script_dir="$(dirname "$(readlink -f "$0")")"

show_help() {
cat << EOF
Usage: "${0##*/}" [-h] ...

    -h|--help      display this help and exit
    --erlapp_path  Mountpoint where apps will be placed in rumprun (Default: /apps/erlang)
    --erlhome      Erlang Home. (Default: /tmp)
    --erlpath      Path to erlang installation. (Default: /opt/erlang)
    --ip           Which IP to configure this VM on. (Default 10.0.120.101)
    --virt         virtualization. One of xen, qemu, kvm
    --empd         Enable Empd. Requires the following options:
    --cookie       Set a specific cookie. (Default: mycookie)
    --name         Set a different name. (Default: rumprun)
    --network      DANGER ZONE: Configures the network, will prompt for sudo password
    --module       Module to run. (Default: echoserver)

EOF
}

main() {
  local erlapp_path=/apps/erlang
  local erlhome=/tmp
  local erlpath=/opt/erlang
  local name=rumprun
  local ip=10.0.120.101
  local cookie=mycookie
  local virt=qemu
  local module=echoserver
  local network=
  local empd_opt=-no_epmd
  local epmd_conf=

  local OPTIND=1 # Reset is necessary if getopts was used previously
  while getopts "h-:" opt; do
    case "$opt" in
      h) show_help
        exit 0
        ;;
      -)
        case "$OPTARG" in
          erlapp_path=*) erlapp_path="${OPTARG#*=}" ;;
          erlhome=*)     erlhome="${OPTARG#*=}"     ;;
          erlpath=*)     erlpath="${OPTARG#*=}"     ;;
          ip=*)          ip="${OPTARG#*=}"          ;;
          virt=*)        virt="${OPTARG#*=}"        ;;
          epmd|empd)     empd_opt=''                ;;
          cookie=*)      cookie="${OPTARG#*=}"      ;;
          name=*)        name="${OPTARG#*=}"        ;;
          network)       network=1                  ;;
          module=*)      module="${OPTARG#*=}"      ;;
          *) show_help
            exit 1
          ;;
        esac;;
      *) show_help
        exit 1
        ;;
    esac
  done


  [[ -n "$network" ]] && {
    "$script_dir/network.sh"
    trap true INT
  }

  [[ -z "$empd_opt" ]] && {
    epmd_conf="-s erlpmd_ctl start -s setnodename start $name@$ip $cookie"
  }

  rumprun "$virt" \
     -I if,vioif,'-net tap,script=no,ifname=tap0' \
     -W if,inet,static,"$ip/24" \
     -e ERL_INETRC="$erlpath/erl_inetrc" \
     -b images/erlang.iso,"$erlpath" \
     -b examples/app.iso,"$erlapp_path" \
     -i beam.hw.bin \
       "-- $epmd_opt -root $erlpath/lib/erlang \
        -progname erl -- \
        -home $erlhome -noshell -pa $erlapp_path \
        $epmd_conf -s $module start"

  [[ -n "$network" ]] && {
    "$script_dir/unetwork.sh"
  }
}

main "$@"
