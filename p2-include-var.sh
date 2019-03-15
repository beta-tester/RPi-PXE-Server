#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################


######################################################################
######################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
######################################################################
######################################################################
CUSTOM_LANG=de
CUSTOM_LANG_LONG=de_DE
CUSTOM_LANG_UPPER=DE
CUSTOM_LANG_WRITTEN=German
CUSTOM_LANG_EXT=de-latin1-nodeadkeys
CUSTOM_TIMEZONE=Europe/Berlin
######################################################################
RPI_SN0=--------
RPI_SN0_BOOT=rpi-$RPI_SN0-boot
RPI_SN0_ROOT=rpi-$RPI_SN0-root
######################################################################
INTERFACE_ETH0=
INTERFACE_BR0=br0
##########################################################################
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1:1.0/net ]; then
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1:1.0/net)
fi
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/*/1-1.1.1:1.0/net ]; then
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/*/1-1.1.1:1.0/net)
fi
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/soc/*.usb/usb1/1-1/*/1-1.1\:1.0/net ]; then
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/*/1-1.1\:1.0/net)
fi
######################################################################
IP_ETH0=$(ip -4 address show dev $INTERFACE_ETH0 | grep -o -E '(([0-9]{1,3}[\.]){3}[0-9]{1,3})' | sed '1!d')
IP_ETH0_=$(echo $IP_ETH0 | grep -E -o "([0-9]{1,3}[\.]){3}")
IP_ETH0_0=$(echo $(echo $IP_ETH0_)0)
IP_ETH0_START=$(echo $(echo $IP_ETH0_)200)
IP_ETH0_END=$(echo $(echo $IP_ETH0_)250)
IP_ETH0_ROUTER=$(echo $(ip rout show dev $INTERFACE_ETH0 | grep default | cut -d' ' -f3))
IP_ETH0_DNS=$IP_ETH0_ROUTER
IP_ETH0_MASK=255.255.255.0
IP_BR0=192.168.250.1
IP_BR0_START=192.168.250.200
IP_BR0_END=192.168.250.250
IP_BR0_MASK=255.255.255.0
######################################################################
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
######################################################################
DST_PXE_BIOS=menu-bios
DST_PXE_EFI32=menu-efi32
DST_PXE_EFI64=menu-efi64
