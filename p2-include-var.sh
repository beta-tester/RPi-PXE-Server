#!/bin/bash

########################################################################
if [[ -z "$script_dir" ]]
then
    echo "do not run this script directly !"
    echo "this script is part of p2-update.sh"
    exit -1
fi
########################################################################


########################################################################
########################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
########################################################################
########################################################################
CUSTOM_COUNTRY=DE
CUSTOM_KEYMAP=de-latin1-nodeadkeys
CUSTOM_KMAP=qwertz/de-latin1
CUSTOM_LANGUAGE=de
CUSTOM_LAYOUTCODE=de
CUSTOM_LOCALE=de_DE.UTF-8
CUSTOM_TIMEZONE=Europe/Berlin
CUSTOM_VARIANT=German
########################################################################
RPI_SN0=--------
RPI_SN1=--------
RPI_SN2=--------
RPI_SN3=--------
########################################################################
INTERFACE_ETH0=
INTERFACE_ETH1=eth1
INTERFACE_WLAN0=wlan0
########################################################################
if [[ -z "$INTERFACE_ETH0" ]] && [[ -d /sys/devices/platform/scb/fd580000.genet/net ]]; then
# RPi4B
INTERFACE_ETH0=$(ls /sys/devices/platform/scb/fd580000.genet/net)
fi
if [[ -z "$INTERFACE_ETH0" ]] && [[ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/net ]]; then
# RPi3B+
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/net)
fi
if [[ -z "$INTERFACE_ETH0" ]] && [[ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net ]]; then
# RPi1B rev.1, RPi1B rev.2, RPi1B+, RPi2B, RPi3B
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net)
fi
if [[ -z "$INTERFACE_ETH0" ]]; then
# fallback
INTERFACE_ETH0=eth0
fi
########################################################################
IP_ETH0=$(ip -4 address show dev $INTERFACE_ETH0 | grep -o -E '(([0-9]{1,3}[\.]){3}[0-9]{1,3})' | sed '1!d')
IP_ETH0_=$(echo $IP_ETH0 | grep -o -E '([0-9]{1,3}[\.]){3}')
IP_ETH0_0=$(echo $(echo $IP_ETH0_)0)/24
IP_ETH0_START=$(echo $(echo $IP_ETH0_)200)
IP_ETH0_END=$(echo $(echo $IP_ETH0_)250)
IP_ETH0_ROUTER=$(echo $(ip rout show  dev $INTERFACE_ETH0 | grep default | cut -d' ' -f3))
IP_ETH0_DNS=$IP_ETH0_ROUTER
IP_ETH0_MASK=255.255.255.0
########################################################################
IP_ETH1=192.168.250.1
IP_ETH1_0=192.168.250.0/24
IP_ETH1_START=192.168.250.100
IP_ETH1_END=192.168.250.110
IP_ETH1_MASK=255.255.255.0
########################################################################
IP_WLAN0=192.168.251.1
IP_WLAN0_0=192.168.251.0/24
IP_WLAN0_START=192.168.251.100
IP_WLAN0_END=192.168.251.110
IP_WLAN0_MASK=255.255.255.0
########################################################################
DRIVER_WLAN0=nl80211
COUNTRY_WLAN0=$CUSTOM_COUNTRY
PASSWORD_WLAN0=p@ssw0rd
SSID_WLAN0=wlan0@domain.local
INTERFACE_WLAN0X=wlan0x
PASSWORD_WLAN0X=p@ssw0rd
SSID_WLAN0X=wlan0x@domain.local

########################################################################
ISO=/iso
IMG=/img
TFTP_ETH0=/tftp
NFS_ETH0=/nfs
SRC_MOUNT=/media/server
SRC_BACKUP=$SRC_MOUNT/backup
SRC_ISO=$SRC_BACKUP$ISO
SRC_IMG=$SRC_BACKUP$IMG
SRC_TFTP_ETH0=$SRC_BACKUP$TFTP_ETH0
SRC_NFS_ETH0=$SRC_BACKUP$NFS_ETH0
DST_ROOT=/srv
DST_ISO=$DST_ROOT$ISO
DST_IMG=$DST_ROOT$IMG
DST_TFTP_ETH0=$DST_ROOT$TFTP_ETH0
DST_NFS_ETH0=$DST_ROOT$NFS_ETH0
########################################################################
DST_PXE_BIOS=menu-bios
DST_PXE_EFI32=menu-efi32
DST_PXE_EFI64=menu-efi64
DST_IPXE=menu-ipxe
########################################################################
KERNEL_MAJOR=$(cat /proc/version | awk '{print $3}' | awk -F . '{print $1}')
KERNEL_MINOR=$(cat /proc/version | awk '{print $3}' | awk -F . '{print $2}')
KERNEL_VER=$((KERNEL_MAJOR*100 + KERNEL_MINOR))
OS_VER=$(grep VERSION_ID /etc/*-release |  grep -o '".*"' | sed 's/"//g')
