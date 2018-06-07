#!/bin/bash

##########################################################################
# winpe,        https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx
# ubuntu,       http://releases.ubuntu.com/
#               http://cdimage.ubuntu.com/daily-live/current/
# debian,       https://cdimage.debian.org/debian-cd/
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
#
# rpi-raspbian  https://downloads.raspberrypi.org/raspbian/images/
# piCore        http://tinycorelinux.net/9.x/armv6/releases/RPi/
#               http://tinycorelinux.net/9.x/armv7/releases/RPi/
#
# v2018-06-07
#
# known issues:
#    overlayfs can not get exported via nfs
#    overlayfs is working, when you put a bindfs on top of overlayfs, to make exportfs happy
#    note: this overlayfs+bindfs construction does NOT work reliably - data loss!
#    solution: maybe linux kernel 4.16


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
CUSTOM_LANG=de
CUSTOM_LANG_LONG=de_DE
CUSTOM_LANG_UPPER=DE
CUSTOM_LANG_WRITTEN=German
CUSTOM_LANG_EXT=de-latin1-nodeadkeys
CUSTOM_TIMEZONE=Europe/Berlin
##########################################################################
RPI_SN0=--------
RPI_SN1=--------
RPI_SN2=--------
RPI_SN3=--------
##########################################################################
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net)
INTERFACE_ETH1=eth1
INTERFACE_WLAN0=wlan0
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
IP_ETH1_END=192.168.250.110
IP_ETH1_MASK=255.255.255.0
##########################################################################
IP_WLAN0=192.168.251.1
IP_WLAN0_START=192.168.251.100
IP_WLAN0_END=192.168.251.110
IP_WLAN0_MASK=255.255.255.0
##########################################################################
DRIVER_WLAN0=nl80211
COUNTRY_WLAN0=$CUSTOM_LANG_UPPER
PASSWORD_WLAN0=p@ssw0rd
SSID_WLAN0=wlan0@domain.local
INTERFACE_WLAN0X=wlan0x
PASSWORD_WLAN0X=p@ssw0rd
SSID_WLAN0X=wlan0x@domain.local

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
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-desktop-amd64.iso
UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-desktop-i386.iso

UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=http://releases.ubuntu.com/18.04/ubuntu-18.04-desktop-amd64.iso

UBUNTU_DAILY_X64=ubuntu-daily-x64
UBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/daily-live/pending/cosmic-desktop-amd64.iso


LUBUNTU_X64=lubuntu-x64
LUBUNTU_X64_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04-desktop-amd64.iso
LUBUNTU_X86=lubuntu-x86
LUBUNTU_X86_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04-desktop-i386.iso

LUBUNTU_DAILY_X64=lubuntu-daily-x64
LUBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/lubuntu/daily-live/pending/cosmic-desktop-amd64.iso


UBUNTU_NONPAE=ubuntu-nopae
UBUNTU_NONPAE_URL=

DEBIAN_KVER=4.9.0-6
DEBIAN_X64=debian-x64
DEBIAN_X64_URL=https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.4.0-amd64-lxde.iso
DEBIAN_X86=debian-x86
DEBIAN_X86_URL=https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.4.0-i386-lxde.iso

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
KALI_X64_URL=https://cdimage.kali.org/current/kali-linux-2018.2-amd64.iso

PENTOO_X64=pentoo-x64
PENTOO_X64_URL=http://mirror.switch.ch/ftp/mirror/pentoo/latest-iso-symlinks/pentoo-amd64-hardened.iso

SYSTEMRESCTUE_X86=systemrescue-x86
SYSTEMRESCTUE_X86_URL=https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.2.2/systemrescuecd-x86-5.2.2.iso

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=
DESINFECT_X64=desinfect-x64
DESINFECT_X64_URL=

TINYCORE_x64=tinycore-x64
TINYCORE_x64_URL=http://tinycorelinux.net/9.x/x86_64/release/TinyCorePure64-current.iso
TINYCORE_x86=tinycore-x86
TINYCORE_x86_URL=http://tinycorelinux.net/9.x/x86/release/TinyCore-current.iso

RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=https://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2017-12-01/2017-11-16-rpd-x86-stretch.iso

CLONEZILLA_X64=clonezilla-x64
CLONEZILLA_X64_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.5-38/clonezilla-live-2.5.5-38-amd64.iso
CLONEZILLA_X86=clonezilla-x86
CLONEZILLA_X86_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.5.5-38/clonezilla-live-2.5.5-38-i686.iso

FEDORA_X64=fedora-x64
FEDORA_X64_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/28/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-28-1.1.iso

TAILS_X64=tails-x64
TAILS_X64_URL=https://mirrors.kernel.org/tails/stable/tails-amd64-3.6.2/tails-amd64-3.6.2.iso

CENTOS_X64=centos-x64
CENTOS_X64_URL=http://ftp.rrzn.uni-hannover.de/centos/7/isos/x86_64/CentOS-7-x86_64-LiveGNOME-1804.iso


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
handle_hostapd() {
    echo -e "\e[32mhandle_hostapd()\e[0m";

    ######################################################################
    grep -q mod_install_server /etc/hostapd/hostapd.conf || {
    echo -e "\e[36m    setup hostapd.conf for wlan access point\e[0m";
    sudo sh -c "cat << EOF  > /etc/hostapd/hostapd.conf
########################################
#/etc/hostapd/hostapd.conf
## mod_install_server
interface=$INTERFACE_WLAN0
driver=$DRIVER_WLAN0

country_code=$COUNTRY_WLAN0
ieee80211d=1

hw_mode=g
ieee80211n=1
channel=7

wmm_enabled=1

##
ssid=$SSID_WLAN0
ignore_broadcast_ssid=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
#wpa_passphrase=$PASSWORD_WLAN0
wpa_psk=$(wpa_passphrase $SSID_WLAN0 PASSWORD_WLAN0 | grep '[[:blank:]]psk' | cut -d = -f2)

## optional: create virtual wlan adapter
#bss=$INTERFACE_WLAN0X
#ssid=$SSID_WLAN0X
#ignore_broadcast_ssid=0
#macaddr_acl=0
#auth_algs=1
#wpa=2
#wpa_key_mgmt=WPA-PSK
#wpa_pairwise=TKIP
#rsn_pairwise=CCMP
##wpa_passphrase=$PASSWORD_WLAN0X
#wpa_psk=$(wpa_passphrase $SSID_WLAN0X PASSWORD_WLAN0X | grep '[[:blank:]]psk' | cut -d = -f2)
EOF";
    }

    ######################################################################
    grep -q mod_install_server /etc/default/hostapd || {
    echo -e "\e[36m    setup hostapd for wlan access point\e[0m";
    sudo sh -c "cat << EOF  > /etc/default/hostapd
########################################
#/etc/default/hostapd
## mod_install_server
DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"
EOF";
    }

    sudo systemctl restart hostapd.service;
}


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
interface $INTERFACE_WLAN0
static ip_address=$IP_WLAN0/24
static routers=$IP_WLAN0_ROUTER
static domain_name_servers=$IP_WLAN0_ROUTER
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

auto $INTERFACE_WLAN0
iface $INTERFACE_WLAN0 inet static
    address $IP_WLAN0
    netmask $IP_WLAN0_MASK
    gateway $IP_WLAN0_ROUTER
    hwaddress 88:88:88:22:22:22

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
#log-queries

# interface selection
interface=$INTERFACE_ETH0
interface=$INTERFACE_ETH1
interface=$INTERFACE_WLAN0

#
bind-dynamic
domain-needed
bogus-priv

# TFTP_ETH0 (enabled)
enable-tftp
tftp-lowercase
tftp-root=$DST_TFTP_ETH0/, $INTERFACE_ETH0
dhcp-option=$INTERFACE_ETH0, option:tftp-server, 0.0.0.0

#
dhcp-option=$INTERFACE_ETH1, option:nis-domain, eth-nis
dhcp-option=$INTERFACE_ETH1, option:domain-name, eth-domain.local
dhcp-option=$INTERFACE_WLAN0, option:nis-domain, wlan-nis
dhcp-option=$INTERFACE_WLAN0, option:domain-name, wlan-domain.local

# Time Server
dhcp-option=$INTERFACE_ETH0, option:ntp-server, 0.0.0.0
dhcp-option=$INTERFACE_ETH1, option:ntp-server, 0.0.0.0
dhcp-option=$INTERFACE_WLAN0, option:ntp-server, 0.0.0.0

# DHCP
# do not give IPs that are in pool of DSL routers DHCP
dhcp-range=$INTERFACE_ETH0, $IP_ETH0_START, $IP_ETH0_END, 24h
dhcp-range=$INTERFACE_ETH1, $IP_ETH1_START, $IP_ETH1_END, 24h
dhcp-range=$INTERFACE_WLAN0, $IP_WLAN0_START, $IP_WLAN0_END, 24h

# some examples for pre-defined static IPs by MAC or by name
#dhcp-host=$INTERFACE_ETH0, 11:11:11:11:11:11,  192.168.0.100
#dhcp-host=$INTERFACE_ETH0, MySmartHome, 192.168.0.101
#dhcp-host=$INTERFACE_ETH1, 22:22:22:22:22:22,  192.168.250.100
#dhcp-host=$INTERFACE_ETH1, MySmartTV, 192.168.250.101
#dhcp-host=$INTERFACE_WLAN0, 33:33:33:33:33:33, 192.168.251.100
#dhcp-host=$INTERFACE_WLAN0, MySmartPhone, 192.168.251.101

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
dhcp-match=set:iPXE, option:user-class, iPXE

# test if it is a RPi3 or a regular x86PC
tag-if=set:ARM_RPI3, tag:ARCH_0, tag:UUID_RPI3
tag-if=set:x86_BIOS, tag:ARCH_0, tag:!UUID_RPI3, tag:!iPXE
tag-if=set:x86_iPXE, tag:ARCH_0, tag:!UUID_RPI3, tag:iPXE
tag-if=set:UEFI_iPXE, tag:!ARCH_0, tag:!UUID_RPI3, tag:iPXE

pxe-service=tag:ARM_RPI3,0, \"Raspberry Pi Boot   \", bootcode.bin
pxe-service=tag:x86_BIOS,x86PC, \"PXE Boot Menu (BIOS 00:00)\", $DST_PXE_BIOS/lpxelinux
pxe-service=tag:x86_iPXE,x86PC, \"iPXE Boot Menu (iPXE 00:00)\", undionly.kpxe
pxe-service=tag:UEFI_iPXE,x86PC, \"iPXE Boot Menu (iPXE UEFI)\", ipxe.efi
pxe-service=6, \"PXE Boot Menu (UEFI 00:06)\", $DST_PXE_EFI32/syslinux.efi
pxe-service=x86-64_EFI, \"PXE Boot Menu (UEFI 00:07)\", $DST_PXE_EFI64/syslinux.efi
pxe-service=9, \"PXE Boot Menu (UEFI 00:09)\", $DST_PXE_EFI64/syslinux.efi

dhcp-boot=tag:ARM_RPI3, bootcode.bin
dhcp-boot=tag:x86_BIOS, $DST_PXE_BIOS/lpxelinux.0
#dhcp-boot=tag:x86_iPXE, http://my.web.server/real_boot_script.php
dhcp-boot=tag:x86_iPXE, undionly.kpxe
dhcp-boot=tag:UEFI_iPXE, ipxe.efi
dhcp-option=iPXE, 175, 8:1:1
dhcp-boot=tag:x86_UEFI, $DST_PXE_EFI32/syslinux.efi
dhcp-boot=tag:x64_UEFI, $DST_PXE_EFI64/syslinux.efi
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
    #sudo sed -i /etc/samba/smb.conf -n -e "1,/#======================= Share Definitions =======================/p";
    sudo sh -c "cat << EOF  > /etc/samba/smb.conf
########################################
## mod_install_server
#======================= Global Settings =======================
[global]

## Browsing/Identification ###
   workgroup = WORKGROUP
dns proxy = yes
enhanced browsing = no

#### Networking ####
interfaces = $IP_ETH0_0/24 $INTERFACE_ETH0
bind interfaces only = yes

#### Debugging/Accounting ####
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d

####### Authentication #######
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user

########## Domains ###########

############ Misc ############
   usershare allow guests = yes

# https://www.samba.org/samba/security/CVE-2017-14746.html
server min protocol = SMB2

#======================= Share Definitions =======================
[srv]
    path = $DST_ROOT
    comment = /srv folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = no
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mode = 0644
    force directory mode = 0755
    force user = root
    force group = root
    hide dot files = no

[media]
    path = /media/
    comment = /media folder of pxe-server
    guest ok = yes
    guest only = yes
    browseable = no
    read only = no
    create mask = 0644
    directory mask = 0755
    force create mode = 0644
    force directory mode = 0755
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
LABEL $UBUNTU_LTS_X64
    MENU LABEL Ubuntu LTS x64
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz.efi
    INITRD $NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz
    INITRD $NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$UBUNTU_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$UBUNTU_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$UBUNTU_X86/casper/vmlinuz
    INITRD $NFS_ETH0/$UBUNTU_X86/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$UBUNTU_DAILY_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$UBUNTU_DAILY_X64/casper/initrd.lz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_DAILY_X64 ro netboot=nfs file=/cdrom/preseed/ubuntu.seed boot=casper systemd.mask=tmp.mount -- debian-installer/language=$CUSTOM_LANG console-setup/layoutcode=$CUSTOM_LANG keyboard-configuration/layoutcode=$CUSTOM_LANG keyboard-configuration/variant=$CUSTOM_LANG_WRITTEN
    TEXT HELP
        Boot to Ubuntu x64 Daily-Live
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
    KERNEL $NFS_ETH0/$LUBUNTU_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$LUBUNTU_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$LUBUNTU_X86/casper/vmlinuz
    INITRD $NFS_ETH0/$LUBUNTU_X86/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$LUBUNTU_DAILY_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$LUBUNTU_DAILY_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz
    INITRD $NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$DEBIAN_X64/live/vmlinuz-$DEBIAN_KVER-amd64
    INITRD $NFS_ETH0/$DEBIAN_X64/live/initrd.img-$DEBIAN_KVER-amd64
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
    KERNEL $NFS_ETH0/$DEBIAN_X86/live/vmlinuz-$DEBIAN_KVER-686
    INITRD $NFS_ETH0/$DEBIAN_X86/live/initrd.img-$DEBIAN_KVER-686
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86 ro netboot=nfs boot=live config -- locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG utc=no timezone=$CUSTOM_TIMEZONE
    TEXT HELP
        Boot to Debian x86 Live LXDE
        User: user, Password: live
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
    KERNEL $NFS_ETH0/$PARROT_LITE_X64/live/vmlinuz
    INITRD $NFS_ETH0/$PARROT_LITE_X64/live/initrd.img
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
    KERNEL $NFS_ETH0/$PARROT_LITE_X86/live/vmlinuz
    INITRD $NFS_ETH0/$PARROT_LITE_X86/live/initrd.img
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
    KERNEL $NFS_ETH0/$PARROT_FULL_X64/live/vmlinuz
    INITRD $NFS_ETH0/$PARROT_FULL_X64/live/initrd.img
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
    KERNEL $NFS_ETH0/$PARROT_FULL_X86/live/vmlinuz
    INITRD $NFS_ETH0/$PARROT_FULL_X86/live/initrd.img
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
    KERNEL $NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi
    INITRD $NFS_ETH0/$GNURADIO_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$KALI_X64/live/vmlinuz
    INITRD $NFS_ETH0/$KALI_X64/live/initrd.img
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
    KERNEL $NFS_ETH0/$DEFT_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$DEFT_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$DEFTZ_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$DEFTZ_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$PENTOO_X64/isolinux/pentoo
    INITRD $NFS_ETH0/$PENTOO_X64/isolinux/pentoo.igz
    APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 ro real_root=/dev/nfs root=/dev/ram0 init=/linuxrc overlayfs looptype=squashfs loop=/image.squashfs cdroot nox --
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
LABEL $SYSTEMRESCTUE_X86
    MENU LABEL System Rescue x86
    KERNEL $NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/rescue32
    INITRD $NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/initram.igz
    APPEND netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCTUE_X86 ro dodhcp -- setkmap=$CUSTOM_LANG
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
    KERNEL $NFS_ETH0/$DESINFECT_X86/casper/vmlinuz
    INITRD $NFS_ETH0/$DESINFECT_X86/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$DESINFECT_X64/casper/vmlinuz
    INITRD $NFS_ETH0/$DESINFECT_X64/casper/initrd.lz
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
    KERNEL $NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64
    INITRD $NFS_ETH0/$TINYCORE_x64/boot/corepure64.gz
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
    KERNEL $NFS_ETH0/$TINYCORE_x86/boot/vmlinuz
    INITRD $NFS_ETH0/$TINYCORE_x86/boot/core.gz
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
    KERNEL $NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2
    INITRD $NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img
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
    KERNEL $NFS_ETH0/$CLONEZILLA_X64/live/vmlinuz
    INITRD $NFS_ETH0/$CLONEZILLA_X64/live/initrd.img
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
    KERNEL $NFS_ETH0/$CLONEZILLA_X86/live/vmlinuz
    INITRD $NFS_ETH0/$CLONEZILLA_X86/live/initrd.img
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
    KERNEL $NFS_ETH0/$FEDORA_X64/isolinux/vmlinuz
    INITRD $NFS_ETH0/$FEDORA_X64/isolinux/initrd.img
    APPEND root=live:http://$IP_ETH0$NFS_ETH0/$FEDORA_X64/LiveOS/squashfs.img ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8
    TEXT HELP
        Boot to Fedora Workstation Live
        User: liveuser
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
##       https://github.com/haraldh/dracut/blob/master/dracut.cmdline.7.asc
## NOT WORKING
LABEL $CENTOS_X64
    MENU LABEL CentOS x64
    KERNEL $NFS_ETH0/$CENTOS_X64/isolinux/vmlinuz0
    INITRD $NFS_ETH0/$CENTOS_X64/isolinux/initrd0.img
    #APPEND root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 ro rootfstype=auto rd.live.image rhgb rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.shell rd.break console=tty0 loglevel=7 vga=794 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8

# dracut: FATAL: Don't know how to handle 'root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64';
    #APPEND root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8

# dracut: FATAL: Don't know how to handle 'root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img';
    #APPEND root=live:nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img ro rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8

# mount.nfs: mountpoint /sysroot is not a directory
    #APPEND root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64/LiveOS/squashfs.img ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8

# Warning: Could not boot.
    # Warning: /dev/mapper/live-rw does not exist
    # Starting Dracut Emergency Shell
    APPEND root=nfs:$IP_ETH0:$DST_NFS_ETH0/$CENTOS_X64 ro root-path=/LiveOS/squashfs.img rootfstype=squashfs rd.live.image rd.live.ram=1 rd.live.overlay=none rd.luks=0 rd.md=0 rd.dm=0 vga=794 rd.shell log_buf_len=1M rd.retry=10 -- vconsole.font=latarcyrheb-sun16 vconsole.keymap=$CUSTOM_LANG_EXT locale.LANG=$CUSTOM_LANG_LONG.UTF-8

    TEXT HELP
        Boot to CentOS LiveGNOME
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
LABEL $TAILS_X64
    MENU LABEL Tails x64
    #KERNEL $NFS_ETH0/$TAILS_X64/live/vmlinuz
    INITRD $NFS_ETH0/$TAILS_X64/live/initrd.img
    #APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64 ro netboot=nfs boot=live config loglevel=7 -- break locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG
    APPEND fetch=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64/live/filesystem.squashfs ro boot=live config live-media=removable nopersistent noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 nox11autologin module=Tails -- break locales=$CUSTOM_LANG_LONG.UTF-8 keyboard-layouts=$CUSTOM_LANG
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


##########################################################################
handle_ipxe() {
    echo -e "\e[32mhandle_ipxe()\e[0m";

    ######################################################################
    # http://ipxe.org/docs
    # http://ipxe.org/howto/chainloading

    ######################################################################
    if [ -d "$SRC_TFTP_ETH0" ]; then
        echo -e "\e[36m    copy iPXE stuff\e[0m";
        if ! [ -f "$DST_TFTP_ETH0/undionly.kpxe" ] && [ -f "$SRC_TFTP_ETH0/undionly.kpxe" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/undionly.kpxe  $DST_TFTP_ETH0/; fi
        if ! [ -f "$DST_TFTP_ETH0/ipxe.efi" ] && [ -f "$SRC_TFTP_ETH0/ipxe.efi" ]; then sudo rsync -xa --info=progress2 $SRC_TFTP_ETH0/ipxe.efi  $DST_TFTP_ETH0/; fi
    else
        echo -e "\e[36m    download iPXE stuff\e[0m";
        sudo wget -O $DST_TFTP_ETH0/undionly.kpxe  https://boot.ipxe.org/undionly.kpxe;
        sudo wget -O $DST_TFTP_ETH0/ipxe.efi  https://boot.ipxe.org/ipxe.efi;
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
    if [ "$3" == "bindfs" ]; then sudo umount -f $DST_ORIGINAL 2> /dev/null; fi

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

        if ! [ -d "$DST_ORIGINAL" ]; then
            if [ "$3" == "bindfs" ]; then
                echo -e "\e[36m    create nfs folder\e[0m";
                sudo mkdir -p $DST_ORIGINAL;
            fi
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/fstab; then
            echo -e "\e[36m    add iso image to fstab\e[0m";
            if [ "$3" == "bindfs" ]; then
                sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_ORIGINAL  auto  ro,nofail,auto,loop  0  10' >> /etc/fstab";
                sudo sh -c "echo '$DST_ORIGINAL  $DST_NFS_ETH0/$NAME  fuse.bindfs  ro,auto,force-user=root,force-group=root,perms=a+rX  0  11' >> /etc/fstab";
            else
                if [ "$3" == "timestamping" ]; then
                    sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$4  0  10' >> /etc/fstab";
                else
                    sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop$3  0  10' >> /etc/fstab";
                fi
            fi
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[36m    add nfs folder to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ETH0/$NAME  *(ro,async,no_subtree_check,root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi

        if [ "$3" == "bindfs" ]; then sudo mount $DST_ORIGINAL; fi
        sudo mount $DST_NFS_ETH0/$NAME;
        sudo exportfs *:$DST_NFS_ETH0/$NAME;

        #if [ -d "/var/www/html" ]; then
        #    if ! [ -h "/var/www/html/$FILE_ISO" ]; then
        #        sudo ln -s $DST_ISO/$FILE_ISO /var/www/html/$FILE_ISO
        #    fi
        #    if ! [ -h "/var/www/html/$NAME" ]; then
        #        sudo ln -s $DST_NFS_ETH0/$NAME/ /var/www/html/$NAME
        #    fi
        #fi
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
$IP_ETH0:$DST_NFS_ROOT  /      nfs   defaults,noatime  0  1
$IP_ETH0:$DST_NFS_BOOT  /boot  nfs   defaults,noatime  0  2
EOF";
                sudo rm $DST_CUSTOM_ROOT/etc/init.d/resize2fs_once;
            fi

            ##############################################################
            if (echo $FLAGS | grep -q wpa); then
                echo -e "\e[36m    add wpa_supplicant template file\e[0m";
                sudo sh -c "cat << EOF  > $DST_CUSTOM_ROOT/etc/wpa_supplicant/wpa_supplicant.conf
########################################
country=$COUNTRY_WLAN0
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
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y --purge && sudo apt autoclean -y && sync && echo Done.
sudo nano /etc/resolv.conf
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

            ##################################################################
            if (echo $FLAGS | grep -q apt); then
                ##############################################################
                if ! [ -f "$DST_CUSTOM_ROOT/etc/apt/apt.conf.d/01proxy" ]; then
                    echo -e "\e[36m    add apt proxy file\e[0m";
                    sudo sh -c "cat << EOF  > $DST_CUSTOM_ROOT/etc/apt/apt.conf.d/01proxy
Acquire::http::Proxy \"http://$IP_ETH0:3142\";
EOF";
                fi
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
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_NFS_BOOT/$FILE_URL 2> /dev/null; then
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

    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$SN" ]; then sudo ln -s $DST_NFS_BOOT/  $DST_TFTP_ETH0/$SN; fi

    ######################################################################
    sudo cp $DST_IMG/$FILE_URL $DST_CUSTOM_BOOT/$FILE_URL;
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
    local DST_LOWER_BOOT=/srv/tmp/lower/$NAME_BOOT
    local DST_LOWER_ROOT=$SRC_ROOT
    local DST_UPPER_BOOT=/srv/tmp/upper/$DST_SN_BOOT
    local DST_UPPER_ROOT=/srv/tmp/upper/$DST_SN_ROOT
    local DST_WORK_BOOT=/srv/tmp/work/$DST_SN_BOOT
    local DST_WORK_ROOT=/srv/tmp/work/$DST_SN_ROOT
    local DST_MERGED_BOOT=/srv/tmp/merged/$DST_SN_BOOT
    local DST_MERGED_ROOT=/srv/tmp/merged/$DST_SN_ROOT
    ######################################################################
    local DST_CUSTOM_BOOT=$DST_NFS_BOOT
    local DST_CUSTOM_ROOT=$DST_NFS_ROOT
    ######################################################################

    sudo exportfs -u *:$DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_NFS_BOOT 2> /dev/null;
    sudo umount -f $DST_MERGED_BOOT 2> /dev/null;
    sudo umount -f $DST_LOWER_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_ROOT 2> /dev/null;
    sudo umount -f $DST_MERGED_ROOT 2> /dev/null;


    ######################################################################
    if (echo $FLAGS | grep -q redo) \
    || ! grep -q $(cat $DST_IMG/$FILE_URL)  $DST_UPPER_BOOT/$FILE_URL 2> /dev/null; then
        echo -e "\e[36m    delete old boot files\e[0m";
        sudo rm -rf $DST_NFS_BOOT;
        sudo rm -rf $DST_UPPER_BOOT;
        sudo rm -rf $DST_WORK_BOOT;
        sudo rm -rf $DST_MERGED_BOOT;
        sudo rm -rf $DST_LOWER_BOOT;
        echo -e "\e[36m    delete old root files\e[0m";
        sudo rm -rf $DST_NFS_ROOT;
        sudo rm -rf $DST_UPPER_ROOT;
        sudo rm -rf $DST_WORK_ROOT;
        sudo rm -rf $DST_MERGED_BOOT;
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
    if ! [ -d "$DST_MERGED_BOOT" ]; then sudo mkdir -p $DST_MERGED_BOOT; fi
    if ! [ -d "$DST_LOWER_BOOT" ]; then sudo mkdir -p $DST_LOWER_BOOT; fi
    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! [ -d "$DST_NFS_ROOT" ]; then sudo mkdir -p $DST_NFS_ROOT; fi
        if ! [ -d "$DST_UPPER_ROOT" ]; then sudo mkdir -p $DST_UPPER_ROOT; fi
        if ! [ -d "$DST_WORK_ROOT" ]; then sudo mkdir -p $DST_WORK_ROOT; fi
        if ! [ -d "$DST_MERGED_ROOT" ]; then sudo mkdir -p $DST_MERGED_ROOT; fi
    fi

    ######################################################################
    if ! [ -f "/etc/mount-delayed.sh" ]; then sudo touch /etc/mount-delayed.sh; sudo chmod 0755 /etc/mount-delayed.sh; fi
    if ! grep -q "mount-delayed.sh" /etc/rc.local; then
        sudo sed /etc/rc.local -i -e "s/^exit 0$/\########################################\n## workaround\n\/etc\/mount-delayed.sh;\n\nexit 0/"
    fi
    sudo sed /etc/mount-delayed.sh -i -e "/$DST_SN_BOOT/d"
    sudo sh -c "echo 'mount $DST_LOWER_BOOT' >> /etc/mount-delayed.sh";
    sudo sh -c "echo 'mount $DST_MERGED_BOOT' >> /etc/mount-delayed.sh";
    sudo sh -c "echo 'mount $DST_NFS_BOOT' >> /etc/mount-delayed.sh";
    sudo sed /etc/mount-delayed.sh -i -e "/$DST_SN_ROOT/d"
    if (echo $FLAGS | grep -q root); then
        sudo sh -c "echo 'mount $DST_MERGED_ROOT' >> /etc/mount-delayed.sh";
        sudo sh -c "echo 'mount $DST_NFS_ROOT' >> /etc/mount-delayed.sh";
    fi

    ######################################################################
    if ! grep -q "$DST_NFS_BOOT" /etc/fstab; then
        echo -e "\e[36m    add image-boot to fstab\e[0m";
        sudo sh -c "echo '$SRC_BOOT  $DST_LOWER_BOOT  fuse.bindfs  ro,noauto  0  12' >> /etc/fstab";
        sudo sh -c "echo 'overlay  $DST_MERGED_BOOT  overlay  rw,noauto,lowerdir=$DST_LOWER_BOOT,upperdir=$DST_UPPER_BOOT,workdir=$DST_WORK_BOOT  0  13' >> /etc/fstab";
        sudo sh -c "echo '$DST_MERGED_BOOT  $DST_NFS_BOOT  fuse.bindfs  rw,noauto  0  14' >> /etc/fstab";
    fi

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_NFS_ROOT" /etc/fstab; then
            echo -e "\e[36m    add image-root to fstab\e[0m";
            sudo sh -c "echo 'overlay  $DST_MERGED_ROOT  overlay  rw,lowerdir=$DST_LOWER_ROOT,upperdir=$DST_UPPER_ROOT,workdir=$DST_WORK_ROOT  0  13' >> /etc/fstab";
            sudo sh -c "echo '$DST_MERGED_ROOT  $DST_NFS_ROOT  fuse.bindfs  rw,noauto  0  14' >> /etc/fstab";
        fi
    fi


    ######################################################################
    sudo mount $DST_LOWER_BOOT;
    sudo mount $DST_MERGED_BOOT;
    sudo mount $DST_NFS_BOOT;
    if (echo $FLAGS | grep -q root); then
        sudo mount $DST_MERGED_ROOT;
        sudo mount $DST_NFS_ROOT;
    fi

    ######################################################################
    if ! [ -h "$DST_TFTP_ETH0/$SN" ]; then sudo ln -s $DST_NFS_BOOT/  $DST_TFTP_ETH0/$SN; fi

    ######################################################################
    sudo cp $DST_IMG/$FILE_URL $DST_CUSTOM_BOOT/$FILE_URL;
    handle_rpi_pxe_customization $DST_CUSTOM_BOOT $DST_CUSTOM_ROOT $FLAGS;

    ######################################################################
    if ! grep -q "$DST_NFS_BOOT" /etc/exports; then
        echo -e "\e[36m    add $DST_NFS_BOOT to exports\e[0m";
        sudo sh -c "echo '$DST_NFS_BOOT  *(rw,sync,no_subtree_check,no_root_squash,mp,fsid=$(uuid))' >> /etc/exports";
    fi
    sudo exportfs *:$DST_NFS_BOOT;

    ######################################################################
    if (echo $FLAGS | grep -q root); then
        if ! grep -q "$DST_NFS_ROOT" /etc/exports; then
            echo -e "\e[36m    add $DST_NFS_ROOT to exports\e[0m";
            sudo sh -c "echo '$DST_NFS_ROOT  *(rw,sync,no_subtree_check,no_root_squash,mp,fsid=$(uuid))' >> /etc/exports";
        fi
        sudo exportfs *:$DST_NFS_ROOT;
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
        # overlayfs is working, when you put a bindfs on top of overlayfs, to make exportfs happy
        # note: this construction does NOT work reliably - data loss!
        #handle_rpi_pxe_overlay  $1 $2 $3;
    else
        # overlayFS is still not able to export via nfs
        handle_rpi_pxe_classic  $1 $2 $3;

        # overlayfs is working, when you put a bindfs on top of overlayfs, to make exportfs happy
        # note: this construction does NOT work reliably - data loss!
        #handle_rpi_pxe_overlay  $1 $2 $3;
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
    ## network nat
    grep -q mod_install_server /etc/sysctl.conf 2> /dev/null || {
    echo -e "\e[36m    setup sysctrl for nat\e[0m";
    sudo sh -c "cat << EOF  >> /etc/sysctl.conf
########################################
## mod_install_server
net.ipv4.ip_forward=1
#net.ipv6.conf.all.forwarding=1
EOF";
    }


    ######################################################################
    ## network nat
    sudo iptables -t nat --list | grep -q MASQUERADE 2> /dev/null || {
    echo -e "\e[36m    setup iptables for nat\e[0m";
    sudo iptables -t nat -A POSTROUTING -o $INTERFACE_ETH0 -j MASQUERADE
    sudo dpkg-reconfigure --unseen-only iptables-persistent
    }


    ######################################################################
    ## chrony
    grep -q mod_install_server /etc/chrony/chrony.conf 2> /dev/null || {
    echo -e "\e[36m    setup chrony\e[0m";
    sudo sh -c "cat << EOF  > /etc/chrony/chrony.conf
########################################
## mod_install_server
allow

#server  stratum1.domain.local  iburst  minpoll 5  maxpoll 5
server  ptbtime1.ptb.de  iburst
server  ptbtime2.ptb.de  iburst
server  ptbtime3.ptb.de  iburst
server  ntp1.oma.be  iburst
server  ntp2.oma.be  iburst
server  ntp.certum.pl  iburst
server  ntp1.sp.se  iburst
server  ntp2.sp.se  iburst

server  char-ntp-pool.charite.de
server  isis.uni-paderborn.de

pool  $CUSTOM_LANG.pool.ntp.org  iburst

keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
logdir /var/log/chrony
maxupdateskew 100.0
hwclockfile /etc/adjtime
rtcsync
makestep 1 3
EOF";
    }

}


##########################################################################
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


##########################################################################
handle_hostapd;
handle_dhcpcd;
handle_dnsmasq;
handle_samba;
handle_optional;


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
#handle_iso  $UBUNTU_LTS_X86     $UBUNTU_LTS_X86_URL;
handle_iso  $UBUNTU_X64         $UBUNTU_X64_URL;
#handle_iso  $UBUNTU_X86         $UBUNTU_X86_URL;
handle_iso  $UBUNTU_DAILY_X64   $UBUNTU_DAILY_X64_URL   timestamping;

handle_iso  $LUBUNTU_X64         $LUBUNTU_X64_URL;
#handle_iso  $LUBUNTU_X86         $LUBUNTU_X86_URL;
handle_iso  $LUBUNTU_DAILY_X64   $LUBUNTU_DAILY_X64_URL   timestamping;

#handle_iso  $UBUNTU_NONPAE      $UBUNTU_NONPAE_URL;
#handle_iso  $DEBIAN_X64         $DEBIAN_X64_URL;
#handle_iso  $DEBIAN_X86         $DEBIAN_X86_URL;
#handle_iso  $PARROT_LITE_X64    $PARROT_LITE_X64_URL;
#handle_iso  $PARROT_LITE_X86    $PARROT_LITE_X86_URL;
handle_iso  $PARROT_FULL_X64     $PARROT_FULL_X64_URL;
#handle_iso  $PARROT_FULL_X86     $PARROT_FULL_X86_URL;
#handle_iso  $GNURADIO_X64       $GNURADIO_X64_URL;
#handle_iso  $DEFT_X64           $DEFT_X64_URL;
#handle_iso  $DEFTZ_X64          $DEFTZ_X64_URL          ,gid=root,uid=root,norock,mode=292;
handle_iso  $KALI_X64           $KALI_X64_URL;
handle_iso  $PENTOO_X64         $PENTOO_X64_URL    timestamping;
handle_iso  $SYSTEMRESCTUE_X86  $SYSTEMRESCTUE_X86_URL;
handle_iso  $DESINFECT_X86      $DESINFECT_X86_URL;
handle_iso  $TINYCORE_x64       $TINYCORE_x64_URL       timestamping;
handle_iso  $TINYCORE_x86       $TINYCORE_x86_URL       timestamping;
handle_iso  $RPDESKTOP_X86      $RPDESKTOP_X86_URL;
#handle_iso  $CLONEZILLA_X64     $CLONEZILLA_X64_URL;
handle_iso  $CLONEZILLA_X86     $CLONEZILLA_X86_URL;
handle_iso  $FEDORA_X64         $FEDORA_X64_URL;
##handle_iso  $CENTOS_X64         $CENTOS_X64_URL;
##handle_iso  $TAILS_X64          $TAILS_X64_URL;
##########################################################################
handle_pxe;
handle_ipxe;


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export
##########################################################################
##########################################################################
#handle_zip_img  $PI_CORE   $PI_CORE_URL;
#handle_zip_img  $RPD_LITE  $RPD_LITE_URL  timestamping;
#handle_zip_img  $RPD_FULL  $RPD_FULL_URL  timestamping;
##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to have as pi 3 pxe network booting
##########################################################################
##########################################################################
#handle_rpi_pxe  $PI_CORE  $RPI_SN0  bootcode,config,root;
#handle_rpi_pxe  $RPD_LITE  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
#handle_rpi_pxe  $RPD_FULL  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;


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
