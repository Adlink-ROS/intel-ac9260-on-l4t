#!/bin/bash

set -eu
WORK_DIR=`pwd`
SOURCE_DIR=/lib/modules/$(uname -r)/source
BUILD_DIR=/lib/modules/$(uname -r)/build/drivers/bluetooth
INSTALL_DIR=/lib/modules/$(uname -r)/updates/drivers/bluetooth
FW_DIR=/lib/firmware/intel

# Prepare the kernel headers
if [[ $# -eq 0 ]]; then
	bash kernel-header.sh
fi

# Install bluetooth manager
echo "Installing bluetooth manager"
sudo apt update
sudo apt install -y wget blueman rfkill
sudo service bluetooth start

# Build bluetooth driver
echo "Building bluetooth driver to support AC9260"
cd $SOURCE_DIR
patch -p1 -N < $WORK_DIR/btusb.patch && true
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth modules_install

# Download linux firmware
cd $WORK_DIR
if [[ ! -d linux-firmware ]]; then
	echo "Downloading linux-firmware"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
fi
mkdir -p $FW_DIR
sudo cp linux-firmware/intel/ibt-18-2.* $FW_DIR/

echo "Registering the new btusb module"
sudo mkdir -p $INSTALL_DIR
sudo cp $BUILD_DIR/btusb.ko $INSTALL_DIR/
sudo modprobe -r btusb
sudo depmod -a
sudo modprobe btusb

echo "***************************************************************"
echo " Done! Please reboot the system for the driver to take effect. "
echo "***************************************************************"
