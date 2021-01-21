#!/bin/sh

# Install development tools
apt update
apt install -y bc

# Prepare the kernel headers
cd /lib/modules/$(uname -r)/source
make oldconfig # generate .config if it's not existed
sed -i 's/CONFIG_LOCALVERSION="-v1.0.6"$/CONFIG_LOCALVERSION="-v1.0.6+"/g' .config
make oldconfig && make prepare && make prepare scripts

# Download AC9260 backport driver
mkdir -p ~/intelwifi9260
cd ~/intelwifi9260
git clone https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/backport-iwlwifi.git -b release/core46

# Build AC9260 backport driver
cd ~/intelwifi9260/backport-iwlwifi
make defconfig-iwlwifi-public
make -j6
make install

# Download AC9260 firmware
cd ~/intelwifi9260/backport-iwlwifi
git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/iwlwifi-9260* /lib/firmware/

# Register AC9260 backport driver
modprobe iwlwifi

echo "***************************************************************"
echo " Done! Please reboot the system for the driver to take effect. "
echo "***************************************************************"
