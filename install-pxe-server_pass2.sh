#!/bin/sh

######################################################################
# ubuntu,       http://releases.ubuntu.com/
#               https://help.ubuntu.com/community/Installation/MinimalCD
# debian,       http://cdimage.debian.org/debian-cd/
# gnuradio,     https://wiki.gnuradio.org/index.php/GNU_Radio_Live_SDR_Environment
# kali,         http://www.kali.org/kali-linux-releases/
# deft,         http://www.deftlinux.net/
# pentoo,       http://www.pentoo.ch/download/
# sysrescue,    http://sourceforge.net/projects/systemrescuecd/ (http://www.sysresccd.org/Download/)
# knoppix,      http://www.knopper.net/knoppix-mirrors/index-en.html
# tails         https://tails.boum.org/install/download/openpgp/index.en.html
# winpe,        https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx
# nonpae,       ftp://ftp.heise.de/pub/ct/projekte/ubuntu-nonpae/ubuntu-12.04.4-nonpae.iso
# tinycore,     http://tinycorelinux.net/downloads.html
# rpdesktop,    http://downloads.raspberrypi.org/rpd_x86/images/ (https://www.raspberrypi.org/blog/a-raspbian-desktop-update-with-some-new-programming-tools/)
#
# rpi-raspbian  http://downloads.raspberrypi.org/raspbian/images/
# piCore        http://tinycorelinux.net/9.x/armv6/releases/RPi/
#               http://tinycorelinux.net/9.x/armv7/releases/RPi/
#
# v2017-08-26
#
# known issues:
#

#bridge#


######################################################################
echo -e "\e[36msetup variables\e[0m";

######################################################################
######################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
######################################################################
######################################################################
RPI_SN0=12345678
RPI_SN0_BOOT=rpi-$RPI_SN0-boot
RPI_SN0_ROOT=rpi-$RPI_SN0-root
######################################################################
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net)
INTERFACE_BR0=br0
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
SRC_MOUNT=/media/server/backup
SRC_ISO=$SRC_MOUNT$ISO
SRC_IMG=$SRC_MOUNT$IMG
SRC_TFTP_ETH0=$SRC_MOUNT$TFTP_ETH0
SRC_NFS_ETH0=$SRC_MOUNT$NFS_ETH0
DST_ROOT=/srv
DST_ISO=$DST_ROOT$ISO
DST_IMG=$DST_ROOT$IMG
DST_TFTP_ETH0=$DST_ROOT$TFTP_ETH0
DST_NFS_ETH0=$DST_ROOT$NFS_ETH0
######################################################################
DST_PXE_BIOS=menu-bios
DST_PXE_EFI32=menu-efi32
DST_PXE_EFI64=menu-efi64


echo
echo -e "$INTERFACE_ETH0 \e[36mis used as primary networkadapter for PXE\e[0m";
echo -e "$IP_ETH0 \e[36mis used as primary IP address for PXE\e[0m";
echo -e "$RPI_SN0 \e[36mis used as SN for RPi3 network booting\e[0m";
echo

if [ "$IP_ETH0" == "" ]; then
    echo -e "\e[1;31mIP address not found. please check your ethernet cable.\e[0m";
    exit 1
fi

if [ "$IP_ETH0_ROUTER" == "" ]; then
    echo -e "\e[1;31mrouter IP address not found. please check your router settings.\e[0m";
    exit 1
fi


######################################################################
######################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
######################################################################
######################################################################
WIN_PE_X86=win-pe-x86
WIN_PE_X86_URL=

UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-amd64.iso

UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-i386.iso

UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-amd64.iso

UBUNTU_X86=ubuntu-x86
UBUNTU_X86_URL=http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-i386.iso

UBUNTU_NONPAE=ubuntu-nopae
UBUNTU_NONPAE_URL=

DEBIAN_X64=debian-x64
DEBIAN_X64_URL=http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.1.0-amd64-lxde.iso

DEBIAN_X86=debian-x86
DEBIAN_X86_URL=http://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.1.0-i386-lxde.iso

GNURADIO_X64=gnuradio-x64
GNURADIO_X64_URL=http://s3-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso

DEFT_X64=deft-x64
DEFT_X64_URL=http://na.mirror.garr.it/mirrors/deft/deft-8.2.iso

KALI_X64=kali-x64
KALI_X64_URL=http://cdimage.kali.org/kali-2017.1/kali-linux-2017.1-amd64.iso

PENTOO_X64=pentoo-x64
PENTOO_X64_URL=http://mirror.switch.ch/ftp/mirror/pentoo/Pentoo_amd64_default/pentoo-amd64-default-2015.0_RC5.iso

SYSTEMRESCTUE_X86=systemrescue-x86
SYSTEMRESCTUE_X86_URL=http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.0.4/systemrescuecd-x86-5.0.4.iso

TAILS_X64=tails-x64
TAILS_X64_URL=https://mirrors.kernel.org/tails/stable/tails-amd64-3.1/tails-amd64-3.1.iso

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=

TINYCORE_x86=tinycore-x86
TINYCORE_x86_URL=http://tinycorelinux.net/8.x/x86/release/TinyCore-current.iso

TINYCORE_x64=tinycore-x64
TINYCORE_x64_URL=http://tinycorelinux.net/8.x/x86_64/release/TinyCorePure64-current.iso

RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=http://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2017-06-23/2017-06-22-rpd-x86-jessie.iso


######################################################################
######################################################################
## url to zip files,
##  that contains disk images
##  for raspbarry pi 3 network booting
## note:
##  update the url, if disk image is outdated
######################################################################
######################################################################
PI_CORE=pi-core
PI_CORE_URL=http://tinycorelinux.net/9.x/armv7/releases/RPi/piCore-9.0.3.zip

RPD_LITE=rpi-raspbian-lite
RPD_LITE_URL=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-08-17/2017-08-16-raspbian-stretch-lite.zip

RPD_FULL=rpi-raspbian-full
RPD_FULL_URL=https://downloads.raspberrypi.org/raspbian/images/raspbian-2017-08-17/2017-08-16-raspbian-stretch.zip


######################################################################
handle_dhcpcd() {
    echo -e "\e[32mhandle_dhcpcd()\e[0m";

    ######################################################################
    if grep -q stretch /etc/*-release; then
        echo -e "\e[36m    a stretch os detected\e[0m";
        ######################################################################
        grep -q $INTERFACE_ETH0 /etc/dhcpcd.conf || {
        echo -e "\e[36m    setup dhcpcd.conf\e[0m";
        sudo sh -c "cat << EOF  >> /etc/dhcpcd.conf
########################################
## mod_install_server
interface $INTERFACE_ETH0
static ip_address=$IP_ETH0/24
static routers=$IP_ETH0_ROUTER
static domain_name_servers=$IP_ETH0_ROUTER
EOF";
        sudo systemctl daemon-reload;
        sudo systemctl restart dhcpcd.service;
        }
    else
        echo -e "\e[36m    a non-stretch os detected\e[0m";
        ######################################################################
        grep -q mod_install_server /etc/network/interfaces || {
        echo -e "\e[36m    setup networking, disable dhcpcd\e[0m";
        sudo sh -c "cat << EOF  > /etc/network/interfaces
########################################
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug wlan1
iface wlan1 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

## mod_install_server
auto $INTERFACE_ETH0
iface $INTERFACE_ETH0 inet static
    address $IP_ETH0
    netmask $IP_ETH0_MASK
    gateway $IP_ETH0_ROUTER

#bridge#auto eth1
#bridge#iface eth1 inet static
#bridge#    hwaddress 88:88:88:11:11:11
#bridge#    address 169.254.11.11
#bridge#    netmask 255.255.0.0
#bridge#
#bridge#auto br0
#bridge#iface br0 inet static
#bridge#    bridge_ports eth1 wlan0 wlan1
#bridge#        hwaddress 88:88:88:88:88:88
#bridge#        address $IP_BR0
#bridge#        netmask $IP_BR0_MASK
#bridge#        bridge_stp off       # disable Spanning Tree Protocol
#bridge#        bridge_waitport 0    # no delay before a port becomes available
#bridge#        bridge_fd 0          # no forwarding delay
EOF";

        echo "nameserver $IP_ETH0_DNS" | sudo tee -a /etc/resolv.conf
        sudo chattr +i /etc/resolv.conf
        sudo rm /etc/resolvconf/update.d/dnsmasq
        sudo systemctl disable dhcpcd.service;
        sudo systemctl enable networking.service;
        }
    fi
}


######################################################################
handle_dnsmasq() {
    echo -e "\e[32mhandle_dnsmasq()\e[0m";

    ######################################################################
    [ -f /etc/dnsmasq.d/pxe-server ] || {
    echo -e "\e[36m    setup dnsmasq for pxe\e[0m";
    sudo sh -c "cat << EOF  >> /etc/dnsmasq.d/pxe-server
########################################
#/etc/dnsmasq.d/pxeboot

## mod_install_server

log-dhcp
log-queries

# interface selection
interface=$INTERFACE_ETH0
#bridge#interface=$INTERFACE_BR0

# TFTP_ETH0 (enabled)
enable-tftp
tftp-lowercase
tftp-root=$DST_TFTP_ETH0/, $INTERFACE_ETH0
#bridge#tftp-root=$DST_TFTP_ETH0_BR0/, $INTERFACE_BR0

# DHCP
# do not give IPs that are in pool of DSL routers DHCP
dhcp-range=$INTERFACE_ETH0, $IP_ETH0_START, $IP_ETH0_END, 24h
#bridge#dhcp-range=$INTERFACE_BR0, $IP_BR0_START, $IP_BR0_END, 24h

# DNS (enabled)
port=53
dns-loop-detect

# PXE (enabled)
# warning: unfortunately, a RPi3 identifies itself as of architecture x86PC (x86PC=0)
# luckily the RPi3 seems to use always the same UUID 44444444-4444-4444-4444-444444444444
dhcp-match=set:UUID_RPI3, option:client-machine-id, 00:44:44:44:44:44:44:44:44:44:44:44:44:44:44:44:44
dhcp-match=set:ARCH_0, option:client-arch, 0
dhcp-match=set:x86_UEFI, option:client-arch, 6
dhcp-match=set:x64_UEFI, option:client-arch, 7
dhcp-match=set:x64_UEFI, option:client-arch, 9

# test if it is a RPi3 or a regular x86PC
tag-if=set:ARM_RPI3, tag:ARCH_0, tag:UUID_RPI3
tag-if=set:x86_BIOS, tag:ARCH_0, tag:!UUID_RPI3

pxe-service=tag:ARM_RPI3,0, \"Raspberry Pi Boot   \", bootcode.bin
pxe-service=tag:x86_BIOS,x86PC, \"PXE Boot Menu (BIOS 00:00)\", $DST_PXE_BIOS/pxelinux
pxe-service=6, \"PXE Boot Menu (UEFI 00:06)\", $DST_PXE_EFI32/syslinux
pxe-service=x86-64_EFI, \"PXE Boot Menu (UEFI 00:07)\", $DST_PXE_EFI64/syslinux
pxe-service=9, \"PXE Boot Menu (UEFI 00:09)\", $DST_PXE_EFI64/syslinux

dhcp-boot=tag:ARM_RPI3, bootcode.bin
dhcp-boot=tag:x86_BIOS, $DST_PXE_BIOS/pxelinux.0
dhcp-boot=tag:x86_UEFI, $DST_PXE_EFI32/syslinux.0
dhcp-boot=tag:x64_UEFI, $DST_PXE_EFI64/syslinux.0
EOF";
    sudo systemctl restart dnsmasq.service;
    }
}


######################################################################
handle_samba() {
    echo -e "\e[32mhandle_samba()\e[0m";

    ######################################################################
    grep -q mod_install_server /etc/samba/smb.conf 2> /dev/null || ( \
    echo -e "\e[36m    setup samba\e[0m";
    sudo sed -i /etc/samba/smb.conf -n -e "1,/#======================= Share Definitions =======================/p";
    sudo sh -c "cat << EOF  >> /etc/samba/smb.conf
########################################
## mod_install_server

[srv]
    comment = /srv folder of pxe-server
    path = $DST_ROOT/
    public = yes
    only guest = yes
    browseable = yes
    read only = no
    writeable = yes
    create mask = 0644
    directory mask = 0755
    force create mask = 0644
    force directory mask = 0755
    force user = root
    force group = root

[media]
    comment = /media folder of pxe-server
    path = /media/
    public = yes
    only guest = yes
    browseable = yes
    read only = no
    writeable = yes
    create mask = 0644
    directory mask = 0755
    force create mask = 0644
    force directory mask = 0755
    force user = root
    force group = root
EOF"
    sudo systemctl restart smbd.service;
    )
}


######################################################################
handle_pxe_menu() {
    # $1 : menu short name
    # $2 : menu file name
    ##############################################################
    local FILE_MENU=$DST_TFTP_ETH0/$1/pxelinux.cfg/$2
    ##############################################################
    echo -e "\e[32mhandle_pxe_menu(\e[0m$1\e[32m)\e[0m";
    echo -e "\e[36m    setup sys menu for pxe\e[0m";
    if ! [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then sudo mkdir -p $DST_TFTP_ETH0/$1/pxelinux.cfg; fi
    if [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
# $FILE_MENU

# http://www.syslinux.org/wiki/index.php?title=Menu

DEFAULT /vesamenu.c32
TIMEOUT 600
ONTIMEOUT Boot Local
PROMPT 0
NOESCAPE 1
ALLOWOPTIONS 1

menu color title * #FFFFFFFF *
menu title PXE Boot Menu (menu-bios)
menu rows 20
menu tabmsgrow 24
menu tabmsg [Enter]=boot, [Tab]=edit, [Esc]=return
menu cmdlinerow 24
menu timeoutrow 25
menu color help 1;37;40 #FFFFFFFF *
menu helpmsgrow 26

LABEL Boot Local
    localboot 0
    TEXT HELP
        Boot to local hard disk
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_TFTP_ETH0/$1/pxeboot.0" ]; then
        echo  -e "\e[36m    add $WIN_PE_X86 (PXE)\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Windows PE x86 (PXE)
    PXE /pxeboot.0
    TEXT HELP
        Boot to Windows PE 32bit
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_ISO/$WIN_PE_X86.iso" ]; then
        echo  -e "\e[36m    add $WIN_PE_X86 (ISO)\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Windows PE x86 (ISO)
    KERNEL /memdisk
    APPEND iso
    INITRD $ISO/$WIN_PE_X86.iso
    TEXT HELP
        Boot to Windows PE 32bit ISO ~400MB
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz.efi" ]; then
        echo  -e "\e[36m    add $UBUNTU_LTS_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Ubuntu LTS x64
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu LTS x64 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_LTS_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Ubuntu LTS x86
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu LTS x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_X64/casper/vmlinuz.efi" ]; then
        echo  -e "\e[36m    add $UBUNTU_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Ubuntu x64
    KERNEL $NFS_ETH0/$UBUNTU_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$UBUNTU_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu x64 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_X86/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Ubuntu x86
    KERNEL $NFS_ETH0/$UBUNTU_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_NONPAE\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL  Ubuntu non-PAE x86
    KERNEL $NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_NONPAE  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu non-PAE x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEBIAN_X64/live/vmlinuz-4.9.0-3-amd64" ]; then
        echo  -e "\e[36m    add $DEBIAN_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Debian x64
    KERNEL $NFS_ETH0/$DEBIAN_X64/live/vmlinuz-4.9.0-3-amd64
    APPEND initrd=$NFS_ETH0/$DEBIAN_X64/live/initrd.img-4.9.0-3-amd64  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X64  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Debian x64 Live LXDE
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEBIAN_X86/live/vmlinuz-4.9.0-3-686" ]; then
        echo  -e "\e[36m    add $DEBIAN_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Debian x86
    KERNEL $NFS_ETH0/$DEBIAN_X86/live/vmlinuz-4.9.0-3-686
    APPEND initrd=$NFS_ETH0/$DEBIAN_X86/live/initrd.img-4.9.0-3-686  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Debian x86 Live LXDE
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi" ]; then
        echo  -e "\e[36m    add $GNURADIO_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL GNU Radio x64
    KERNEL $NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$GNURADIO_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$GNURADIO_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to GNU Radio x64 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$KALI_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $KALI_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Kali x64
    KERNEL $NFS_ETH0/$KALI_X64/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$KALI_X64/live/initrd.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$KALI_X64  boot=live  noconfig=sudo  username=root  hostname=kali  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Kali x64 Live
        User: root, Password: toor
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEFT_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $DEFT_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL DEFT x64
    KERNEL $NFS_ETH0/$DEFT_X64/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$DEFT_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFT_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  memtest=4  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to DEFT x64 Live
        User: root, Password: toor
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PENTOO_X64/isolinux/pentoo" ]; then
        echo  -e "\e[36m    add $PENTOO_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Pentoo x64
    KERNEL $NFS_ETH0/$PENTOO_X64/isolinux/pentoo
    APPEND initrd=$NFS_ETH0/$PENTOO_X64/isolinux/pentoo.igz  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 real_root=/dev/nfs  root=/dev/ram0  init=/linuxrc  aufs  looptype=squashfs  loop=/image.squashfs  cdroot  nox  --  keymap=de
    TEXT HELP
        Boot to Pentoo x64 Live
        User: pentoo
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/rescue32" ]; then
        echo  -e "\e[36m    add $SYSTEMRESCTUE_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL System Rescue x86
    KERNEL $NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/rescue32
    APPEND initrd=$NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/initram.igz  netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCTUE_X86  dodhcp  --  setkmap=de
    TEXT HELP
        Boot to System Rescue x86 Live
        User: root
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$TAILS_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $TAILS_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Tails x64
    KERNEL $NFS_ETH0/$TAILS_X64/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$TAILS_X64/live/initrd.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64  boot=live  config  --  break  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Tails x64 Live (modprobe r8169; exit)
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DESINFECT_X86/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $DESINFECT_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL desinfect x86
    KERNEL $NFS_ETH0/$DESINFECT_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$DESINFECT_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  memtest=4  rmdns  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to ct desinfect x86
        User: desinfect
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64" ]; then
        echo  -e "\e[36m    add $TINYCORE_x64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL tiny core x64
    KERNEL $NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64
    APPEND initrd=$NFS_ETH0/$TINYCORE_x64/boot/corepure64.gz  loglevel=3  cde  waitusb=5  __vga=791  --  lang=de  kmap=de
    TEXT HELP
        Boot to tiny core x64
        User: tc
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$TINYCORE_x86/boot/vmlinuz" ]; then
        echo  -e "\e[36m    add $TINYCORE_x86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL tiny core x86
    KERNEL $NFS_ETH0/$TINYCORE_x86/boot/vmlinuz
    APPEND initrd=$NFS_ETH0/$TINYCORE_x86/boot/core.gz  loglevel=3  cde  waitusb=5  __vga=791  --  lang=de  kmap=de
    TEXT HELP
        Boot to tiny core x86
        User: tc
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2" ]; then
        echo  -e "\e[36m    add $RPDESKTOP_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Raspberry Pi Desktop
    KERNEL $NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2
    APPEND initrd=$NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPDESKTOP_X86  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Raspberry Pi Desktop
        User: pi, Password: raspberry
    ENDTEXT
EOF";
    fi
}


######################################################################
handle_iso() {
    # $1 : short name
    # $2 : download ulr
    ##############################################################
    local NAME=$1
    local URL=$2
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    ##############################################################
    echo -e "\e[32mhandle_iso(\e[0m$NAME\e[32m)\e[0m";
    if ! [ -d "$DST_ISO/" ]; then sudo mkdir -p $DST_ISO/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$NAME 2> /dev/null;

    if [ "$URL" == "" ]; then
        if ! [ -f "$DST_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ]; \
        then
            echo -e "\e[36m    copy iso from usb-stick\e[0m";
            sudo rm -f $DST_ISO/$FILE_URL;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_ISO  $DST_ISO;
            sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL  $DST_ISO;
        fi
    else
        if [ -f "$SRC_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ] \
        && grep -q "$URL" $SRC_ISO/$FILE_URL 2> /dev/null \
        && ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null; \
        then
	        echo -e "\e[36m    copy iso from usb-stick\e[0m";
	        sudo rm -f $DST_ISO/$FILE_URL;
	        sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_ISO  $DST_ISO;
	        sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL  $DST_ISO;
        fi

        if ! [ -f "$DST_ISO/$FILE_ISO" ] \
        || ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null; \
        then
	        echo -e "\e[36m    download iso image\e[0m";
	        sudo rm -f $DST_ISO/$FILE_URL;
	        sudo rm -f $DST_ISO/$FILE_ISO;
	        sudo wget -O $DST_ISO/$FILE_ISO  $URL;

            sudo sh -c "echo '$URL' > $DST_ISO/$FILE_URL";
            sudo touch -r $DST_ISO/$FILE_ISO  $DST_ISO/$FILE_URL;
        fi
    fi

    if [ -f "$DST_ISO/$FILE_ISO" ]; then
        if ! [ -d "$DST_NFS_ETH0/$NAME" ]; then
            echo -e "\e[36m    create nfs folder\e[0m";
            sudo mkdir -p $DST_NFS_ETH0/$NAME;
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/fstab; then
            echo -e "\e[36m    add iso image to fstab\e[0m";
            sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[36m    add nfs folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ETH0/$NAME  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        sudo mount $DST_NFS_ETH0/$NAME;
        sudo exportfs *:$DST_NFS_ETH0/$NAME;
    else
        sudo sed /etc/fstab   -i -e "/$NAME/d"
        sudo sed /etc/exports -i -e "/$NAME/d"
    fi
}


######################################################################
handle_zip_img() {
    # $1 : short name
    # $2 : download ulr
    ##############################################################
    local NAME=$1
    local URL=$2
    local RAW_FILENAME=$(basename $URL .zip)
    local RAW_FILENAME_IMG=$RAW_FILENAME.img
    local RAW_FILENAME_ZIP=$RAW_FILENAME.zip
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local DST_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local FILE_URL=$NAME.url
    local FILE_IMG=$NAME.img
    ##############################################################
    echo -e "\e[32mhandle_zip_img(\e[0m$NAME\e[32m)\e[0m";
    if ! [ -d "$DST_IMG/" ]; then sudo mkdir -p $DST_IMG/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_BOOT 2> /dev/null;
    sudo umount -f $DST_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_ROOT 2> /dev/null;
    sudo umount -f $DST_ROOT 2> /dev/null;

    if [ "$URL" == "" ]; then
	    if ! [ -f "$DST_IMG/$FILE_IMG" ] \
	    && [ -f "$SRC_IMG/$FILE_IMG" ] \
	    && [ -f "$SRC_IMG/$FILE_URL" ]; \
	    then
		    echo -e "\e[36m    copy img from usb-stick\e[0m";
		    sudo rm -f $FILE_IMG/$FILE_URL;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_IMG  $DST_IMG;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_URL  $DST_IMG;
	    fi
    else
	    if [ -f "$SRC_IMG/$FILE_IMG" ] \
	    && [ -f "$SRC_IMG/$FILE_URL" ] \
	    && grep -q "$URL" $SRC_IMG/$FILE_URL 2> /dev/null \
	    && ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null; \
	    then
		    echo -e "\e[36m    copy img from usb-stick\e[0m";
		    sudo rm -f $FILE_IMG/$FILE_URL;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_IMG  $DST_IMG;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_URL  $DST_IMG;
	    fi

	    if ! [ -f "$DST_IMG/$FILE_IMG" ] \
	    || ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null; \
	    then
		    echo -e "\e[36m    download image\e[0m";
		    sudo rm -f $DST_IMG/$FILE_IMG;
		    sudo rm -f $DST_IMG/$FILE_URL;
		    sudo wget -O $DST_IMG/$RAW_FILENAME_ZIP  $URL;
		    echo -e "\e[36m    extract image\e[0m";
		    sudo unzip $DST_IMG/$RAW_FILENAME_ZIP  -d $DST_IMG;
		    sudo rm -f $DST_IMG/$RAW_FILENAME_ZIP;
		    sudo mv $DST_IMG/$RAW_FILENAME_IMG  $DST_IMG/$FILE_IMG;

            sudo sh -c "echo '$URL' > $DST_IMG/$FILE_URL";
            sudo touch -r $DST_IMG/$FILE_IMG  $DST_IMG/$FILE_URL;
	    fi
    fi

    if [ -f "$DST_IMG/$FILE_IMG" ]; then
        local OFFSET_BOOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\1 | awk '{print $4}' | sed 's/,//')))
        local SIZE_BOOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\1 | awk '{print $6}' | sed 's/,//')))
        local OFFSET_ROOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\2 | awk '{print $4}' | sed 's/,//')))
        local SIZE_ROOT=$((512*$(sfdisk -d $DST_IMG/$FILE_IMG | grep $DST_IMG/$FILE_IMG\2 | awk '{print $6}' | sed 's/,//')))
        #sfdisk -d $DST_IMG/$FILE_IMG

        sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
        sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"

        ## boot
        if ! [ -d "$DST_BOOT" ]; then
	        echo -e "\e[36m    create image-boot folder\e[0m";
	        sudo mkdir -p $DST_BOOT;
        fi

        if ! grep -q "$DST_BOOT" /etc/fstab; then
	        echo -e "\e[36m    add image-boot to fstab\e[0m";
	        sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_BOOT  auto  ro,nofail,auto,loop,offset=$OFFSET_BOOT,sizelimit=$SIZE_BOOT  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_BOOT" /etc/exports; then
	        echo -e "\e[36m    add image-boot folder to exports\e[0m";
	        sudo sh -c "echo '$DST_BOOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        ## root
        if ! [ -d "$DST_ROOT" ]; then
	        echo -e "\e[36m    create image-root folder\e[0m";
	        sudo mkdir -p $DST_ROOT;
        fi

        if ! grep -q "$DST_ROOT" /etc/fstab; then
	        echo -e "\e[36m    add image-root to fstab\e[0m";
            sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_ROOT  auto  ro,nofail,auto,loop,offset=$OFFSET_ROOT,sizelimit=$SIZE_ROOT  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_ROOT" /etc/exports; then
	        echo -e "\e[36m    add image-root folder to exports\e[0m";
	        sudo sh -c "echo '$DST_ROOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        sudo mount $DST_BOOT;
        sudo exportfs *:$DST_BOOT;

        sudo mount $DST_ROOT;
        sudo exportfs *:$DST_ROOT;
    else
        ## boot
        sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
        sudo sed /etc/exports -i -e "/$NAME_BOOT/d"
        ## root
        sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi
}


######################################################################
handle_network_booting() {
    # $1 : short name
    # $2 : flags (redo,bootcode,cmdline,config,ssh,root,fstab,wpa,history)
    ##############################################################
    local NAME=$1
    local FLAGS=$2
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local SRC_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local SRC_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local DST_BOOT=$DST_NFS_ETH0/$RPI_SN0_BOOT
    local DST_ROOT=$DST_NFS_ETH0/$RPI_SN0_ROOT
    local FILE_URL=$NAME.url
    ##############################################################
    echo -e "\e[32mhandle_network_booting(\e[0m$NAME\e[32m)\e[0m";
    sudo exportfs -u *:$DST_BOOT 2> /dev/null;
    sudo exportfs -u *:$DST_ROOT 2> /dev/null;

    ######################################################################
    if ! [ -d "$DST_BOOT" ]; then sudo mkdir -p $DST_BOOT; fi
    if ! [ -d "$DST_ROOT" ]; then sudo mkdir -p $DST_ROOT; fi

    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$RPI_SN0" ]; then sudo ln -s $DST_BOOT/  $DST_TFTP_ETH0/$RPI_SN0; fi

    ######################################################################
    if (echo $FLAGS | grep -q redo) \
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_BOOT/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old boot files\e[0m";
        sudo rm -rf $DST_BOOT/*;
        echo -e "\e[36m    delete old root files\e[0m";
        sudo rm -rf $DST_ROOT/*;

        ##################################################################
        if ! [ -f "$DST_BOOT/bootcode.bin" ]; then
            echo -e "\e[36m    copy boot files\e[0m";
            sudo rsync -xa --info=progress2 $SRC_BOOT/*  $DST_BOOT/
        fi

        ##################################################################
        if (echo $FLAGS | grep -q cmdline); then
            echo -e "\e[36m    add cmdline file\e[0m";
            sudo sh -c "echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 plymouth.ignore-serial-consoles root=/dev/nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT,vers=3 rw ip=dhcp rootwait net.ifnames=0 elevator=deadline' > $DST_BOOT/cmdline.txt";
        fi

        ##################################################################
        if (echo $FLAGS | grep -q config); then
            echo -e "\e[36m    add config file\e[0m";
            sudo sh -c "cat << EOF  > $DST_BOOT/config.txt
########################################
dtparam=audio=on

max_usb_current=1
#force_turbo=1

disable_overscan=1
hdmi_force_hotplug=1
config_hdmi_boost=4
hdmi_drive=2
cec_osd_name=NetBoot

########################################
##4k@15Hz custom DMT - mode
#gpu_mem=128
#hdmi_group=2
#hdmi_mode=87
#hdmi_cvt 3840 2160 15
#max_framebuffer_width=3840
#max_framebuffer_height=2160
#hdmi_pixel_freq_limit=400000000
EOF";
        fi

        ##################################################################
        if (echo $FLAGS | grep -q ssh); then
            echo -e "\e[36m    add ssh file\e[0m";
            sudo touch $DST_BOOT/ssh;
        fi

        ##################################################################
        if (echo $FLAGS | grep -q root); then
            if ! [ -d "$DST_ROOT/etc" ]; then
                echo -e "\e[36m    copy root files\e[0m";
                sudo rsync -xa --info=progress2 $SRC_ROOT/*  $DST_ROOT/
            fi

            ##############################################################
            if (echo $FLAGS | grep -q fstab); then
                echo -e "\e[36m    add fstab file\e[0m";
                sudo sh -c "cat << EOF  > $DST_ROOT/etc/fstab
########################################
proc  /proc  proc  defaults  0  0
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_BOOT  /boot  nfs   defaults,nofail,noatime  0  2
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT  /      nfs   defaults,nofail,noatime  0  1
EOF";
            fi

            ##############################################################
            if (echo $FLAGS | grep -q wpa); then
                echo -e "\e[36m    add wpa_supplicant template file\e[0m";
                sudo sh -c "cat << EOF  > $DST_ROOT/etc/wpa_supplicant/wpa_supplicant.conf
########################################
country=DE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    # wpa_passphrase <SSID> <PASSWORD>
    #ssid=<ssid>
    #psk=<pks>

    # sudo iwlist wlan0 scan  [essid <SSID>] 
    #bssid=<mac>

    scan_ssid=1
    key_mgmt=WPA-PSK
}
EOF";
                if [ -f "$SRC_MOUNT/wpa_supplicant.conf" ]; then
                    echo -e "\e[36m    add wpa_supplicant file from backup\e[0m";
                    sudo rsync -xa --info=progress2 $SRC_MOUNT/wpa_supplicant.conf  $DST_ROOT/etc/wpa_supplicant/
                fi
            fi

            ##############################################################
            if (echo $FLAGS | grep -q history); then
                echo -e "\e[36m    add .bash_history file\e[0m";
                sudo sh -c "cat << EOF  > $DST_ROOT/home/pi/.bash_history
sudo poweroff
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y --purge autoremove && sudo apt-get -y autoclean && sync && echo Done.
ip route
sudo ip route del default dev eth0
sudo reboot
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase <SSID> <PASSWORD>
sudo iwlist wlan0 scan  [essid <SSID>]
sudo raspi-config
EOF";
                sudo chown 1000:1000 $DST_ROOT/home/pi/.bash_history;
            fi
        fi

        ##################################################################
        sudo cp $DST_IMG/$FILE_URL $DST_BOOT/$FILE_URL;
    fi

    ######################################################################
    if ! grep -q "$DST_BOOT" /etc/exports; then
        echo -e "\e[36m    add $DST_BOOT to exports\e[0m";
        sudo sh -c "echo '$DST_BOOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
    fi
    sudo exportfs *:$DST_BOOT;

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_ROOT" /etc/exports; then
            echo -e "\e[36m    add $DST_ROOT to exports\e[0m";
            sudo sh -c "echo '$DST_ROOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
        fi
        sudo exportfs *:$DST_ROOT;
    else
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi

    ######################################################################
    if (echo $FLAGS | grep -q bootcode); then
        if [ -f "$DST_BOOT/bootcode.bin" ]; then
            echo -e "\e[36m    copy bootcode.bin for RPi3 NETWORK BOOTING\e[0m";
            sudo cp $DST_BOOT/bootcode.bin $DST_TFTP_ETH0/bootcode.bin;
        fi
    fi

    ######################################################################
    if ! [ -f "$DST_TFTP_ETH0/bootcode.bin" ]; then
        echo -e "\e[36m    download bootcode.bin for RPi3 NETWORK BOOTING\e[0m";
        sudo wget -O $DST_TFTP_ETH0/bootcode.bin  https://github.com/raspberrypi/firmware/raw/stable/boot/bootcode.bin;
    fi
}


######################################################################
handle_pxe() {
    echo -e "\e[32mhandle_pxe()\e[0m";

    ######################################################################
    echo -e "\e[36m    copy win-pe stuff\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]            || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    [ -f "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxeboot.0" ]  || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/pxeboot.0    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -f "$DST_TFTP_ETH0/bootmgr.exe" ]              || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/bootmgr.exe  $DST_TFTP_ETH0/;
    [ -d "$DST_TFTP_ETH0/boot" ]                     || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/boot         $DST_TFTP_ETH0/;
    [ -h "$DST_TFTP_ETH0/sources" ]                  || sudo ln -s $DST_NFS_ETH0/$WIN_PE_X86/sources/  $DST_TFTP_ETH0/sources;
    #for SRC in `find /srv/tftp/Boot -depth`
    #do
    #    DST=`dirname "${SRC}"`/`basename "${SRC}" | tr '[A-Z]' '[a-z]'`
    #    if [ "${SRC}" != "${DST}" ]
    #    then
    #        [ ! -e "${DST}" ] && sudo mv -T "${SRC}" "${DST}" || echo "${SRC} was not renamed"
    #    fi
    #done


    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe bios\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxelinux.0" ]   || sudo ln -s /usr/lib/PXELINUX/pxelinux.0                 $DST_TFTP_ETH0/$DST_PXE_BIOS/pxelinux.0;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/ldlinux.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/ldlinux.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/memdisk" ]      || sudo ln -s /usr/lib/syslinux/memdisk                    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                               $DST_TFTP_ETH0/$DST_PXE_BIOS/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/iso" ]          || sudo ln -s $DST_ISO/                                    $DST_TFTP_ETH0/$DST_PXE_BIOS/iso;
    handle_pxe_menu  $DST_PXE_BIOS  default;

    ######################################################################
    #echo -e "\e[36m    setup sys menu files for pxe efi32\e[0m";
    #[ -d "$DST_TFTP_ETH0/$DST_PXE_EFI32" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI32;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/syslinux.0" ]   || sudo ln -s /usr/lib/syslinux/modules/efi32/syslinux.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/syslinux.0;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/ldlinux.e32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/ldlinux.e32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI32/nfs;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI32/iso;
    #handle_pxe_menu  $DST_PXE_EFI32  efidefault;

    ######################################################################
    #echo -e "\e[36m    setup sys menu files for pxe efi64\e[0m";
    #[ -d "$DST_TFTP_ETH0/$DST_PXE_EFI64" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI64;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/syslinux.0" ]   || sudo ln -s /usr/lib/syslinux/modules/efi64/syslinux.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/syslinux.0;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/ldlinux.e64" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/ldlinux.e64   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI64/nfs;
    #[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI64/iso;
    #handle_pxe_menu  $DST_PXE_EFI64  efidefault;
}


######################################################################
handle_optional() {
    echo -e "\e[32mhandle_optional()\e[0m";

    ######################################################################
    #sudo chmod 755 $(find $DST_TFTP_ETH0/ -type d) 2>/dev/null
    #sudo chmod 644 $(find $DST_TFTP_ETH0/ -type f) 2>/dev/null
    #sudo chmod 755 $(find $DST_TFTP_ETH0/ -type l) 2>/dev/null
    #sudo chown -R root:root /srv/ 2>/dev/null
    #sudo chown -R root:root $DST_TFTP_ETH0 2>/dev/null
    #sudo chown -R root:root $DST_TFTP_ETH0/ 2>/dev/null


    ######################################################################
    ## network bridge
    #bridge#grep -q mod_install_server /etc/sysctrl.conf 2> /dev/null || {
    #bridge#echo -e "\e[36m    setup sysctrl for bridging\e[0m";
    #bridge#sudo sh -c "cat << EOF  >> /etc/sysctl.conf
#bridge#########################################
#bridge### mod_install_server
#bridge#net.ipv4.ip_forward=1
#bridge#net.ipv6.conf.all.forwarding=1
#bridge##net.ipv6.conf.all.disable_ipv6 = 1
#bridge#EOF";
    #bridge#}


    ######################################################################
    ## network bridge
    #bridge#sudo iptables -t nat --list | grep -q MASQUERADE 2> /dev/null || {
    #bridge#echo -e "\e[36m    setup iptables for bridging\e[0m";
    #bridge#sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    #bridge#sudo dpkg-reconfigure iptables-persistent
    #bridge#}
}


######################################################################
######################################################################
######################################################################
######################################################################


######################################################################
sudo mkdir -p $DST_ISO;
sudo mkdir -p $DST_IMG;
sudo mkdir -p $DST_TFTP_ETH0;
sudo mkdir -p $DST_NFS_ETH0;

######################################################################
handle_dnsmasq
handle_samba
handle_optional
handle_dhcpcd
######################################################################
######################################################################
######################################################################
######################################################################


######################################################################
######################################################################
## comment out those entries,
##  you don't want to download/mount/export/install for PXE boot
######################################################################
######################################################################
## handle_iso  $WIN_PE_X86        $WIN_PE_X86_URL;
# handle_iso  $UBUNTU_LTS_X64    $UBUNTU_LTS_X64_URL;
# handle_iso  $UBUNTU_LTS_X86    $UBUNTU_LTS_X86_URL;
handle_iso  $UBUNTU_X64        $UBUNTU_X64_URL;
# handle_iso  $UBUNTU_X86        $UBUNTU_X86_URL;
## handle_iso  $UBUNTU_NONPAE     $UBUNTU_NONPAE_URL;
handle_iso  $DEBIAN_X64        $DEBIAN_X64_URL;
# handle_iso  $DEBIAN_X86        $DEBIAN_X86_URL;
# handle_iso  $GNURADIO_X64      $GNURADIO_X64_URL;
# handle_iso  $DEFT_X64          $DEFT_X64_URL;
# handle_iso  $KALI_X64          $KALI_X64_URL;
# handle_iso  $PENTOO_X64        $PENTOO_X64_URL;
# handle_iso  $SYSTEMRESCTUE_X86 $SYSTEMRESCTUE_X86_URL;
## handle_iso  $TAILS_X64         $TAILS_X64_URL;
## handle_iso  $DESINFECT_X86     $DESINFECT_X86_URL;
# handle_iso  $TINYCORE_x64      $TINYCORE_x64_URL;
handle_iso  $TINYCORE_x86      $TINYCORE_x86_URL;
handle_iso  $RPDESKTOP_X86     $RPDESKTOP_X86_URL;
######################################################################
handle_pxe


######################################################################
######################################################################
## comment out those entries,
##  you dont want to download/mount/export
######################################################################
######################################################################
#handle_zip_img  $PI_CORE   $PI_CORE_URL;
handle_zip_img  $RPD_LITE  $RPD_LITE_URL;
#handle_zip_img  $RPD_FULL  $RPD_FULL_URL;
######################################################################
######################################################################
## comment out those entries,
##  you dont want to have as RPi3 network booting
######################################################################
######################################################################
#handle_network_booting  $PI_CORE  bootcode,config
handle_network_booting  $RPD_LITE  bootcode,cmdline,config,ssh,root,fstab,wpa,history
#handle_network_booting  $RPD_FULL  bootcode,cmdline,config,ssh,root,fstab,wpa,history


######################################################################
######################################################################
######################################################################
######################################################################


######################################################################
echo -e "\e[32mbackup new iso images to usb-stick\e[0m";
sudo rsync -xa --info=progress2 $DST_ISO/*.iso $DST_ISO/*.url  $SRC_ISO/
######################################################################
echo -e "\e[32mbackup new images to usb-stick\e[0m";
sudo rsync -xa --info=progress2 $DST_IMG/*.img $DST_IMG/*.url  $SRC_IMG/
######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
