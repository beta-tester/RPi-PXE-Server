#!/bin/bash

##########################################################################
# winpe,        https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx
# ubuntu,       http://releases.ubuntu.com/
#               http://cdimage.ubuntu.com/daily-live/current/
# debian,       https://cdimage.debian.org/debian-cd/
# devuan,       https://files.devuan.org/devuan_ascii/desktop-live/
# parrotsec,    https://cdimage.parrotsec.org/parrot/iso/
# gnuradio,     https://wiki.gnuradio.org/index.php/GNU_Radio_Live_SDR_Environment
# kali,         https://www.kali.org/kali-linux-releases/
# deft,         http://www.deftlinux.net/
# pentoo,       http://www.pentoo.ch/download/
# sysrescue,    https://sourceforge.net/projects/systemrescuecd/ (https://www.sysresccd.org/Download/)
# clonezilla    http://clonezilla.org/
# tinycore,     http://tinycorelinux.net/downloads.html
# rpdesktop,    https://downloads.raspberrypi.org/rpd_x86/images/
# fedora,       https://getfedora.org/en/workstation/download/
# nonpae,       ftp://ftp.heise.de/pub/ct/projekte/ubuntu-nonpae/ubuntu-12.04.4-nonpae.iso
# tails,        https://tails.boum.org/install/download/openpgp/index.en.html
# centos,       https://www.centos.org/download/
# opensuse      https://download.opensuse.org/distribution/openSUSE-current/live/
#
# rpi-raspbian  https://downloads.raspberrypi.org/raspbian/images/
# piCore        http://tinycorelinux.net/9.x/armv6/releases/RPi/
#               http://tinycorelinux.net/9.x/armv7/releases/RPi/
#
# v2018-08-26
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

sudo umount -f $SRC_MOUNT
sudo mount $SRC_MOUNT

######################################################################
######################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
######################################################################
##########################################################################
WIN_PE_X86=win-pe-x86
WIN_PE_X86_URL=

UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/16.04/ubuntu-16.04.5-desktop-amd64.iso
UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04/ubuntu-16.04.5-desktop-i386.iso
UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=http://releases.ubuntu.com/18.04/ubuntu-18.04.1-desktop-amd64.iso
UBUNTU_DAILY_X64=ubuntu-daily-x64
UBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/daily-live/pending/cosmic-desktop-amd64.iso
UBUNTU_STUDIO_X64=ubuntu-studio-x64
UBUNTU_STUDIO_X64_URL=http://cdimage.ubuntu.com/ubuntustudio/releases/18.04/release/ubuntustudio-18.04-dvd-amd64.iso

LUBUNTU_X64=lubuntu-x64
LUBUNTU_X64_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04.1-desktop-amd64.iso
LUBUNTU_X86=lubuntu-x86
LUBUNTU_X86_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04.1-desktop-i386.iso
LUBUNTU_DAILY_X64=lubuntu-daily-x64
LUBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/lubuntu/daily-live/pending/cosmic-desktop-amd64.iso

UBUNTU_NONPAE=ubuntu-nopae
UBUNTU_NONPAE_URL=

DEBIAN_KVER=4.9.0-7
DEBIAN_X64=debian-x64
DEBIAN_X64_URL=https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.5.0-amd64-lxde.iso
DEBIAN_X86=debian-x86
DEBIAN_X86_URL=https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.5.0-i386-lxde.iso

DEVUAN_X64=devuan-x64
DEVUAN_X64_URL=https://files.devuan.org/devuan_ascii/desktop-live/devuan_ascii_2.0.0_amd64_desktop-live.iso
DEVUAN_X86=devuan-x86
DEVUAN_X86_URL=https://files.devuan.org/devuan_ascii/desktop-live/devuan_ascii_2.0.0_i386_desktop-live.iso

PARROT_LITE_X64=parrot-lite-x64
PARROT_LITE_X64_URL=https://cdimage.parrotsec.org/parrot/iso/4.1/Parrot-home-4.1_amd64.iso
PARROT_LITE_X86=parrot-lite-x86
PARROT_LITE_X86_URL=https://cdimage.parrotsec.org/parrot/iso/4.1/Parrot-home-4.1_i386.iso
PARROT_FULL_X64=parrot-full-x64
PARROT_FULL_X64_URL=https://cdimage.parrotsec.org/parrot/iso/4.1/Parrot-security-4.1_amd64.iso
PARROT_FULL_X86=parrot-full-x86
PARROT_FULL_X86_URL=https://cdimage.parrotsec.org/parrot/iso/4.1/Parrot-security-4.1_i386.iso

GNURADIO_X64=gnuradio-x64
GNURADIO_X64_URL=https://s3-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso

DEFT_X64=deft-x64
DEFT_X64_URL=https://na.mirror.garr.it/mirrors/deft/deft-8.2.iso
DEFTZ_X64=deftz-x64
DEFTZ_X64_URL=https://na.mirror.garr.it/mirrors/deft/zero/deftZ-2017-1.iso

KALI_X64=kali-x64
KALI_X64_URL=https://cdimage.kali.org/current/kali-linux-2018.3-amd64.iso

PENTOO_X64=pentoo-x64
#PENTOO_X64_URL=https://www.pentoo.ch/isos/latest-iso-symlinks/pentoo-amd64-hardened-latest.iso
PENTOO_X64_URL=https://www.pentoo.ch/isos/Pentoo_amd64_hardened/pentoo-full-amd64-hardened-2018.0_RC8.iso
PENTOO_BETA_X64=pentoo-beta-x64
#PENTOO_BETA_X64_URL=https://pentoo.ch/isos/latest-iso-symlinks/Beta/pentoo-beta-amd64-hardened-latest.iso
PENTOO_BETA_X64_URL=https://www.pentoo.ch/isos/Beta/Pentoo_amd64_hardened/pentoo-full-amd64-hardened-2018.0_RC7.2_p20180730.iso

SYSTEMRESCUE_X86=systemrescue-x86
SYSTEMRESCUE_X86_URL=https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.2.2/systemrescuecd-x86-5.2.2.iso

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=
DESINFECT_X64=desinfect-x64
DESINFECT_X64_URL=

TINYCORE_x64=tinycore-x64
TINYCORE_x64_URL=http://tinycorelinux.net/9.x/x86_64/release/TinyCorePure64-current.iso
TINYCORE_x86=tinycore-x86
TINYCORE_x86_URL=http://tinycorelinux.net/9.x/x86/release/TinyCore-current.iso

RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=https://downloads.raspberrypi.org/rpd_x86_latest

CLONEZILLA_X64=clonezilla-x64
CLONEZILLA_X64_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.6-22/clonezilla-live-2.5.6-22-amd64.iso
CLONEZILLA_X86=clonezilla-x86
CLONEZILLA_X86_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.6-22/clonezilla-live-2.5.6-22-i686.iso

FEDORA_X64=fedora-x64
FEDORA_X64_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/28/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-28-1.1.iso


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
RPD_LITE_URL=https://downloads.raspberrypi.org/raspbian_lite_latest

RPD_FULL=rpi-raspbian-full
RPD_FULL_URL=https://downloads.raspberrypi.org/raspbian_latest




##########################################################################
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

# NTP Server
dhcp-option=$INTERFACE_ETH0, option:ntp-server, 0.0.0.0
#bridge#dhcp-option=$INTERFACE_BR0, option:ntp-server, 0.0.0.0

# TFTP_ETH0 (enabled)
enable-tftp
tftp-lowercase
tftp-root=$DST_TFTP_ETH0/, $INTERFACE_ETH0
#bridge#tftp-root=$DST_TFTP_ETH0_BR0/, $INTERFACE_BR0

# DHCP
# do not give IPs that are in pool of DSL routers DHCP
dhcp-range=$INTERFACE_ETH0, $IP_ETH0_START, $IP_ETH0_END, 24h
#bridge#dhcp-range=$INTERFACE_BR0, $IP_BR0_START, $IP_BR0_END, 24h
dhcp-option=$INTERFACE_ETH0, option:tftp-server, $IP_ETH0
#bridge#dhcp-option=$INTERFACE_BR0, option:tftp-server, $IP_BR0

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
pxe-service=tag:x86_BIOS,x86PC, \"PXE Boot Menu (BIOS 00:00)\", $DST_PXE_BIOS/lpxelinux
pxe-service=6, \"PXE Boot Menu (UEFI 00:06)\", $DST_PXE_EFI32/syslinux.efi
pxe-service=x86-64_EFI, \"PXE Boot Menu (UEFI 00:07)\", $DST_PXE_EFI64/syslinux.efi
pxe-service=9, \"PXE Boot Menu (UEFI 00:09)\", $DST_PXE_EFI64/syslinux.efi

dhcp-boot=tag:ARM_RPI3, bootcode.bin
dhcp-boot=tag:x86_BIOS, $DST_PXE_BIOS/lpxelinux.0
dhcp-boot=tag:x86_UEFI, $DST_PXE_EFI32/syslinux.efi
dhcp-boot=tag:x64_UEFI, $DST_PXE_EFI64/syslinux.efi
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
[global]
# https://www.samba.org/samba/security/CVE-2017-14746.html
server min protocol = SMB2

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
    force create mode = 0644
    force directory mode = 0755
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
    force create mode = 0644
    force directory mode = 0755
    force user = root
    force group = root
EOF"
    sudo systemctl restart smbd.service;
    )
}


handle_chrony() {
    echo -e "\e[32mhandle_chrony()\e[0m";

    ######################################################################
    grep -q mod_install_server /etc/chrony/chrony.conf 2> /dev/null || {
        echo -e "\e[36m    setup chrony\e[0m";
        sudo systemctl stop chronyd.service;
        sudo sh -c "cat << EOF  > /etc/chrony/chrony.conf
########################################
## mod_install_server
allow

server  ptbtime1.ptb.de  iburst
server  ptbtime2.ptb.de  iburst
server  ptbtime3.ptb.de  iburst
server  char-ntp-pool.charite.de
server  isis.uni-paderborn.de
server  ntp1.rrze.uni-erlangen.de  iburst
server  ntp2.rrze.uni-erlangen.de  iburst
server  ntp3.rrze.uni-erlangen.de  iburst
server  ntp1.oma.be  iburst
server  ntp2.oma.be  iburst
server  ntp.certum.pl  iburst
server  ntp1.sp.se  iburst

pool  europe.pool.ntp.org  iburst

keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
logdir /var/log/chrony
maxupdateskew 100.0
hwclockfile /etc/adjtime
rtcsync
makestep 1 3
EOF";
        sudo systemctl restart chronyd.service;
    }
}


##########################################################################
handle_pxe_menu() {
    # $1 : menu short name
    # $2 : menu file name
    ######################################################################
    local FILE_MENU=$DST_TFTP_ETH0/$1/pxelinux.cfg/$2
    local FILE_BASE=http://$(hostname)
    ######################################################################
    ## INFO:
    ## The entry before -- means that it will be used by the live system / the installer
    ## The entry after -- means that it will be carried to and used by the installed system
    ## https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/kernel-parameters.txt
    ######################################################################
    echo -e "\e[32mhandle_pxe_menu(\e[0m$1\e[32m)\e[0m";
    echo -e "\e[36m    setup sys menu for pxe\e[0m";
    if ! [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then sudo mkdir -p $DST_TFTP_ETH0/$1/pxelinux.cfg; fi
    if [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ]; then
        sudo sh -c "cat << EOF  > $FILE_MENU
########################################
# $FILE_MENU

# http://www.syslinux.org/wiki/index.php?title=Menu

DEFAULT vesamenu.c32
#TIMEOUT 600
#ONTIMEOUT localboot
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

########################################
LABEL reboot
    MENU LABEL Reboot
    COM32 reboot.c32
########################################
LABEL poweroff
    MENU LABEL Power Off
    COM32 poweroff.c32
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_TFTP_ETH0/$1/pxeboot.n12" ]; then
        echo  -e "\e[36m    add $WIN_PE_X86 (PXE)\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $WIN_PE_X86-pxe
    MENU LABEL Windows PE x86 (PXE)
    PXE pxeboot.n12
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
LABEL $WIN_PE_X86-iso
    MENU LABEL Windows PE x86 (ISO)
    KERNEL memdisk
    APPEND iso
    INITRD $FILE_BASE$ISO/$WIN_PE_X86.iso
    TEXT HELP
        Boot to Windows PE 32bit ISO ~400MB
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_LTS_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $UBUNTU_LTS_X64
    MENU LABEL Ubuntu LTS x64
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
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
LABEL $UBUNTU_LTS_X86
    MENU LABEL Ubuntu LTS x86
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X86 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu LTS x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $UBUNTU_X64
    MENU LABEL Ubuntu x64
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
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
LABEL $UBUNTU_X86
    MENU LABEL Ubuntu x86
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_X86/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_X86/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X86 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_DAILY_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_DAILY_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $UBUNTU_DAILY_X64
    MENU LABEL Ubuntu x64 Daily-Live
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_DAILY_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_DAILY_X64/casper/initrd
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_DAILY_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu x64 Daily-Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_STUDIO_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_STUDIO_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $UBUNTU_STUDIO_X64
    MENU LABEL Ubuntu Studio x64
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_STUDIO_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_STUDIO_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu Studio x64 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi


    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$LUBUNTU_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $LUBUNTU_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $LUBUNTU_X64
    MENU LABEL lubuntu x64
    KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_X64 ro netboot=nfs file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to lubuntu x64 Live
        User: lubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$LUBUNTU_X86/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $LUBUNTU_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $LUBUNTU_X86
    MENU LABEL lubuntu x86
    KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_X86/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_X86/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_X86 ro netboot=nfs file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to lubuntu x86 Live
        User: lubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$LUBUNTU_DAILY_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $LUBUNTU_DAILY_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $LUBUNTU_DAILY_X64
    MENU LABEL lubuntu x64 Daily-Live
    KERNEL $FILE_BASE$NFS_ETH0/$LUBUNTU_DAILY_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$LUBUNTU_DAILY_X64/casper/initrd
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$LUBUNTU_DAILY_X64 ro netboot=nfs file=/cdrom/preseed/lubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to lubuntu x64 Daily-Live
        User: lubuntu
    ENDTEXT
EOF";
    fi


    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $UBUNTU_NONPAE\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $UBUNTU_NONPAE
    MENU LABEL Ubuntu non-PAE x86
    KERNEL $FILE_BASE$NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_NONPAE ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu non-PAE x86 Live
        User: ubuntu
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEBIAN_X64/live/vmlinuz-$DEBIAN_KVER-amd64" ]; then
        echo  -e "\e[36m    add $DEBIAN_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $DEBIAN_X64
    MENU LABEL Debian x64
    KERNEL $FILE_BASE$NFS_ETH0/$DEBIAN_X64/live/vmlinuz-$DEBIAN_KVER-amd64
    INITRD $FILE_BASE$NFS_ETH0/$DEBIAN_X64/live/initrd.img-$DEBIAN_KVER-amd64
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Debian x64 Live LXDE
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEBIAN_X86/live/vmlinuz-$DEBIAN_KVER-686" ]; then
        echo  -e "\e[36m    add $DEBIAN_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $DEBIAN_X86
    MENU LABEL Debian x86
    KERNEL $FILE_BASE$NFS_ETH0/$DEBIAN_X86/live/vmlinuz-$DEBIAN_KVER-686
    INITRD $FILE_BASE$NFS_ETH0/$DEBIAN_X86/live/initrd.img-$DEBIAN_KVER-686
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Debian x86 Live LXDE
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEVUAN_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $DEVUAN_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $DEVUAN_X64
    MENU LABEL Devuan x64
    KERNEL $FILE_BASE$NFS_ETH0/$DEVUAN_X64/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DEVUAN_X64/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEVUAN_X64 ro netboot=nfs boot=live username=devuan config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Devuan x64 Live
        User: devuan
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DEVUAN_X86/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $DEVUAN_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $DEVUAN_X86
    MENU LABEL Devuan x86
    KERNEL $FILE_BASE$NFS_ETH0/$DEVUAN_X86/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DEVUAN_X86/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEVUAN_X86 ro netboot=nfs boot=live username=devuan config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Devuan x86 Live
        User: devuan
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PARROT_LITE_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $PARROT_LITE_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $PARROT_LITE_X64
    MENU LABEL Parrot Lite x64
    KERNEL $FILE_BASE$NFS_ETH0/$PARROT_LITE_X64/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$PARROT_LITE_X64/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_LITE_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Parrot Lite x64 Live (Home/Workstation)
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PARROT_LITE_X86/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $PARROT_LITE_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $PARROT_LITE_X86
    MENU LABEL Parrot Lite x86
    KERNEL $FILE_BASE$NFS_ETH0/$PARROT_LITE_X86/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$PARROT_LITE_X86/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_LITE_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Parrot Lite x86 Live (Home/Workstation)
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PARROT_FULL_X64/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $PARROT_FULL_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $PARROT_FULL_X64
    MENU LABEL Parrot Full x64
    KERNEL $FILE_BASE$NFS_ETH0/$PARROT_FULL_X64/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$PARROT_FULL_X64/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_FULL_X64 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Parrot Full x64 Live (Security)
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PARROT_FULL_X86/live/vmlinuz" ]; then
        echo  -e "\e[36m    add $PARROT_FULL_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $PARROT_FULL_X86
    MENU LABEL Parrot Full x86
    KERNEL $FILE_BASE$NFS_ETH0/$PARROT_FULL_X86/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$PARROT_FULL_X86/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PARROT_FULL_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG pkeys=$CUSTOM_LANG setxkbmap=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Parrot Full x86 Live (Security)
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi" ]; then
        echo  -e "\e[36m    add $GNURADIO_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $GNURADIO_X64
    MENU LABEL GNU Radio x64
    KERNEL $FILE_BASE$NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi
    INITRD $FILE_BASE$NFS_ETH0/$GNURADIO_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$GNURADIO_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
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
LABEL $KALI_X64
    MENU LABEL Kali x64
    KERNEL $FILE_BASE$NFS_ETH0/$KALI_X64/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$KALI_X64/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$KALI_X64 ro netboot=nfs boot=live noconfig=sudo username=root hostname=kali -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
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
LABEL $DEFT_X64
    MENU LABEL DEFT x64
    KERNEL $FILE_BASE$NFS_ETH0/$DEFT_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DEFT_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFT_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
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
LABEL $DEFTZ_X64
    MENU LABEL DEFT Zero x64
    KERNEL $FILE_BASE$NFS_ETH0/$DEFTZ_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DEFTZ_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFTZ_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
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
LABEL $PENTOO_X64
    MENU LABEL Pentoo x64
    KERNEL $FILE_BASE$NFS_ETH0/$PENTOO_X64/isolinux/pentoo
    INITRD $FILE_BASE$NFS_ETH0/$PENTOO_X64/isolinux/pentoo.igz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc overlayfs looptype=squashfs loop=/image.squashfs cdroot nox secureconsole max_loop=256 dokeymap video=uvesafb:mtrr:3,ywrap,1024x768-16 console=tty0 scsi_mod.use_blk_mq=1 net.ifnames=0 ipv6.autoconf=0 --
    TEXT HELP
        Boot to Pentoo x64 Live
        User: pentoo
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$PENTOO_BETA_X64/isolinux/pentoo" ]; then
        echo  -e "\e[36m    add $PENTOO_BETA_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $PENTOO_BETA_X64
    MENU LABEL Pentoo Beta x64
    KERNEL $FILE_BASE$NFS_ETH0/$PENTOO_BETA_X64/isolinux/pentoo
    INITRD $FILE_BASE$NFS_ETH0/$PENTOO_BETA_X64/isolinux/pentoo.igz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_BETA_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc overlayfs looptype=squashfs loop=/image.squashfs cdroot nox secureconsole max_loop=256 dokeymap video=uvesafb:mtrr:3,ywrap,1024x768-16 console=tty0 scsi_mod.use_blk_mq=1 net.ifnames=0 ipv6.autoconf=0 --
    TEXT HELP
        Boot to Pentoo Beta x64 Live
        User: pentoo
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$SYSTEMRESCUE_X86/isolinux/rescue32" ]; then
        echo  -e "\e[36m    add $SYSTEMRESCUE_X86\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $SYSTEMRESCUE_X86
    MENU LABEL System Rescue x86
    KERNEL $FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X86/isolinux/rescue32
    INITRD $FILE_BASE$NFS_ETH0/$SYSTEMRESCUE_X86/isolinux/initram.igz
    APPEND netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCUE_X86 ro dodhcp -- setkmap=$CUSTOM_LANG
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
LABEL $DESINFECT_X86
    MENU LABEL desinfect x86
    KERNEL $FILE_BASE$NFS_ETH0/$DESINFECT_X86/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DESINFECT_X86/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X86 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 rmdns -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to ct desinfect x86
        User: desinfect
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$DESINFECT_X64/casper/vmlinuz" ]; then
        echo  -e "\e[36m    add $DESINFECT_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
LABEL $DESINFECT_X64
    MENU LABEL desinfect x64
    KERNEL $FILE_BASE$NFS_ETH0/$DESINFECT_X64/casper/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$DESINFECT_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper memtest=4 rmdns -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to ct desinfect x64
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
LABEL $TINYCORE_x64
    MENU LABEL tiny core x64
    KERNEL $FILE_BASE$NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64
    INITRD $FILE_BASE$NFS_ETH0/$TINYCORE_x64/boot/corepure64.gz
    APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_x64 ro tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=us
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
LABEL $TINYCORE_x86
    MENU LABEL tiny core x86
    KERNEL $FILE_BASE$NFS_ETH0/$TINYCORE_x86/boot/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$TINYCORE_x86/boot/core.gz
    APPEND nfsmount=$IP_ETH0:$DST_NFS_ETH0/$TINYCORE_x86 ro tce=/mnt/nfs/cde waitusb=5 vga=791 loglevel=3 -- lang=en kmap=us
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
LABEL $RPDESKTOP_X86
    MENU LABEL Raspberry Pi Desktop
    KERNEL $FILE_BASE$NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2
    INITRD $FILE_BASE$NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPDESKTOP_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
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
LABEL $CLONEZILLA_X64
    MENU LABEL Clonezilla x64
    KERNEL $FILE_BASE$NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$CLONEZILLA_X64/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X64 ro netboot=nfs boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
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
LABEL $CLONEZILLA_X86
    MENU LABEL Clonezilla x86
    KERNEL $FILE_BASE$NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$CLONEZILLA_X86/live/initrd.img
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CLONEZILLA_X86 ro netboot=nfs boot=live config username=user hostname=clonezilla union=overlay components noswap edd=on nomodeset nodmraid ocs_live_run=ocs-live-general ocs_live_extra_param= ocs_live_batch=no net.ifnames=0 nosplash noprompt -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Clonezilla x86
        User: user, Password: live
    ENDTEXT
EOF";
    fi

    if [ -f "$FILE_MENU" ] \
    && [ -f "$DST_NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz" ]; then
        echo  -e "\e[36m    add $FEDORA_X64\e[0m";
        sudo sh -c "cat << EOF  >> $FILE_MENU
########################################
## INFO: http://people.redhat.com/harald/dracut.html#dracut.kernel
##       https://github.com/haraldh/dracut/blob/master/dracut.cmdline.7.asc
##       https://lukas.zapletalovi.com/2016/08/hidden-feature-of-fedora-24-live-pxe-boot.html
LABEL $FEDORA_X64
    MENU LABEL Fedora x64
    KERNEL $FILE_BASE$NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz
    INITRD $FILE_BASE$NFS_ETH0/$FEDORA_X64/isolinux/initrd.img
    APPEND root=live:nfs://$IP_ETH0$DST_NFS_ETH0/$FEDORA_X64/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8
    TEXT HELP
        Boot to Fedora Workstation Live
        User: liveuser
    ENDTEXT
EOF";
    fi
}


##########################################################################
compare_last_modification_time() {
    python3 - << EOF "$1" "$2"
import sys
import os
import urllib.request
import time

try:
    arg_file = sys.argv[1]
    stat_file = os.stat(arg_file)
    time_file = time.gmtime(stat_file.st_mtime)

    arg_url = sys.argv[2]
    conn_url = urllib.request.urlopen(arg_url)
    time_url = time.strptime(conn_url.headers['last-modified'], '%a, %d %b %Y %H:%M:%S %Z')

    if time_url <= time_file:
        exit_code = 0
    else:
        exit_code = 1
except:
    exit_code = 1

sys.exit(exit_code)
EOF
}


##########################################################################
handle_iso() {
    echo -e "\e[32mhandle_iso(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    # $2 : download url
    # $3 : optional/additional mount flags
    ######################################################################
    local NAME=$1
    local URL=$2
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    local DST_ORIGINAL=/srv/tmp/original/$NAME
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
        || ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null \
        || ([ "$3" == "timestamping" ] && ! compare_last_modification_time $DST_ISO/$FILE_ISO $URL); \
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
            if [ "$3" == "timestamping" ]; then
                sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$4  0  10' >> /etc/fstab";
            else
                sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$3  0  10' >> /etc/fstab";
            fi
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[36m    add nfs folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ETH0/$NAME  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        sudo mount $DST_NFS_ETH0/$NAME;
        sudo exportfs *:$DST_NFS_ETH0/$NAME;
    else
        sudo sed /etc/fstab   -i -e "/$NAME/d"
        sudo sed /etc/exports -i -e "/$NAME/d"
    fi
}




##########################################################################
_unhandle_iso() {
    if [ "_$1_" == "__" ]; then return 0; fi

    echo -e "\e[32m_unhandle_iso(\e[0m$1\e[32m)\e[0m";
    ######################################################################
    # $1 : short name
    ######################################################################
    local NAME=$1
    local FILE_URL=$NAME.url
    local FILE_ISO=$NAME.iso
    ######################################################################

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$NAME 2> /dev/null;

    sudo rm -f $DST_ISO/$FILE_URL;
    sudo rm -f $DST_ISO/$FILE_ISO;

    sudo rm -rf $DST_NFS_ETH0/$NAME;

    sudo sed /etc/fstab   -i -e "/$NAME/d"
    sudo sed /etc/exports -i -e "/$NAME/d"
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
        || ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null \
        || ([ "$3" == "timestamping" ] && ! compare_last_modification_time $DST_IMG/$FILE_URL $URL); \
        then
            echo -e "\e[36m    download image\e[0m";
            sudo rm -f $DST_IMG/$FILE_IMG;
            sudo rm -f $DST_IMG/$FILE_URL;
            sudo wget -O $DST_IMG/$RAW_FILENAME_ZIP  $URL;

            sudo sh -c "echo '$URL' > $DST_IMG/$FILE_URL";
            sudo touch -r $DST_IMG/$RAW_FILENAME_ZIP  $DST_IMG/$FILE_URL;

            echo -e "\e[36m    extract image\e[0m";
            sudo unzip $DST_IMG/$RAW_FILENAME_ZIP  -d $DST_IMG > /tmp/output.tmp;
            sudo rm -f $DST_IMG/$RAW_FILENAME_ZIP;
            local RAW_FILENAME_IMG=$(grep 'inflating' /tmp/output.tmp | cut -d':' -f2 | xargs basename)
            sudo mv $DST_IMG/$RAW_FILENAME_IMG  $DST_IMG/$FILE_IMG;
            rm /tmp/output.tmp
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
            sudo sh -c "echo '$DST_NFS_BOOT  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
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
            sudo sh -c "echo '$DST_NFS_ROOT  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
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
    if [ "$RPI_SN0" == "--------" ]; then
        echo -e "\e[36m    skipped: no serial number setted at RPI_SN0.\e[0m";
        return 1;
    fi
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

#hdmi_ignore_cec_init=1
cec_osd_name=NetBoot

#########################################
# standard resolution
hdmi_drive=2

#########################################
# custom resolution
# 4k@24Hz or 25Hz custom DMT - mode
#gpu_mem=128
#hdmi_group=2
#hdmi_mode=87
#hdmi_pixel_freq_limit=400000000
#max_framebuffer_width=3840
#max_framebuffer_height=2160
#
#    #### implicit timing ####
#    hdmi_cvt 3840 2160 24
#    #hdmi_cvt 3840 2160 25
#
#    #### explicit timing ####
#    #hdmi_ignore_edid=0xa5000080
#    #hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 24 0 211190000 3
#    ##hdmi_timings=3840 1 48 32 80 2160 1 3 5 54 0 0 0 25 0 220430000 3
#    #framebuffer_width=3840
#    #framebuffer_height=2160
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
                if [ -f "$SRC_BACKUP/wpa_supplicant.conf" ]; then
                    echo -e "\e[36m    add wpa_supplicant file from backup\e[0m";
                    sudo rsync -xa --info=progress2 $SRC_BACKUP/wpa_supplicant.conf  $DST_ROOT/etc/wpa_supplicant/
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
    [ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]            || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
    if [ -d "$SRC_TFTP_ETH0" ]; then
        echo -e "\e[36m    copy win-pe stuff\e[0m";
        if ! [ -f "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxeboot.n12" ] && [ -f "$SRC_TFTP_ETH0/pxeboot.n12" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/pxeboot.n12  $DST_TFTP_ETH0/$DST_PXE_BIOS/; fi
        if ! [ -f "$DST_TFTP_ETH0/bootmgr.exe" ] && [ -f "$SRC_TFTP_ETH0/bootmgr.exe" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/bootmgr.exe  $DST_TFTP_ETH0/; fi
        if ! [ -d "$DST_TFTP_ETH0/boot" ] && [ -d "$SRC_TFTP_ETH0/boot" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/boot  $DST_TFTP_ETH0/; fi
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
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/lpxelinux.0" ]  || sudo ln -s /usr/lib/PXELINUX/lpxelinux.0                $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/ldlinux.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/ldlinux.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/bios/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/memdisk" ]      || sudo ln -s /usr/lib/syslinux/memdisk                    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                               $DST_TFTP_ETH0/$DST_PXE_BIOS/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/iso" ]          || sudo ln -s $DST_ISO/                                    $DST_TFTP_ETH0/$DST_PXE_BIOS/iso;
    handle_pxe_menu  $DST_PXE_BIOS  default;

    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe efi32\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_EFI32" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI32;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/syslinux.efi" ] || sudo ln -s /usr/lib/SYSLINUX.EFI/efi32/syslinux.efi      $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/ldlinux.e32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/ldlinux.e32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/efi32/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI32/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI32/iso;
    handle_pxe_menu  $DST_PXE_EFI32  default;

    ######################################################################
    echo -e "\e[36m    setup sys menu files for pxe efi64\e[0m";
    [ -d "$DST_TFTP_ETH0/$DST_PXE_EFI64" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI64;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/syslinux.efi" ] || sudo ln -s /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi      $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/ldlinux.e64" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/ldlinux.e64   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/reboot.c32" ]   || sudo ln -s /usr/lib/syslinux/modules/efi64/reboot.c32    $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/poweroff.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/poweroff.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI64/nfs;
    [ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/iso" ]          || sudo ln -s $DST_ISO/                                     $DST_TFTP_ETH0/$DST_PXE_EFI64/iso;
    handle_pxe_menu  $DST_PXE_EFI64  default;
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

##########################################################################
if [ -d "/var/www/html" ]; then
    [ -h "/var/www/html$ISO" ]      || sudo ln -s $DST_ISO      /var/www/html$ISO;
    [ -h "/var/www/html$IMG" ]      || sudo ln -s $DST_IMG      /var/www/html$IMG;
    [ -h "/var/www/html$NFS_ETH0" ] || sudo ln -s $DST_NFS_ETH0 /var/www/html$NFS_ETH0;
fi

######################################################################
handle_dnsmasq
handle_samba
handle_optional
handle_dhcpcd
handle_chrony


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
## or
## "_unhandle_iso  ...",
##  if you want to delete the entire iso and its nfs export to free disk space
##########################################################################
##########################################################################
##handle_iso  $WIN_PE_X86  $WIN_PE_X86_URL;
_unhandle_iso  $UBUNTU_LTS_X64  $UBUNTU_LTS_X64_URL;
_unhandle_iso  $UBUNTU_LTS_X86  $UBUNTU_LTS_X86_URL;
handle_iso  $UBUNTU_X64  $UBUNTU_X64_URL;
_unhandle_iso  $UBUNTU_DAILY_X64  $UBUNTU_DAILY_X64_URL  timestamping;
_unhandle_iso  $LUBUNTU_X64  $LUBUNTU_X64_URL;
_unhandle_iso  $LUBUNTU_X86  $LUBUNTU_X86_URL;
_unhandle_iso  $LUBUNTU_DAILY_X64  $LUBUNTU_DAILY_X64_URL  timestamping;
_unhandle_iso  $UBUNTU_STUDIO_X64  $UBUNTU_STUDIO_X64_URL;
##handle_iso  $UBUNTU_NONPAE  $UBUNTU_NONPAE_URL;
handle_iso  $DEBIAN_X64  $DEBIAN_X64_URL;
_unhandle_iso  $DEBIAN_X86  $DEBIAN_X86_URL;
_unhandle_iso  $DEVUAN_X64  $DEVUAN_X64_URL;
_unhandle_iso  $DEVUAN_X86  $DEVUAN_X86_URL;
_unhandle_iso  $PARROT_LITE_X64  $PARROT_LITE_X64_URL;
_unhandle_iso  $PARROT_LITE_X86  $PARROT_LITE_X86_URL;
_unhandle_iso  $PARROT_FULL_X64  $PARROT_FULL_X64_URL;
_unhandle_iso  $PARROT_FULL_X86  $PARROT_FULL_X86_URL;
_unhandle_iso  $GNURADIO_X64  $GNURADIO_X64_URL;
_unhandle_iso  $DEFT_X64  $DEFT_X64_URL;
_unhandle_iso  $DEFTZ_X64  $DEFTZ_X64_URL  ,gid=root,uid=root,norock,mode=292;
_unhandle_iso  $KALI_X64  $KALI_X64_URL;
_unhandle_iso  $PENTOO_X64  $PENTOO_X64_URL  timestamping;
_unhandle_iso  $PENTOO_BETA_X64  $PENTOO_BETA_X64_URL  timestamping;
_unhandle_iso  $SYSTEMRESCUE_X86  $SYSTEMRESCUE_X86_URL;
##handle_iso  $DESINFECT_X86  $DESINFECT_X86_URL;
_unhandle_iso  $TINYCORE_x64  $TINYCORE_x64_URL  timestamping;
_unhandle_iso  $TINYCORE_x86  $TINYCORE_x86_URL  timestamping;
handle_iso  $RPDESKTOP_X86  $RPDESKTOP_X86_URL  timestamping;
_unhandle_iso  $CLONEZILLA_X64  $CLONEZILLA_X64_URL;
_unhandle_iso  $CLONEZILLA_X86  $CLONEZILLA_X86_URL;
_unhandle_iso  $FEDORA_X64  $FEDORA_X64_URL;
######################################################################
handle_pxe


######################################################################
######################################################################
## comment out those entries,
##  you dont want to download/mount/export
######################################################################
######################################################################
#handle_zip_img  $PI_CORE   $PI_CORE_URL;
handle_zip_img  $RPD_LITE  $RPD_LITE_URL  timestamping;
#handle_zip_img  $RPD_FULL  $RPD_FULL_URL  timestamping;
######################################################################
######################################################################
## comment out those entries,
##  you dont want to have as RPi3 network booting
######################################################################
######################################################################
#handle_network_booting  $PI_CORE  bootcode,config
handle_network_booting  $RPD_LITE  bootcode,cmdline,config,ssh,root,fstab,wpa,history
#handle_network_booting  $RPD_FULL  bootcode,cmdline,config,ssh,root,fstab,wpa,history


#      #              #              #              #              #
#     ###            ###            ###            ###            ###
#    #####          #####          #####          #####          #####
#   #######        #######        #######        #######        #######
#  #########      #########      #########      #########      #########
# ###########    ###########    ###########    ###########    ###########
##########################################################################


######################################################################
if [ -d "$SRC_ISO" ]; then
    echo -e "\e[32mbackup new iso images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_ISO/*.iso $DST_ISO/*.url  $SRC_ISO/
fi
######################################################################
if [ -d "$SRC_IMG" ]; then
    echo -e "\e[32mbackup new images to usb-stick\e[0m";
    sudo rsync -xa --info=progress2 $DST_IMG/*.img $DST_IMG/*.url  $SRC_IMG/
fi
######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
