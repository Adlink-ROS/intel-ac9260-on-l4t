#!/bin/bash

set -eu

echo "*** Installing Bluetooth driver ***"
bash install-bluetooth.sh

echo "*** Installing WiFi driver ***"
bash install-wifi.sh --skip


