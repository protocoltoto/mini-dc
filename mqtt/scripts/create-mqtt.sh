#!/bin/bash
set -e

source .env

echo "== Creating LXC $CTID =="

pct create $CTID local:vztmpl/$TEMPLATE \
  -hostname $HOSTNAME \
  -memory 256 \
  -cores 1 \
  -net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GW \
  -storage $STORAGE \
  -rootfs $STORAGE:4 \
  -unprivileged 1 \
  -features nesting=1 \
  -onboot 1

echo "== Done =="