# intel-ac9260-on-l4t
Build instructions of Intel AC9260 WiFi and Bluetooth driver on Linux for NVIDIA Tegra

## Instructions
1. Download this repo:
```bash
git clone https://github.com/Adlink-ROS/intel-ac9260-on-l4t.git
```

2. Run installation script:
```bash
cd intel-ac9260-on-l4t
bash install.sh
```

3. Reboot system after seeing 'Done!'

4. Verify the WiFi & Bluetooth
```bash
# It may take one minute to load WiFi driver after you login to the desktop.
# After one minute, execute the command 'rfkill' to find wlan and bluetooth.
rfkill
```

5. Clean unused files to free up the disk space. It will not affect WiFi and Bluetooth
```bash
cd intel-ac9260-on-l4t
rm -rf backport-iwlwifi linux-firmware
```

Note: Please make sure that you are using root privilege to run install.sh

## Verified Hardware Platform
- ADLINK ROScube-Pico-NX
