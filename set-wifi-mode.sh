#!/bin/bash

set -eu
MODULE_PATH="/lib/modules/`uname -r`"
STANDARD_WIFI_DIR="standard_wifi_backup"

function usage () {
    echo "usage :"
    echo "${1} [show|ac9260|standard]"
    echo "  show    : show current support wifi mode is standard or ac9260"
    echo "  ac9260  : set system to support ac9260 wifi module."
    echo "            BCM4365, Realtek and other wifi module will not support"
    echo "  standard: set system to support standard wifi module. AC9260 not support" 
    exit
}

function isAC9260Mode () {
    local found=`find ${MODULE_PATH} -name "compat.ko"`
    if [ "$found" == "" ]; then
	echo "False"
    else
	echo "True"
    fi
}

function setWifiAC9260 () { 
    local isAC9260=$(isAC9260Mode)
    if [ $isAC9260 == "True" ]; then
	echo "Aleady in AC9260 mode"
        exit
    fi

    echo "Installing AC9260 driver"

    # backup standard wifi driver
    mkdir -p ${STANDARD_WIFI_DIR}
    cp -af ${MODULE_PATH}/kernel/drivers/net/wireless/intel ${STANDARD_WIFI_DIR}
    cp -af ${MODULE_PATH}/kernel/net/mac80211 ${STANDARD_WIFI_DIR}
    cp -af ${MODULE_PATH}/kernel/net/wireless ${STANDARD_WIFI_DIR}	

    local check_ac9260=`find . -name "compat.ko"`
    if [ "$check_ac9260" == "" ]; then
	# build and install AC9260 driver
	bash install.sh
    else
	# install AC9260 driver
	cd backport-iwlwifi
	make install
    fi

    depmod -a
    sync
    echo "Please reboot system to support AC9260 backport driver"
}

function setWifiStandard () {
    local isAC9260=$(isAC9260Mode)
    if [ $isAC9260 == "False" ]; then
        echo "Aleady in standard mode"
	exit
    fi

    # remove ac9260 driver
    rm -rf ${MODULE_PATH}/updates/compat/compat.ko
    rm -rf ${MODULE_PATH}/updates/drivers/net/wireless/intel
    rm -rf ${MODULE_PATH}/updates/net/mac80211
    rm -rf ${MODULE_PATH}/updates/net/wireless

    # restore the standard wifi driver
    echo "Restoring the standard WiFi driver"
    cp -af ${STANDARD_WIFI_DIR}/intel ${MODULE_PATH}/kernel/drivers/net/wireless/
    cp -af ${STANDARD_WIFI_DIR}/mac80211 ${MODULE_PATH}/kernel/net/
    cp -af ${STANDARD_WIFI_DIR}/wireless ${MODULE_PATH}/kernel/net/

    depmod -a
    sync
    echo "Please reboot system to support standard WiFi driver"
}

function showWifiStatus () {
    local isAC9260=$(isAC9260Mode)
    if [ $isAC9260 == "True" ]; then
        echo "Current WiFi support : AC9260"
    else
        echo "Current WiFi support : Standard WiFi"
    fi
}

# check permission as root
if [[ `id -u` -ne 0 ]]; then
    echo ""
    echo "Please run as root(sudo command needed)"
    echo ""
fi

if [ $# -ne 1 ]; then
    usage $0
fi

if [ "${1}" = "show" ]; then
    showWifiStatus
elif [ "${1}" = "ac9260" ]; then
    setWifiAC9260
elif [ "${1}" = "standard" ]; then
    setWifiStandard
else
    usage ${0}
fi

