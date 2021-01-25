#!/bin/bash

set -eu
WORK_DIR=`pwd`

# Prepare the kernel headers
if [[ ($# -gt 0) && ($1 = '--skip') ]]; then
	bash kernel-header.sh
fi

# Install bluetooth manager
echo "Installing bluetooth manager"
apt update
apt install -y wget blueman
service bluetooth start

# Build bluetooth driver
echo "Building bluetooth driver to support AC9260"
cd /lib/modules/$(uname -r)/source/
patch -p1 -N < $WORK_DIR/btusb.patch && true
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth modules_install

# Download linux firmware
cd $WORK_DIR
if [[ ! -d linux-firmware ]]; then
	echo "Downloading AC9260 bluetooth firmware"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
fi
mkdir -p /lib/firmware/intel
cp linux-firmware/intel/ibt-18-2.* /lib/firmware/intel/

echo "Registering the new btusb module"
modprobe -r btusb
modprobe btusb

echo "***************************************************************"
echo " Done! Please reboot the system for the driver to take effect. "
echo "***************************************************************"
