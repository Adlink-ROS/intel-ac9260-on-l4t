#!/bin/bash

echo "Preparing the kernel headers"
apt update
apt install -y bc
cd /lib/modules/$(uname -r)/source
make oldconfig # generate .config if it's not existed
BSP_VERSION=$(echo $(uname -r) | cut -d"-" -f2)
if [ ${BSP_VERSION: -1} == '+' ]; then
    sed -i "s/CONFIG_LOCALVERSION=\"-${BSP_VERSION:0:-1}\"$/CONFIG_LOCALVERSION=\"-$BSP_VERSION\"/g" .config
fi
make prepare && make prepare scripts

