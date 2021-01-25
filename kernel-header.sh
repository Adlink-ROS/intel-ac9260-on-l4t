#!/bin/bash

echo "Preparing the kernel headers"
apt update
apt install -y bc
cd /lib/modules/$(uname -r)/source
make oldconfig # generate .config if it's not existed
sed -i 's/CONFIG_LOCALVERSION="-v1.0.6"$/CONFIG_LOCALVERSION="-v1.0.6+"/g' .config
make prepare && make prepare scripts

