#!/bin/bash

set -eu

echo "*** Installing WiFi driver ***"
bash install-wifi.sh

echo "*** Installing Bluetooth driver ***"
bash install-bluetooth.sh --skip

