#!/bin/bash

set -eu
WORK_DIR=`pwd`

# Prepare the kernel headers
if [[ $# -eq 0 ]]; then
	bash kernel-header.sh
fi

# Download backport driver for AC9260
cd $WORK_DIR
if [[ ! -d backport-iwlwifi ]]; then
	echo "Downloading backport driver for AC9260"
	git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git -b release/core46
fi

# Build backport driver
echo "Building backport driver"
cd $WORK_DIR/backport-iwlwifi
make defconfig-iwlwifi-public
make -j$(( $(nproc) + 1 ))
make install

# Download linux firmware
cd $WORK_DIR
if [[ ! -d linux-firmware ]]; then
	echo "Downloading linux-firmware"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
fi

# Copy AC9260 WiFi firmware to system
cp $WORK_DIR/linux-firmware/iwlwifi-9260* /lib/firmware/

# Register backport driver for AC9260
modprobe iwlwifi

echo "Installing Network Manager"
apt update
apt install -y network-manager-gnome rfkill

echo "***************************************************************"
echo " Done! Please reboot the system for the driver to take effect. "
echo "***************************************************************"
