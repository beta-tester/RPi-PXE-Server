#!/bin/bash

##########################################################################
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
# clonezilla    http://clonezilla.org/
#
# v2017-12-01
#
# known issues:
#

#bridge#


##########################################################################
echo -e "\e[36msetup variables\e[0m";

##########################################################################
##########################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
##########################################################################
##########################################################################
RPI_SN0=--------
RPI_SN1=--------
RPI_SN2=--------
RPI_SN3=--------
##########################################################################
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net)
INTERFACE_ETH1=eth1
##########################################################################
IP_ETH0=$(ip -4 address show dev $INTERFACE_ETH0 | grep -o -E '(([0-9]{1,3}[\.]){3}[0-9]{1,3})' | sed '1!d')
IP_ETH0_=$(echo $IP_ETH0 | grep -o -E '([0-9]{1,3}[\.]){3}')
IP_ETH0_0=$(echo $(echo $IP_ETH0_)0)
IP_ETH0_START=$(echo $(echo $IP_ETH0_)200)
IP_ETH0_END=$(echo $(echo $IP_ETH0_)250)
IP_ETH0_ROUTER=$(echo $(ip rout show  dev $INTERFACE_ETH0 | grep default | cut -d' ' -f3))
IP_ETH0_DNS=$IP_ETH0_ROUTER
IP_ETH0_MASK=255.255.255.0
##########################################################################
IP_ETH1=192.168.250.1
IP_ETH1_START=192.168.250.100
IP_ETH1_END=192.168.250.100
IP_ETH1_MASK=255.255.255.0
##########################################################################
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
##########################################################################
DST_PXE_BIOS=menu-bios
DST_PXE_EFI32=menu-efi32
DST_PXE_EFI64=menu-efi64
##########################################################################
KERNEL_MAJOR=$(cat /proc/version | awk '{print $3}' | awk -F . '{print $1}')
KERNEL_MINOR=$(cat /proc/version | awk '{print $3}' | awk -F . '{print $2}')
KERNEL_VER=$((KERNEL_MAJOR*100 + KERNEL_MINOR))

echo
echo -e "$KERNEL_MAJOR.$KERNEL_MINOR \e[36mis kernel version\e[0m";
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

sudo umount -f $SRC_MOUNT 2> /dev/null;
sudo mount $SRC_MOUNT 2> /dev/null;

##########################################################################
##########################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
##########################################################################
##########################################################################
WIN_PE_X86=win-pe-x86
WIN_PE_X86_URL=

UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-amd64.iso

UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-i386.iso

UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=http://releases.ubuntu.com/17.10/ubuntu-17.10-desktop-amd64.iso

UBUNTU_X86=ubuntu-x86
UBUNTU_X86_URL=http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-i386.iso

UBUNTU_NONPAE=ubuntu-nopae
UBUNTU_NONPAE_URL=

DEBIAN_X64=debian-x64
DEBIAN_X64_URL=http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.2.0-amd64-lxde.iso

DEBIAN_X86=debian-x86
DEBIAN_X86_URL=http://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.2.0-i386-lxde.iso

GNURADIO_X64=gnuradio-x64
GNURADIO_X64_URL=http://s3-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso

DEFT_X64=deft-x64
DEFT_X64_URL=http://na.mirror.garr.it/mirrors/deft/deft-8.2.iso

DEFTZ_X64=deftz-x64
DEFTZ_X64_URL=http://na.mirror.garr.it/mirrors/deft/zero/deftZ-2017-1.iso

KALI_X64=kali-x64
KALI_X64_URL=http://cdimage.kali.org/kali-2017.3/kali-linux-2017.3-amd64.iso

PENTOO_X64=pentoo-x64
PENTOO_X64_URL=http://mirror.switch.ch/ftp/mirror/pentoo/Pentoo_amd64_default/pentoo-amd64-default-2015.0_RC5.iso

SYSTEMRESCTUE_X86=systemrescue-x86
SYSTEMRESCTUE_X86_URL=https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.1.2/systemrescuecd-x86-5.1.2.iso

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=

TINYCORE_x64=tinycore-x64
TINYCORE_x64_URL=http://tinycorelinux.net/8.x/x86_64/release/TinyCorePure64-8.2.1.iso

TINYCORE_x86=tinycore-x86
TINYCORE_x86_URL=http://tinycorelinux.net/8.x/x86/release/TinyCore-8.2.1.iso

RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=http://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2017-12-01/2017-11-16-rpd-x86-stretch.iso

CLONEZILLA_X64=clonezilla-x64
CLONEZILLA_X64_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.2-31/clonezilla-live-2.5.2-31-amd64.iso

CLONEZILLA_X86=clonezilla-x86
CLONEZILLA_X86_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.2-31/clonezilla-live-2.5.2-31-i686.iso

FEDORA_X64=fedora-x64
FEDORA_X64_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/26/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-26-1.5.iso

TAILS_X64=tails-x64
TAILS_X64_URL=https://mirrors.kernel.org/tails/stable/tails-amd64-3.3/tails-amd64-3.3.iso

CENTOS_X64=centos-x64
CENTOS_X64_URL=http://ftp.rrzn.uni-hannover.de/centos/7/isos/x86_64/CentOS-7-x86_64-LiveGNOME-1708.iso


##########################################################################
##########################################################################
## url to zip files,
##  that contains disk images
##  for raspbarry pi 3 pxe network booting
## note:
##  update the url, if disk image is outdated
##########################################################################
##########################################################################
PI_CORE=pi-core
PI_CORE_URL=http://tinycorelinux.net/9.x/armv7/releases/RPi/piCore-9.0.3.zip

RPD_LITE=rpi-raspbian-lite
RPD_LITE_URL=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/2017-11-29-raspbian-stretch-lite.zip

RPD_FULL=rpi-raspbian-full
RPD_FULL_URL=https://downloads.raspberrypi.org/raspbian/images/raspbian-2017-12-01/2017-11-29-raspbian-stretch.zip


##########################################################################
handle_dhcpcd() {
    echo -e "\e[32mhandle_dhcpcd()\e[0m";

    ######################################################################
    if grep -q stretch /etc/*-release; then
        echo -e "\e[36m    a stretch os detected\e[0m";
        ##################################################################
        grep -q mod_install_server /etc/dhcpcd.conf || {
        echo -e "\e[36m    setup dhcpcd.conf\e[0m";
        sudo sh -c "cat << EOF  >> /etc/dhcpcd.conf
########################################
## mod_install_server
interface $INTERFACE_ETH0
static ip_address=$IP_ETH0/24
static routers=$IP_ETH0_ROUTER
static domain_name_servers=$IP_ETH0_ROUTER

########################################
interface $INTERFACE_ETH1
static ip_address=$IP_ETH1/24
static routers=$IP_ETH1_ROUTER
static domain_name_servers=$IP_ETH1_ROUTER

########################################
#bridge#interface $INTERFACE_BR0
#bridge#static ip_address=$IP_BR0/24
#bridge#static routers=$IP_BR0_ROUTER
#bridge#static domain_name_servers=$IP_BR0_ROUTER
EOF";
        sudo systemctl daemon-reload;
        sudo systemctl restart dhcpcd.service;
        }
    else
        echo -e "\e[36m    a non-stretch os detected\e[0m";
        ##################################################################
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

auto $INTERFACE_ETH1
iface $INTERFACE_ETH1 inet static
    address $IP_ETH1
    netmask $IP_ETH1_MASK
    gateway $IP_ETH1_ROUTER
    hwaddress 88:88:88:11:11:11

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


##########################################################################
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
interface=$INTERFACE_ETH1
#bridge#interface=$INTERFACE_BR0

# TFTP_ETH0 (enabled)
enable-tftp
tftp-lowercase
tftp-root=$DST_TFTP_ETH0/, $INTERFACE_ETH0
dhcp-option=$INTERFACE_ETH0, option:tftp-server, $IP_ETH0
#nat#tftp-root=$DST_TFTP_ETH1/, $INTERFACE_ETH1
#nat#dhcp-option=$INTERFACE_ETH1, option:tftp-server, $IP_ETH1
#bridge#tftp-root=$DST_TFTP_BR0/, $INTERFACE_BR0
#bridge#dhcp-option=$INTERFACE_BR0, option:tftp-server, $IP_BR0

# DHCP
# do not give IPs that are in pool of DSL routers DHCP
dhcp-range=$INTERFACE_ETH0, $IP_ETH0_START, $IP_ETH0_END, 24h
dhcp-range=$INTERFACE_ETH1, $IP_ETH1_START, $IP_ETH1_END, 24h
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


##########################################################################
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
    path = $DST_ROOT/
    comment = /srv folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = yes
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mask = 0644
    force directory mask = 0755
    force user = root
    force group = root
    hide dot files = no

[media]
    path = /media/
    comment = /media folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = yes
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mask = 0644
    force directory mask = 0755
    force user = root
    force group = root
    hide dot files = no
EOF"
    sudo systemctl restart smbd.service;
    )
}


##########################################################################
handle_pxe_menu() {
    # $1 : menu short name
    # $2 : menu file name
    ######################################################################
    local FILE_MENU=$DST_TFTP_ETH0/$1/pxelinux.cfg/$2
    ######################################################################
    ## INFO:
    ## The entry before -- means that it will be used by the live system / the installer
    ## The entry after -- means that it will be carried to and used by the installed system
    ## https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/kernel-parameters.txt
    ##
    ## some debian/ubuntu parameter
    ## https://www.debian.org/releases/stretch/example-preseed.txt
    ## https://www.debian.org/releases/stretch/amd64/apb.html.en
    ## https://www.debian.org/releases/stretch/amd64/ch05s03.html.en
    ## https://manpages.debian.org/stretch/live-config-doc/live-config.7.en.html
    ## http://manpages.ubuntu.com/manpages/precise/man7/live-config.7.html
    ######################################################################
    echo -e "\e[32mhandle_pxe_menu(\e[0m$1\e[32m)\e[0m";
    echo -e "\e[36m    setup sys menu for pxe\e[0m";
    if ! [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then sudo mkdir -p $DST_TFTP_ETH0/$1/pxelinux.cfg; fi
    if [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then
        sudo sh -c "cat << EOF  > $FILE_MENU
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
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X64 ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X86 ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$UBUNTU_X64/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X64 ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$UBUNTU_X86/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X86 ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_NONPAE ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$DEBIAN_X64/live/initrd.img-4.9.0-3-amd64 netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X64 ro boot=live config -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
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
    APPEND initrd=$NFS_ETH0/$DEBIAN_X86/live/initrd.img-4.9.0-3-686 netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86 ro boot=live config -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
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
    APPEND initrd=$NFS_ETH0/$GNURADIO_X64/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$GNURADIO_X64 ro file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
    APPEND initrd=$NFS_ETH0/$KALI_X64/live/initrd.img netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$KALI_X64 ro boot=live noconfig=sudo username=root hostname=kali -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
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
    APPEND initrd=$NFS_ETH0/$DEFT_X64/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFT_X64 ro file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
    TEXT HELP
        Boot to DEFT x64 Live
        User: root, Password: toor
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEFTZ_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $DEFTZ_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL DEFT Zero x64
    KERNEL $NFS_ETH0/$DEFTZ_X64/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$DEFTZ_X64/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFTZ_X64 ro file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
    TEXT HELP
        Boot to DEFT Zero x64 Live
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
    APPEND initrd=$NFS_ETH0/$PENTOO_X64/isolinux/pentoo.igz nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc aufs looptype=squashfs loop=/image.squashfs cdroot nox --
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
    APPEND initrd=$NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/initram.igz netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCTUE_X86 ro dodhcp -- setkmap=de
    TEXT HELP
        Boot to System Rescue x86 Live
        User: root
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
    APPEND initrd=$NFS_ETH0/$DESINFECT_X86/casper/initrd.lz netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X86 ro file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 rmdns -- debian-installer/language=de console-setup/layoutcode=de keyboard-configuration/layoutcode=de keyboard-configuration/variant=German
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
# INFO: http://wiki.tinycorelinux.net/wiki:boot_options
LABEL tiny core x64
    KERNEL $NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64
    APPEND initrd=$NFS_ETH0/$TINYCORE_x64/boot/corepure64.gz nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_x64 ro tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=us
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
# INFO: http://wiki.tinycorelinux.net/wiki:boot_options
LABEL tiny core x86
    KERNEL $NFS_ETH0/$TINYCORE_x86/boot/vmlinuz
    APPEND initrd=$NFS_ETH0/$TINYCORE_x86/boot/core.gz nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_x86 ro tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=us
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
    APPEND initrd=$NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPDESKTOP_X86 ro boot=live config -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
    TEXT HELP
        Boot to Raspberry Pi Desktop
        User: pi, Password: raspberry
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $CLONEZILLA_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Clonezilla x64
    KERNEL $NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$CLONEZILLA_X64/live/initrd.img netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X64 ro boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
    TEXT HELP
        Boot to Clonezilla x64
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $CLONEZILLA_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL Clonezilla x86
    KERNEL $NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$CLONEZILLA_X86/live/initrd.img netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X86 ro boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=de_DE.UTF-8 keyboard-layouts=de utc=no timezone=Europe/Berlin
    TEXT HELP
        Boot to Clonezilla x86
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$CENTOS_X64/isolinux/vmlinuz0" ]; then
        echo  -e "\e[36m    add $CENTOS_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
## INFO: http://people.redhat.com/harald/dracut.html#dracut.kernel
##       https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/chap-installation-server-setup
## NOT WORKING
LABEL CentOS x64
    KERNEL $NFS_ETH0/$CENTOS_X64/isolinux/vmlinuz0
    APPEND initrd=$NFS_ETH0/$CENTOS_X64/isolinux/initrd0.img root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 rootfstype=auto ro rd.live.image rhgb rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=de-latin1-nodeadkeys locale.LANG=de_DE.UTF-8
    TEXT HELP
        Boot to CentOS LiveGNOME
        User: liveuser
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz" ]; then
        echo  -e "\e[36m    add $FEDORA_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
## INFO: http://people.redhat.com/harald/dracut.html#dracut.kernel
## NOT WORKING
LABEL Fedora x64
    KERNEL $NFS_ETH0/$FEDORA_X64/images/pxeboot/vmlinuz
#    APPEND initrd=$NFS_ETH0/$FEDORA_X64/images/pxeboot/initrd.img root=$IP_ETH0:$DST_NFS_ETH0/$FEDORA_X64/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=de-latin1-nodeadkeys locale.LANG=de_DE.UTF-8
    APPEND initrd=$NFS_ETH0/$FEDORA_X64/images/pxeboot/initrd.img root=nfs:$IP_ETH0:$DST_NFS_ETH0/$FEDORA_X64,vers=3 root-path=/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=de-latin1-nodeadkeys locale.LANG=de_DE.UTF-8
#    APPEND initrd=$NFS_ETH0/$FEDORA_X64/images/pxeboot/initrd.img root=live:tftp://$IP_ETH0/menu-bios/nfs/$FEDORA_X64/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=de-latin1-nodeadkeys locale.LANG=de_DE.UTF-8
    TEXT HELP
        Boot to Fedora Workstation Live
        User: liveuser
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$TAILS_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $TAILS_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
## INFO: https://www.com-magazin.de/praxis/nas/multi-boot-nas-server-232864.html?page=10_tails-vom-nas-booten
## NOT WORKING
LABEL Tails x64
    KERNEL $NFS_ETH0/$TAILS_X64/live/vmlinuz
#    APPEND initrd=$NFS_ETH0/$TAILS_X64/live/initrd.img netboot=nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64 ro boot=live config loglevel=7 -- break locales=de_DE.UTF-8 keyboard-layouts=de
    APPEND initrd=$NFS_ETH0/$TAILS_X64/live/initrd.img fetch=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64/live/filesystem.squashfs ro boot=live config live-media=removable nopersistent noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 splash nox11autologin module=Tails quiet
    TEXT HELP
        Boot to Tails x64 Live (modprobe r8169; exit)
    ENDTEXT
EOF";
    fi
}


##########################################################################
handle_pxe() {
    echo -e "\e[32mhandle_pxe()\e[0m";

    ######################################################################
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]            || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    if [ -d "$SRC_TFTP_ETH0" ]; then
        echo -e "\e[36m    copy win-pe stuff\e[0m";
        [ -f "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxeboot.0" ]  || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/pxeboot.0    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
        [ -f "$DST_TFTP_ETH0/bootmgr.exe" ]              || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/bootmgr.exe  $DST_TFTP_ETH0/;
        [ -d "$DST_TFTP_ETH0/boot" ]                     || sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/boot         $DST_TFTP_ETH0/;
    fi
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


##########################################################################
handle_iso() {
    echo -e "\e[32mhandle_iso(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    ######################################################################
    local NAME=$1
    local URL=$2
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    ######################################################################

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
            sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop  0  10' >> /etc/fstab";
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


##########################################################################
handle_zip_img() {
    echo -e "\e[32mhandle_zip_img(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    ######################################################################
    local NAME=$1
    local URL=$2
    local RAW_FILENAME=$(basename $URL .zip)
    local RAW_FILENAME_IMG=$RAW_FILENAME.img
    local RAW_FILENAME_ZIP=$RAW_FILENAME.zip
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_NFS_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local DST_NFS_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local FILE_URL=$NAME.url
    local FILE_IMG=$NAME.img
    ######################################################################

    if ! [ -d "$DST_IMG/" ]; then sudo mkdir -p $DST_IMG/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_ROOT 2> /dev/null;

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
        if ! [ -d "$DST_NFS_BOOT" ]; then
	        echo -e "\e[36m    create image-boot folder\e[0m";
	        sudo mkdir -p $DST_NFS_BOOT;
        fi

        if ! grep -q "$DST_NFS_BOOT" /etc/fstab; then
	        echo -e "\e[36m    add image-boot to fstab\e[0m";
	        sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_BOOT  auto  ro,nofail,auto,loop,offset=$OFFSET_BOOT,sizelimit=$SIZE_BOOT  0  11' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_BOOT" /etc/exports; then
	        echo -e "\e[36m    add image-boot folder to exports\e[0m";
	        sudo sh -c "echo '$DST_NFS_BOOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        ## root
        if ! [ -d "$DST_NFS_ROOT" ]; then
	        echo -e "\e[36m    create image-root folder\e[0m";
	        sudo mkdir -p $DST_NFS_ROOT;
        fi

        if ! grep -q "$DST_NFS_ROOT" /etc/fstab; then
	        echo -e "\e[36m    add image-root to fstab\e[0m";
            sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_ROOT  auto  ro,nofail,auto,loop,offset=$OFFSET_ROOT,sizelimit=$SIZE_ROOT  0  11' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ROOT" /etc/exports; then
	        echo -e "\e[36m    add image-root folder to exports\e[0m";
	        sudo sh -c "echo '$DST_NFS_ROOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        sudo mount $DST_NFS_BOOT;
        sudo exportfs *:$DST_NFS_BOOT;

        sudo mount $DST_NFS_ROOT;
        sudo exportfs *:$DST_NFS_ROOT;
    else
        ## boot
        sudo sed /etc/fstab   -i -e "/$NAME_BOOT/d"
        sudo sed /etc/exports -i -e "/$NAME_BOOT/d"
        ## root
        sudo sed /etc/fstab   -i -e "/$NAME_ROOT/d"
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi
}

##########################################################################
handle_rpi_pxe_customization() {
    echo -e "\e[36m    handle_rpi_pxe_customization()\e[0m";
    ######################################################################
    local DST_CUSTOM_BOOT=$1
    local DST_CUSTOM_ROOT=$2
    local FLAGS=$3
    ######################################################################
    if (echo $FLAGS | grep -q redo); then
        ##################################################################
        if (echo $FLAGS | grep -q cmdline); then
            echo -e "\e[36m    add cmdline file\e[0m";
            sudo sh -c "echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 plymouth.ignore-serial-consoles root=/dev/nfs nfsroot=$IP_ETH0:$DST_NFS_ROOT,vers=3 rootwait rw ip=dhcp elevator=deadline net.ifnames=0 consoleblank=0' > $DST_CUSTOM_BOOT/cmdline.txt";
        fi

        ##################################################################
        if (echo $FLAGS | grep -q config); then
            echo -e "\e[36m    add config file\e[0m";
            sudo sh -c "cat << EOF  > $DST_CUSTOM_BOOT/config.txt
########################################
dtparam=audio=on

max_usb_current=1
#force_turbo=1

disable_overscan=1
hdmi_force_hotplug=1
config_hdmi_boost=4

#hdmi_ignore_cec_init=1
cec_osd_name=NetBoot

#########################################
# standard resolution
hdmi_drive=2

#########################################
##4k@24Hz or 25Hz custom DMT - mode
#hdmi_ignore_edid=0xa5000080
#hdmi_group=2
#hdmi_mode=87
#hdmi_pixel_freq_limit=400000000
#hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 24 0 211190000 3
##hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 25 0 220430000 3
#gpu_mem=128
#framebuffer_width=3840
#framebuffer_height=2160
#max_framebuffer_width=3840
#max_framebuffer_height=2160
EOF";
        fi

        ##################################################################
        if (echo $FLAGS | grep -q ssh); then
            echo -e "\e[36m    add ssh file\e[0m";
            sudo touch $DST_CUSTOM_BOOT/ssh;
        fi

        ##################################################################
        if (echo $FLAGS | grep -q root); then
            ##############################################################
            if (echo $FLAGS | grep -q fstab); then
                echo -e "\e[36m    add fstab file\e[0m";
                sudo sh -c "cat << EOF  > $DST_CUSTOM_ROOT/etc/fstab
########################################
proc  /proc  proc  defaults  0  0
$IP_ETH0:$DST_NFS_ROOT  /      nfs   defaults,nofail,noatime  0  1
$IP_ETH0:$DST_NFS_BOOT  /boot  nfs   defaults,nofail,noatime  0  2
EOF";
            fi

            ##############################################################
            if (echo $FLAGS | grep -q wpa); then
                echo -e "\e[36m    add wpa_supplicant template file\e[0m";
                sudo sh -c "cat << EOF  > $DST_CUSTOM_ROOT/etc/wpa_supplicant/wpa_supplicant.conf
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
                if [ -f "$SRC_BACKUP/wpa_supplicant.conf" ]; then
                    echo -e "\e[36m    add wpa_supplicant file from backup\e[0m";
                    sudo rsync -xa --info=progress2 $SRC_BACKUP/wpa_supplicant.conf  $DST_CUSTOM_ROOT/etc/wpa_supplicant/
                fi
            fi

            ##############################################################
            if (echo $FLAGS | grep -q history); then
                echo -e "\e[36m    add .bash_history file\e[0m";
                sudo sh -c "cat << EOF  > $DST_CUSTOM_ROOT/home/pi/.bash_history
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
                sudo chown 1000:1000 $DST_CUSTOM_ROOT/home/pi/.bash_history;
            fi
        fi
    fi
}

##########################################################################
handle_rpi_pxe_classic() {
    echo -e "\e[32mhandle_rpi_pxe_classic(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : serial number
    # $3 : flags (redo,bootcode,cmdline,config,ssh,root,fstab,wpa,history)
    ######################################################################
    local NAME=$1
    local SN=$2
    local FLAGS=$3
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_SN_BOOT=$SN-boot
    local DST_SN_ROOT=$SN-root
    local SRC_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local SRC_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local DST_NFS_BOOT=$DST_NFS_ETH0/$DST_SN_BOOT
    local DST_NFS_ROOT=$DST_NFS_ETH0/$DST_SN_ROOT
    local FILE_URL=$NAME.url
    ######################################################################
    local DST_CUSTOM_BOOT=$DST_NFS_BOOT
    local DST_CUSTOM_ROOT=$DST_NFS_ROOT
    ######################################################################

    sudo exportfs -u *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;


    ######################################################################
    if (echo $FLAGS | grep -q redo) \
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_UPPER_BOOT/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old boot files\e[0m";
        sudo rm -rf $DST_NFS_BOOT;
        echo -e "\e[36m    delete old root files\e[0m";
        sudo rm -rf $DST_NFS_ROOT;
        sudo sed /etc/fstab -i -e "/$DST_SN_BOOT/d"
        sudo sed /etc/fstab -i -e "/$DST_SN_ROOT/d"
        sudo sed /etc/exports -i -e "/$DST_SN_BOOT/d"
        sudo sed /etc/exports -i -e "/$DST_SN_ROOT/d"
        local FLAGS=$FLAGS,redo
    fi

    ######################################################################
    if ! [ -d "$DST_NFS_BOOT" ]; then
        echo -e "\e[36m    copy boot files\e[0m";
        sudo mkdir -p $DST_NFS_BOOT;
        sudo rsync -xa --info=progress2 $SRC_BOOT/*  $DST_NFS_BOOT/
    fi

    if ! [ -d "$DST_NFS_ROOT" ] \
    && (echo $FLAGS | grep -q root); then
        echo -e "\e[36m    copy root files\e[0m";
        sudo mkdir -p $DST_NFS_ROOT;
        sudo rsync -xa --info=progress2 $SRC_ROOT/*  $DST_NFS_ROOT/
    fi

    sudo cp $DST_IMG/$FILE_URL $DST_LOWER/$FILE_URL;

    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$SN" ]; then sudo ln -s $DST_NFS_BOOT/  $DST_TFTP_ETH0/$SN; fi

    ######################################################################
    handle_rpi_pxe_customization $DST_CUSTOM_BOOT $DST_CUSTOM_ROOT $FLAGS;

    ######################################################################
    if ! grep -q "$DST_NFS_BOOT" /etc/exports; then
        echo -e "\e[36m    add $DST_NFS_BOOT to exports\e[0m";
        sudo sh -c "echo '$DST_NFS_BOOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
    fi
    sudo exportfs *:$DST_NFS_BOOT;

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_NFS_ROOT" /etc/exports; then
            echo -e "\e[36m    add $DST_NFS_ROOT to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ROOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
        fi
        sudo exportfs *:$DST_NFS_ROOT;
    else
        sudo sed /etc/exports -i -e "/$NAME_ROOT/d"
    fi

    ######################################################################
    if ! [ -f "$DST_TFTP_ETH0/bootcode.bin" ]; then
        echo -e "\e[36m    download bootcode.bin for RPi3 network booting\e[0m";
        sudo wget -O $DST_TFTP_ETH0/bootcode.bin  https://github.com/raspberrypi/firmware/raw/stable/boot/bootcode.bin;
    fi
}

##########################################################################
handle_rpi_pxe_overlay() {
    echo -e "\e[32mhandle_rpi_pxe_overlay(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : serial number
    # $3 : flags (redo,bootcode,cmdline,config,ssh,root,fstab,wpa,history)
    ######################################################################
    local NAME=$1
    local SN=$2
    local FLAGS=$3
    local NAME_BOOT=$NAME-boot
    local NAME_ROOT=$NAME-root
    local DST_SN_BOOT=$SN-boot
    local DST_SN_ROOT=$SN-root
    local SRC_BOOT=$DST_NFS_ETH0/$NAME_BOOT
    local SRC_ROOT=$DST_NFS_ETH0/$NAME_ROOT
    local DST_NFS_BOOT=$DST_NFS_ETH0/$DST_SN_BOOT
    local DST_NFS_ROOT=$DST_NFS_ETH0/$DST_SN_ROOT
    local FILE_URL=$NAME.url
    ######################################################################
    local DST_LOWER=/srv/_lo
    local DST_LOWER_BOOT=/srv/_lo/$NAME_BOOT
    local DST_LOWER_ROOT=/srv/_lo/$NAME_ROOT
    local DST_UPPER_BOOT=/srv/_up/$DST_SN_BOOT
    local DST_UPPER_ROOT=/srv/_up/$DST_SN_ROOT
    local DST_WORK_BOOT=/srv/_wk/$DST_SN_BOOT
    local DST_WORK_ROOT=/srv/_wk/$DST_SN_ROOT
    ######################################################################
    local DST_CUSTOM_BOOT=$DST_NFS_BOOT
    local DST_CUSTOM_ROOT=$DST_NFS_ROOT
    ######################################################################

    sudo exportfs -vu *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -vf $DST_NFS_BOOT 2> /dev/null;

    sudo exportfs -vu *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -vf $DST_NFS_ROOT 2> /dev/null;


    ######################################################################
    # NOTE: this folders will maybe shared by other overlayfs as lowerdir.
    if ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_LOWER/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old lowerdir files\e[0m";
        sudo rm -rf $DST_LOWER_BOOT;
        sudo rm -rf $DST_LOWER_ROOT;
        local FLAGS=$FLAGS,redo
    fi
    ######################################################################
    # WORKAROUND: overlayFS can't handle FAT32 file-system,
    # so copy files to a lowerdir, instead of using the FAT32 partition
    # NOTE: this folder will maybe shared by other overlayfs as lowerdir.
    if ! [ -d "$DST_LOWER_BOOT" ]; then
        echo -e "\e[36m    copy boot files to lowerdir\e[0m";
        sudo mkdir -p $DST_LOWER_BOOT;
        sudo rsync -xa --info=progress2 $SRC_BOOT/*  $DST_LOWER_BOOT/
    fi
    ######################################################################
    # WORKAROUND: overlayFS can't handle disk image mount correctly at boot time,
    # so copy files to a lowerdir, instead of using disk image partition
    # NOTE: this folder will maybe shared by other overlayfs as lowerdir.
    if ! [ -d "$DST_LOWER_ROOT" ] \
    && (echo $FLAGS | grep -q root); then
        echo -e "\e[36m    copy root files to lowerdir\e[0m";
        sudo mkdir -p $DST_LOWER_ROOT;
        sudo rsync -xa --info=progress2 $SRC_ROOT/*  $DST_LOWER_ROOT/
    fi
    ######################################################################
    sudo cp $DST_IMG/$FILE_URL $DST_LOWER/$FILE_URL;


    ######################################################################
    if (echo $FLAGS | grep -q redo) \
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_UPPER_BOOT/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old boot files\e[0m";
        sudo rm -rf $DST_NFS_BOOT;
        sudo rm -rf $DST_UPPER_BOOT;
        sudo rm -rf $DST_WORK_BOOT;
        echo -e "\e[36m    delete old root files\e[0m";
        sudo rm -rf $DST_NFS_ROOT;
        sudo rm -rf $DST_UPPER_ROOT;
        sudo rm -rf $DST_WORK_ROOT;
        sudo sed /etc/fstab -i -e "/$DST_SN_BOOT/d"
        sudo sed /etc/fstab -i -e "/$DST_SN_ROOT/d"
        sudo sed /etc/exports -i -e "/$DST_SN_BOOT/d"
        sudo sed /etc/exports -i -e "/$DST_SN_ROOT/d"
        local FLAGS=$FLAGS,redo
    fi

    ######################################################################
    if ! [ -d "$DST_NFS_BOOT" ]; then sudo mkdir -p $DST_NFS_BOOT; fi
    if ! [ -d "$DST_UPPER_BOOT" ]; then sudo mkdir -p $DST_UPPER_BOOT; fi
    if ! [ -d "$DST_WORK_BOOT" ]; then sudo mkdir -p $DST_WORK_BOOT; fi
    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! [ -d "$DST_NFS_ROOT" ]; then sudo mkdir -p $DST_NFS_ROOT; fi
        if ! [ -d "$DST_UPPER_ROOT" ]; then sudo mkdir -p $DST_UPPER_ROOT; fi
        if ! [ -d "$DST_WORK_ROOT" ]; then sudo mkdir -p $DST_WORK_ROOT; fi
    fi


    ######################################################################
    if ! grep -q "$DST_NFS_BOOT" /etc/fstab; then
        echo -e "\e[36m    add image-boot to fstab\e[0m";
        sudo sh -c "echo 'overlay  $DST_NFS_BOOT  overlay  rw,lowerdir=$DST_LOWER_BOOT,upperdir=$DST_UPPER_BOOT,workdir=$DST_WORK_BOOT  0  12' >> /etc/fstab";
        #sudo sh -c "echo 'overlay  $DST_NFS_BOOT  overlay  rw,lowerdir=$DST_LOWER_BOOT,upperdir=$DST_UPPER_BOOT,workdir=$DST_WORK_BOOT,redirect_dir=off,index=off  0  12' >> /etc/fstab";
    fi

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_NFS_ROOT" /etc/fstab; then
            echo -e "\e[36m    add image-root to fstab\e[0m";
            sudo sh -c "echo 'overlay  $DST_NFS_ROOT  overlay  rw,lowerdir=$DST_LOWER_ROOT,upperdir=$DST_UPPER_ROOT,workdir=$DST_WORK_ROOT  0  12' >> /etc/fstab";
            #sudo sh -c "echo 'overlay  $DST_NFS_ROOT  overlay  rw,lowerdir=$DST_LOWER_ROOT,upperdir=$DST_UPPER_ROOT,workdir=$DST_WORK_ROOT,redirect_dir=off,index=off  0  12' >> /etc/fstab";
        fi
    fi


    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$SN" ]; then sudo ln -s $DST_NFS_BOOT/  $DST_TFTP_ETH0/$SN; fi

    ######################################################################
    sudo mount -v $DST_NFS_BOOT;
    if (echo $FLAGS | grep -q root); then sudo mount -v $DST_NFS_ROOT; fi

    ######################################################################
    handle_rpi_pxe_customization $DST_CUSTOM_BOOT $DST_CUSTOM_ROOT $FLAGS;

    ######################################################################
    if ! grep -q "$DST_NFS_BOOT" /etc/exports; then
        echo -e "\e[36m    add $DST_NFS_BOOT to exports\e[0m";
        sudo sh -c "echo '$DST_NFS_BOOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
    fi
    sudo exportfs -v *:$DST_NFS_BOOT;

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_NFS_ROOT" /etc/exports; then
            echo -e "\e[36m    add $DST_NFS_ROOT to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ROOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
        fi
        sudo exportfs -v *:$DST_NFS_ROOT;
    else
        sudo sed /etc/fstab   -i -e "/$DST_SN_ROOT/d"
        sudo sed /etc/exports -i -e "/$DST_SN_ROOT/d"
    fi

    ######################################################################
    if ! [ -f "$DST_TFTP_ETH0/bootcode.bin" ]; then
        echo -e "\e[36m    download bootcode.bin for RPi3 network booting\e[0m";
        sudo wget -O $DST_TFTP_ETH0/bootcode.bin  https://github.com/raspberrypi/firmware/raw/stable/boot/bootcode.bin;
    fi
}


##########################################################################
handle_rpi_pxe() {
   if [ "$2" == "--------" ]; then
        echo -e "\e[36m    skipped: no proper serial number given.\e[0m";
        return 1;
    fi

    if [ $(($KERNEL_VER < 413)) != 0 ]; then
        handle_rpi_pxe_classic  $1 $2 $3;
    else
        handle_rpi_pxe_classic  $1 $2 $3;
        # overlayFS is still not able to export via nfs
        # handle_rpi_pxe_overlay  $1 $2 $3;
    fi
}

##########################################################################
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
    grep -q mod_install_server /etc/sysctrl.conf 2> /dev/null || {
    echo -e "\e[36m    setup sysctrl for bridging\e[0m";
    sudo sh -c "cat << EOF  >> /etc/sysctl.conf
########################################
## mod_install_server
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
#net.ipv6.conf.all.disable_ipv6 = 1
EOF";
    }


    ######################################################################
    ## network bridge
    sudo iptables -t nat --list | grep -q MASQUERADE 2> /dev/null || {
    echo -e "\e[36m    setup iptables for bridging\e[0m";
    sudo iptables -t nat -A POSTROUTING -o $INTERFACE_ETH0 -j MASQUERADE
    sudo dpkg-reconfigure iptables-persistent
    }
}


##########################################################################
sudo mkdir -p $DST_ISO;
sudo mkdir -p $DST_IMG;
sudo mkdir -p $DST_TFTP_ETH0;
sudo mkdir -p $DST_NFS_ETH0;

##########################################################################
handle_dnsmasq;
handle_samba;
handle_optional;
handle_dhcpcd;


##########################################################################
# ###########    ###########    ###########    ###########    ###########
#  #########      #########      #########      #########      #########
#   #######        #######        #######        #######        #######
#    #####          #####          #####          #####          #####
#     ###            ###            ###            ###            ###
#      #              #              #              #              #


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export, install for PXE boot
##########################################################################
##########################################################################
handle_iso  $WIN_PE_X86         $WIN_PE_X86_URL;
handle_iso  $UBUNTU_LTS_X64     $UBUNTU_LTS_X64_URL;
handle_iso  $UBUNTU_LTS_X86     $UBUNTU_LTS_X86_URL;
handle_iso  $UBUNTU_X64         $UBUNTU_X64_URL;
handle_iso  $UBUNTU_X86         $UBUNTU_X86_URL;
handle_iso  $UBUNTU_NONPAE      $UBUNTU_NONPAE_URL;
handle_iso  $DEBIAN_X64         $DEBIAN_X64_URL;
handle_iso  $DEBIAN_X86         $DEBIAN_X86_URL;
handle_iso  $GNURADIO_X64       $GNURADIO_X64_URL;
handle_iso  $DEFT_X64           $DEFT_X64_URL;
handle_iso  $DEFTZ_X64          $DEFTZ_X64_URL;
handle_iso  $KALI_X64           $KALI_X64_URL;
handle_iso  $PENTOO_X64         $PENTOO_X64_URL;
handle_iso  $SYSTEMRESCTUE_X86  $SYSTEMRESCTUE_X86_URL;
handle_iso  $DESINFECT_X86      $DESINFECT_X86_URL;
handle_iso  $TINYCORE_x64       $TINYCORE_x64_URL;
handle_iso  $TINYCORE_x86       $TINYCORE_x86_URL;
handle_iso  $RPDESKTOP_X86      $RPDESKTOP_X86_URL;
handle_iso  $CLONEZILLA_X64     $CLONEZILLA_X64_URL;
handle_iso  $CLONEZILLA_X86     $CLONEZILLA_X86_URL;
handle_iso  $CENTOS_X64         $CENTOS_X64_URL;
handle_iso  $FEDORA_X64         $FEDORA_X64_URL;
handle_iso  $TAILS_X64          $TAILS_X64_URL;
##########################################################################
handle_pxe;


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export
##########################################################################
##########################################################################
handle_zip_img  $PI_CORE   $PI_CORE_URL;
handle_zip_img  $RPD_LITE  $RPD_LITE_URL;
handle_zip_img  $RPD_FULL  $RPD_FULL_URL;
##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to have as pi 3 pxe network booting
##########################################################################
##########################################################################
#handle_rpi_pxe  $PI_CORE  $RPI_SN0  bootcode,config,root;
#handle_rpi_pxe  $RPD_LITE  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history;
handle_rpi_pxe  $RPD_FULL  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history;


#      #              #              #              #              #
#     ###            ###            ###            ###            ###
#    #####          #####          #####          #####          #####
#   #######        #######        #######        #######        #######
#  #########      #########      #########      #########      #########
# ###########    ###########    ###########    ###########    ###########
##########################################################################


##########################################################################
if [ -d "$SRC_ISO" ]; then
    echo -e "\e[32mbackup new iso images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_ISO/*.iso $DST_ISO/*.url  $SRC_ISO/
fi
######################################################################
if [ -d "$SRC_IMG" ]; then
    echo -e "\e[32mbackup new images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_IMG/*.img $DST_IMG/*.url  $SRC_IMG/
fi
##########################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
