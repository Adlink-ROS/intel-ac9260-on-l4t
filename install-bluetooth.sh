#!/bin/bash

echo "Installing bluetooth manager"
apt update
apt install -y wget blueman blueman-manager
service bluetooth start

echo "Building bluetooth driver to support AC9260"
cd /lib/modules/$(uname -r)/source/
if [[ ! -f btusb.patch ]]; then
	wget https://raw.githubusercontent.com/yoffy/jetson-nano-kernel/master/btusb.patch
fi
patch -p1 -N < btusb.patch && true
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth
make -j$(( $(nproc) + 1 )) M=drivers/bluetooth modules_install

echo "Downloading AC9260 bluetooth firmware"
cd ~/
if [[ ! -d linux-firmware ]]; then
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
