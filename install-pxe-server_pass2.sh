#!/bin/sh
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
# v2017-08-11
#
# known issues:
#bridge#

######################################################################
echo -e "\e[32msetup variables\e[0m";
######################################################################
RPI_SN0=12345678
RPI_SN0_BOOT=rpi-$RPI_SN0-boot
RPI_SN0_ROOT=rpi-$RPI_SN0-root


######################################################################
INTERFACE_ETH0=eth0
INTERFACE_BR0=br0

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
######################################################################
IP_ETH0=$(ip -4 addr show dev eth0 | grep -o -E '(([0-9]{1,3}[\.]){3}[0-9]{1,3})' | sed '1!d')
IP_ETH0_=$(echo $IP_ETH0 | grep -E -o "([0-9]{1,3}[\.]){3}")
IP_ETH0_0=$(echo $(echo $IP_ETH0_)0)
IP_ETH0_START=$(echo $(echo $IP_ETH0_)200)
IP_ETH0_END=$(echo $(echo $IP_ETH0_)249)
IP_ETH0_ROUTER=$(echo $(ip rout | grep default | cut -d' ' -f3))
IP_ETH0_DNS=$IP_ETH0_ROUTER
IP_ETH0_MASK=255.255.255.0
IP_BR0=192.168.250.1
IP_BR0_START=192.168.250.150
IP_BR0_END=192.168.250.199
IP_BR0_MASK=255.255.255.0

echo
echo -e "\e[32m$IP_ETH0 is used as primary IP address\e[0m";
echo

######################################################################
WIN_PE_X86_URL=
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-amd64.iso
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-desktop-i386.iso
UBUNTU_X64_URL=http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-amd64.iso
UBUNTU_X86_URL=http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-i386.iso
UBUNTU_NONPAE_URL=
DEBIAN_X64_URL=http://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.1.0-amd64-lxde.iso
DEBIAN_X86_URL=http://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.1.0-i386-lxde.iso
GNURADIO_X64_URL=http://s3-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso
DEFT_X64_URL=http://na.mirror.garr.it/mirrors/deft/deft-8.2.iso
KALI_X64_URL=http://cdimage.kali.org/kali-2017.1/kali-linux-2017.1-amd64.iso
PENTOO_X64_URL=http://mirror.switch.ch/ftp/mirror/pentoo/Pentoo_amd64_default/pentoo-amd64-default-2015.0_RC5.iso
SYSTEMRESCTUE_X86_URL=http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/5.0.3/systemrescuecd-x86-5.0.3.iso
TAILS_X64_URL=https://mirrors.kernel.org/tails/stable/tails-amd64-3.1/tails-amd64-3.1.iso
DESINFECT_X86_URL=
TINYCORE_x86_URL=http://tinycorelinux.net/8.x/x86/release/TinyCore-current.iso
TINYCORE_x64_URL=http://tinycorelinux.net/8.x/x86_64/release/TinyCorePure64-current.iso
RPDESKTOP_X86_URL=http://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2017-06-23/2017-06-22-rpd-x86-jessie.iso

WIN_PE_X86=win-pe-x86
UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_X64=ubuntu-x64
UBUNTU_X86=ubuntu-x86
UBUNTU_NONPAE=ubuntu-nopae
DEBIAN_X64=debian-x64
DEBIAN_X86=debian-x86
GNURADIO_X64=gnuradio-x64
DEFT_X64=deft-x64
KALI_X64=kali-x64
PENTOO_X64=pentoo-x64
SYSTEMRESCTUE_X86=systemrescue-x86
TAILS_X64=tails-x64
DESINFECT_X86=desinfect-x86
TINYCORE_x86=tinycore-x86
TINYCORE_x64=tinycore-x64
RPDESKTOP_X86=rpdesktop-x86


######################################################################
RPD_LITE_URL=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-07-05/2017-07-05-raspbian-jessie-lite.zip
RPD_LITE=rpi-raspbian-lite
RPD_LITE_OFFSET_BOOT=8192
RPD_LITE_SIZE_BOOT=85405
RPD_LITE_OFFSET_ROOT=94208
RPD_LITE_SIZE_ROOT=3276162

RPD_FULL_URL=http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/2017-07-05-raspbian-jessie.zip
RPD_FULL=rpi-raspbian-full
RPD_FULL_OFFSET_BOOT=8192
RPD_FULL_SIZE_BOOT=85405
RPD_FULL_OFFSET_ROOT=94208
RPD_FULL_SIZE_ROOT=9010252


######################################################################
sudo mkdir -p $DST_ISO;
sudo mkdir -p $DST_IMG;
sudo mkdir -p $DST_TFTP_ETH0;
sudo mkdir -p $DST_NFS_ETH0;


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
    echo -e "\e[32m($NAME)...\e[0m";
    if ! [ -d "$DST_ISO/" ]; then sudo mkdir -p $DST_ISO/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_ETH0/$NAME 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$NAME 2> /dev/null;

    if [ "$URL" == "" ]; then
        if ! [ -f "$DST_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_ISO" ] \
        && [ -f "$SRC_ISO/$FILE_URL" ]; \
        then
            echo -e "\e[32m($NAME) copy iso from usb-stick\e[0m";
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
	        echo -e "\e[32m($NAME) copy iso from usb-stick\e[0m";
	        sudo rm -f $DST_ISO/$FILE_URL;
	        sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_ISO  $DST_ISO;
	        sudo rsync -xa --info=progress2 $SRC_ISO/$FILE_URL  $DST_ISO;
        fi

        if ! [ -f "$DST_ISO/$FILE_ISO" ] \
        || ! grep -q "$URL" $DST_ISO/$FILE_URL 2> /dev/null; \
        then
	        echo -e "\e[32m($NAME) download iso image\e[0m";
	        sudo rm -f $DST_ISO/$FILE_URL;
	        sudo rm -f $DST_ISO/$FILE_ISO;
	        sudo wget -O $DST_ISO/$FILE_ISO  $URL;

            sudo sh -c "echo '$URL' > $DST_ISO/$FILE_URL";
            sudo touch -r $DST_ISO/$FILE_ISO  $DST_ISO/$FILE_URL;
        fi
    fi

    if [ -f "$DST_ISO/$FILE_ISO" ]; then
        if ! [ -d "$DST_NFS_ETH0/$NAME" ]; then
            echo -e "\e[32m($NAME) create nfs folder\e[0m";
            sudo mkdir -p $DST_NFS_ETH0/$NAME;
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/fstab; then
            echo -e "\e[32m($NAME) add iso image to fstab\e[0m";
            sudo sh -c "echo '$DST_ISO/$FILE_ISO  $DST_NFS_ETH0/$NAME  auto  ro,nofail,auto,loop  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ETH0/$NAME" /etc/exports; then
            echo -e "\e[32m($NAME) add nfs folder to exports\e[0m";
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
[ -f /etc/dnsmasq.d/pxe-server ] || {
echo -e "\e[32msetup dnsmasq for pxe\e[0m";
sudo sh -c "echo '########################################
#/etc/dnsmasq.d/pxeboot

## mod_install_server

log-dhcp
log-queries

# interface selection
interface=$INTERFACE_ETH0
#bridge#interface=$INTERFACE_BR0

# TFTP (enabled)
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
' >> /etc/dnsmasq.d/pxe-server";
sudo systemctl restart dnsmasq.service;
}


######################################################################
grep -q mod_install_server /etc/samba/smb.conf 2> /dev/null || ( \
echo -e "\e[32msetup samba\e[0m";
sudo sed -i /etc/samba/smb.conf -n -e "1,/#======================= Share Definitions =======================/p";
sudo sh -c "echo '########################################
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
' >> /etc/samba/smb.conf"
sudo systemctl restart smbd.service;
)


######################################################################
handle_iso  $WIN_PE_X86        $WIN_PE_X86_URL;
handle_iso  $UBUNTU_LTS_X64    $UBUNTU_LTS_X64_URL;
handle_iso  $UBUNTU_LTS_X86    $UBUNTU_LTS_X86_URL;
handle_iso  $UBUNTU_X64        $UBUNTU_X64_URL;
handle_iso  $UBUNTU_X86        $UBUNTU_X86_URL;
handle_iso  $UBUNTU_NONPAE     $UBUNTU_NONPAE_URL;
handle_iso  $DEBIAN_X64        $DEBIAN_X64_URL;
handle_iso  $DEBIAN_X86        $DEBIAN_X86_URL;
handle_iso  $GNURADIO_X64      $GNURADIO_X64_URL;
handle_iso  $DEFT_X64          $DEFT_X64_URL;
handle_iso  $KALI_X64          $KALI_X64_URL;
handle_iso  $PENTOO_X64        $PENTOO_X64_URL;
handle_iso  $SYSTEMRESCTUE_X86 $SYSTEMRESCTUE_X86_URL;
handle_iso  $TAILS_X64         $TAILS_X64_URL;
handle_iso  $DESINFECT_X86     $DESINFECT_X86_URL;
handle_iso  $TINYCORE_x64      $TINYCORE_x64_URL;
handle_iso  $TINYCORE_x86      $TINYCORE_x86_URL;
handle_iso  $RPDESKTOP_X86     $RPDESKTOP_X86_URL;
######################################################################
echo -e "\e[32mbackup new iso images to usb-stick\e[0m";
sudo rsync -xa --info=progress2 $DST_ISO/*  $SRC_ISO/


######################################################################
handle_pxe_menu() {
    # $1 : menu short name
    # $2 : menu file name
    ##############################################################
    local FILE_MENU=$DST_TFTP_ETH0/$1/pxelinux.cfg/$2
    ##############################################################
    echo -e "\e[32msetup sys menu for pxe\e[0m";
    [ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ] || sudo mkdir -p $DST_TFTP_ETH0/$1/pxelinux.cfg;
[ -d "$DST_TFTP_ETH0/$1/pxelinux.cfg" ] && sudo sh -c "echo '########################################
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

' > $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_TFTP_ETH0/$1/pxeboot.0" ] && sudo sh -c "echo '########################################
LABEL Windows PE x86 (PXE)
    PXE /pxeboot.0
    TEXT HELP
        Boot to Windows PE 32bit
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_ISO/$WIN_PE_X86.iso" ] && sudo sh -c "echo '########################################
LABEL Windows PE x86 (ISO)
    KERNEL /memdisk
    APPEND iso
    INITRD $ISO/$WIN_PE_X86.iso
    TEXT HELP
        Boot to Windows PE 32bit ISO ~400MB
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz.efi" ] && sudo sh -c "echo '########################################
LABEL Ubuntu LTS x64
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu LTS x64 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL Ubuntu LTS x86
    KERNEL $NFS_ETH0/$UBUNTU_LTS_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_LTS_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_LTS_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu LTS x86 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$UBUNTU_X64/casper/vmlinuz.efi" ] && sudo sh -c "echo '########################################
LABEL Ubuntu x64
    KERNEL $NFS_ETH0/$UBUNTU_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$UBUNTU_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu x64 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$UBUNTU_X86/casper/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL Ubuntu x86
    KERNEL $NFS_ETH0/$UBUNTU_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu x86 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL  Ubuntu non-PAE x86
    KERNEL $NFS_ETH0/$UBUNTU_NONPAE/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$UBUNTU_NONPAE/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$UBUNTU_NONPAE  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to Ubuntu non-PAE x86 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$DEBIAN_X64/live/vmlinuz-4.9.0-3-amd64" ] && sudo sh -c "echo '########################################
LABEL Debian x64
    KERNEL $NFS_ETH0/$DEBIAN_X64/live/vmlinuz-4.9.0-3-amd64
    APPEND initrd=$NFS_ETH0/$DEBIAN_X64/live/initrd.img-4.9.0-3-amd64  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X64  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Debian x64 Live LXDE
        User: user, Password: live
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$DEBIAN_X86/live/vmlinuz-4.9.0-3-686" ] && sudo sh -c "echo '########################################
LABEL Debian x86
    KERNEL $NFS_ETH0/$DEBIAN_X86/live/vmlinuz-4.9.0-3-686
    APPEND initrd=$NFS_ETH0/$DEBIAN_X86/live/initrd.img-4.9.0-3-686  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEBIAN_X86  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Debian x86 Live LXDE
        User: user, Password: live
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi" ] && sudo sh -c "echo '########################################
LABEL GNU Radio x64
    KERNEL $NFS_ETH0/$GNURADIO_X64/casper/vmlinuz.efi
    APPEND initrd=$NFS_ETH0/$GNURADIO_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$GNURADIO_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to GNU Radio x64 Live
        User: ubuntu
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$KALI_X64/live/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL Kali x64
    KERNEL $NFS_ETH0/$KALI_X64/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$KALI_X64/live/initrd.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$KALI_X64  boot=live  noconfig=sudo  username=root  hostname=kali  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Kali x64 Live
        User: root, Password: toor
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$DEFT_X64/casper/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL DEFT x64
    KERNEL $NFS_ETH0/$DEFT_X64/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$DEFT_X64/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DEFT_X64  file=/cdrom/preseed/ubuntu.seed  boot=casper  memtest=4  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to DEFT x64 Live
        User: root, Password: toor
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$PENTOO_X64/isolinux/pentoo" ] && sudo sh -c "echo '########################################
LABEL Pentoo x64
    KERNEL $NFS_ETH0/$PENTOO_X64/isolinux/pentoo
    APPEND initrd=$NFS_ETH0/$PENTOO_X64/isolinux/pentoo.igz  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$PENTOO_X64 real_root=/dev/nfs  root=/dev/ram0  init=/linuxrc  aufs  looptype=squashfs  loop=/image.squashfs  cdroot  nox  --  keymap=de
    TEXT HELP
        Boot to Pentoo x64 Live
        User: pentoo
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/rescue32" ] && sudo sh -c "echo '########################################
LABEL System Rescue x86
    KERNEL $NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/rescue32
    APPEND initrd=$NFS_ETH0/$SYSTEMRESCTUE_X86/isolinux/initram.igz  netboot=nfs://$IP_ETH0:$DST_NFS_ETH0/$SYSTEMRESCTUE_X86  dodhcp  --  setkmap=de
    TEXT HELP
        Boot to System Rescue x86 Live
        User: root
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$TAILS_X64/live/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL Tails x64
    KERNEL $NFS_ETH0/$TAILS_X64/live/vmlinuz
    APPEND initrd=$NFS_ETH0/$TAILS_X64/live/initrd.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$TAILS_X64  boot=live  config  --  break  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Tails x64 Live (modprobe r8169; exit)
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$DESINFECT_X86/casper/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL desinfect x86
    KERNEL $NFS_ETH0/$DESINFECT_X86/casper/vmlinuz
    APPEND initrd=$NFS_ETH0/$DESINFECT_X86/casper/initrd.lz  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$DESINFECT_X86  file=/cdrom/preseed/ubuntu.seed  boot=casper  memtest=4  rmdns  --  debian-installer/language=de  console-setup/layoutcode?=de  locale=de_DE
    TEXT HELP
        Boot to ct desinfect x86
        User: desinfect
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64" ] && sudo sh -c "echo '########################################
LABEL tiny core x64
    KERNEL $NFS_ETH0/$TINYCORE_x64/boot/vmlinuz64
    APPEND initrd=$NFS_ETH0/$TINYCORE_x64/boot/corepure64.gz  loglevel=3  cde  waitusb=5  __vga=791  --  lang=de  kmap=de
    TEXT HELP
        Boot to tiny core x64
        User: tc
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$TINYCORE_x86/boot/vmlinuz" ] && sudo sh -c "echo '########################################
LABEL tiny core x86
    KERNEL $NFS_ETH0/$TINYCORE_x86/boot/vmlinuz
    APPEND initrd=$NFS_ETH0/$TINYCORE_x86/boot/core.gz  loglevel=3  cde  waitusb=5  __vga=791  --  lang=de  kmap=de
    TEXT HELP
        Boot to tiny core x86
        User: tc
    ENDTEXT

' >> $FILE_MENU";

[ -f "$FILE_MENU" ] && [ -f "$DST_NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2" ] && sudo sh -c "echo '########################################
LABEL Raspberry Pi Desktop
    KERNEL $NFS_ETH0/$RPDESKTOP_X86/live/vmlinuz2
    APPEND initrd=$NFS_ETH0/$RPDESKTOP_X86/live/initrd2.img  netboot=nfs  nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPDESKTOP_X86  boot=live  config  --  locales=de_DE  keyboard-layouts=de
    TEXT HELP
        Boot to Raspberry Pi Desktop
        User: pi, Password: raspberry
    ENDTEXT

' >> $FILE_MENU";
}


######################################################################
echo -e "\e[32mcopy win-pe stuff\e[0m";
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
echo -e "\e[32msetup sys menu files for pxe bios\e[0m";
[ -d "$DST_TFTP_ETH0/$DST_PXE_BIOS" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_BIOS;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/pxelinux.0" ]   || sudo ln -s /usr/lib/PXELINUX/pxelinux.0                 $DST_TFTP_ETH0/$DST_PXE_BIOS/pxelinux.0;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/ldlinux.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/ldlinux.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/bios/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_BIOS/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/bios/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_BIOS/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/memdisk" ]      || sudo ln -s /usr/lib/syslinux/memdisk                    $DST_TFTP_ETH0/$DST_PXE_BIOS/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_BIOS/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                               $DST_TFTP_ETH0/$DST_PXE_BIOS/nfs;
handle_pxe_menu  $DST_PXE_BIOS  default;

######################################################################
echo -e "\e[32msetup sys menu files for pxe efi32\e[0m";
[ -d "$DST_TFTP_ETH0/$DST_PXE_EFI32" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI32;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/syslinux.0" ]   || sudo ln -s /usr/lib/syslinux/modules/efi32/syslinux.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/syslinux.0;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/ldlinux.e32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/ldlinux.e32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi32/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI32/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi32/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI32/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI32/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI32/nfs;
handle_pxe_menu  $DST_PXE_EFI32  efidefault;

######################################################################
echo -e "\e[32msetup sys menu files for pxe efi64\e[0m";
[ -d "$DST_TFTP_ETH0/$DST_PXE_EFI64" ]              || sudo mkdir -p $DST_TFTP_ETH0/$DST_PXE_EFI64;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/syslinux.0" ]   || sudo ln -s /usr/lib/syslinux/modules/efi64/syslinux.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/syslinux.0;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/ldlinux.e64" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/ldlinux.e64   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/vesamenu.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/vesamenu.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libcom32.c32" ] || sudo ln -s /usr/lib/syslinux/modules/efi64/libcom32.c32  $DST_TFTP_ETH0/$DST_PXE_EFI64/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/libutil.c32" ]  || sudo ln -s /usr/lib/syslinux/modules/efi64/libutil.c32   $DST_TFTP_ETH0/$DST_PXE_EFI64/;
[ -h "$DST_TFTP_ETH0/$DST_PXE_EFI64/nfs" ]          || sudo ln -s $DST_NFS_ETH0/                                $DST_TFTP_ETH0/$DST_PXE_EFI64/nfs;
handle_pxe_menu  $DST_PXE_EFI64  efidefault;


######################################################################
echo -e "\e[32mcopy rpi stuff\e[0m";
[ -f "$DST_TFTP_ETH0/bootcode.bin" ] || sudo wget -O $DST_TFTP_ETH0/bootcode.bin  https://github.com/raspberrypi/firmware/raw/next/boot/bootcode.bin;
#[ -f "$DST_TFTP_ETH0/start.elf" ]    || sudo wget -O $DST_TFTP_ETH0/start.elf     https://github.com/raspberrypi/firmware/raw/next/boot/start.elf;


######################################################################
handle_zip_img() {
    # $1 : short name
    # $2 : download ulr
    # $3 : mount offset /boot
    # $4 : mount size /boot
    # $5 : mount offset /root
    # $6 : mount size /root
    ##############################################################
    local NAME=$1
    local URL=$2
    local OFFSET_BOOT=$((512*$3))
    local SIZE_BOOT=$((512*$4))
    local OFFSET_ROOT=$((512*$5))
    local SIZE_ROOT=$((512*$6))
    local RAW_FILENAME=$(basename $URL .zip)
    local RAW_FILENAME_IMG=$RAW_FILENAME.img
    local RAW_FILENAME_ZIP=$RAW_FILENAME.zip
    local DIR_BOOT=$NAME-boot
    local DIR_ROOT=$NAME-root
    local FILE_URL=$NAME.url
    local FILE_IMG=$NAME.img
    ##############################################################
    if ! [ -d "$DST_IMG/" ]; then sudo mkdir -p $DST_IMG/; fi
    if ! [ -d "$DST_NFS_ETH0/" ]; then sudo mkdir -p $DST_NFS_ETH0/; fi

    sudo exportfs -u *:$DST_NFS_ETH0/$DIR_BOOT 2> /dev/null;
    sudo umount -f $FILE_IMG/$DIR_BOOT 2> /dev/null;

    sudo exportfs -u *:$DST_NFS_ETH0/$DIR_ROOT 2> /dev/null;
    sudo umount -f $DST_NFS_ETH0/$DIR_ROOT 2> /dev/null;

    if [ "$URL" == "" ]; then
	    if ! [ -f "$DST_IMG/$FILE_IMG" ] \
	    && [ -f "$SRC_IMG/$FILE_IMG" ] \
	    && [ -f "$SRC_IMG/$FILE_URL" ]; \
	    then
		    echo -e "\e[32m($NAME) copy img from usb-stick\e[0m";
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
		    echo -e "\e[32m($NAME) copy img from usb-stick\e[0m";
		    sudo rm -f $FILE_IMG/$FILE_URL;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_IMG  $DST_IMG;
		    sudo rsync -xa --info=progress2 $SRC_IMG/$FILE_URL  $DST_IMG;
	    fi

	    if ! [ -f "$DST_IMG/$FILE_IMG" ] \
	    || ! grep -q "$URL" $DST_IMG/$FILE_URL 2> /dev/null; \
	    then
		    echo -e "\e[32m($NAME) download image\e[0m";
		    sudo rm -f $DST_IMG/$FILE_IMG;
		    sudo rm -f $DST_IMG/$FILE_URL;
		    sudo wget -O $DST_IMG/$RAW_FILENAME_ZIP  $URL;
		    echo -e "\e[32m($NAME) extract image\e[0m";
		    sudo unzip $DST_IMG/$RAW_FILENAME_ZIP  -d $DST_IMG;
		    sudo rm -f $DST_IMG/$RAW_FILENAME_ZIP;
		    sudo mv $DST_IMG/$RAW_FILENAME_IMG  $DST_IMG/$FILE_IMG;

            sudo sh -c "echo '$URL' > $DST_IMG/$FILE_URL";
            sudo touch -r $DST_IMG/$FILE_IMG  $DST_IMG/$FILE_URL;
	    fi
    fi

    if [ -f "$DST_IMG/$FILE_IMG" ]; then
        ## boot
        if ! [ -d "$DST_NFS_ETH0/$DIR_BOOT" ]; then
	        echo -e "\e[32m($NAME) create image-boot folder\e[0m";
	        sudo mkdir -p $DST_NFS_ETH0/$DIR_BOOT;
        fi

        if ! grep -q "$DST_NFS_ETH0/$DIR_BOOT" /etc/fstab; then
	        echo -e "\e[32m($NAME) add image-boot to fstab\e[0m";
	        sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_ETH0/$DIR_BOOT  auto  ro,nofail,auto,loop,offset=$OFFSET_BOOT,sizelimit=$SIZE_BOOT  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ETH0/$DIR_BOOT" /etc/exports; then
	        echo -e "\e[32m($NAME) add image-boot folder to exports\e[0m";
	        sudo sh -c "echo '$DST_NFS_ETH0/$DIR_BOOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        ## root
        if ! [ -d "$DST_NFS_ETH0/$DIR_ROOT" ]; then
	        echo -e "\e[32m($NAME) create image-root folder\e[0m";
	        sudo mkdir -p $DST_NFS_ETH0/$DIR_ROOT;
        fi

        if ! grep -q "$DST_NFS_ETH0/$DIR_ROOT" /etc/fstab; then
	        echo -e "\e[32m($NAME) add image-root to fstab\e[0m";
	        sudo sh -c "echo '$DST_IMG/$FILE_IMG  $DST_NFS_ETH0/$DIR_ROOT  auto  ro,nofail,auto,loop,offset=$OFFSET_ROOT,sizelimit=$SIZE_ROOT  0  0' >> /etc/fstab";
        fi

        if ! grep -q "$DST_NFS_ETH0/$DIR_ROOT" /etc/exports; then
	        echo -e "\e[32m($NAME) add image-root folder to exports\e[0m";
	        sudo sh -c "echo '$DST_NFS_ETH0/$DIR_ROOT  *(ro,async,no_subtree_check,root_squash,mp)' >> /etc/exports";
        fi

        sudo mount $DST_NFS_ETH0/$DIR_BOOT;
        sudo exportfs *:$DST_NFS_ETH0/$DIR_BOOT;

        sudo mount $DST_NFS_ETH0/$DIR_ROOT;
        sudo exportfs *:$DST_NFS_ETH0/$DIR_ROOT;
    else
        ## boot
        sudo sed /etc/fstab   -i -e "/$DIR_BOOT/d"
        sudo sed /etc/exports -i -e "/$DIR_BOOT/d"
        ## root
        sudo sed /etc/fstab   -i -e "/$DIR_ROOT/d"
        sudo sed /etc/exports -i -e "/$DIR_ROOT/d"
    fi
}

######################################################################
handle_zip_img  $RPD_LITE  $RPD_LITE_URL  $RPD_LITE_OFFSET_BOOT  $RPD_LITE_SIZE_BOOT  $RPD_LITE_OFFSET_ROOT  $RPD_LITE_SIZE_ROOT;
handle_zip_img  $RPD_FULL  $RPD_FULL_URL  $RPD_FULL_OFFSET_BOOT  $RPD_FULL_SIZE_BOOT  $RPD_FULL_OFFSET_ROOT  $RPD_FULL_SIZE_ROOT;

######################################################################
echo -e "\e[32mbackup new images to usb-stick\e[0m";
sudo rsync -xa --info=progress2 $DST_IMG/*  $SRC_IMG/



######################################################################
[ -d "$DST_NFS_ETH0/$RPI_SN0_BOOT" ] || sudo mkdir -p $DST_NFS_ETH0/$RPI_SN0_BOOT;
[ -d "$DST_NFS_ETH0/$RPI_SN0_ROOT" ] || sudo mkdir -p $DST_NFS_ETH0/$RPI_SN0_ROOT;
[ -h "$DST_TFTP_ETH0/$RPI_SN0" ]     || sudo ln -s $DST_NFS_ETH0/$RPI_SN0_BOOT/  $DST_TFTP_ETH0/$RPI_SN0;

grep -q "$DST_NFS_ETH0/$RPI_SN0_ROOT" /etc/exports || {
echo -e "\e[32m($RPI_SN0_ROOT) add nfs folder to exports\e[0m";
sudo sh -c "echo '$DST_NFS_ETH0/$RPI_SN0_BOOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
sudo exportfs *:$DST_NFS_ETH0/$RPI_SN0_BOOT;
};

grep -q "$DST_NFS_ETH0/$RPI_SN0_ROOT" /etc/exports || {
echo -e "\e[32m($RPI_SN0_ROOT) add nfs folder to exports\e[0m";
sudo sh -c "echo '$DST_NFS_ETH0/$RPI_SN0_ROOT  *(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports";
sudo exportfs *:$DST_NFS_ETH0/$RPI_SN0_ROOT;
};

[ -f "$DST_NFS_ETH0/$RPI_SN0_BOOT/bootcode.bin" ] || {
echo -e "\e[32m($RPI_SN0_BOOT) copy boot files\e[0m";
sudo rsync -xa --info=progress2 $DST_NFS_ETH0/$RPD_LITE-boot/*  $DST_NFS_ETH0/$RPI_SN0_BOOT/
}

[ -d "$DST_NFS_ETH0/$RPI_SN0_ROOT/etc" ] || {
echo -e "\e[32m($RPI_SN0_ROOT) copy root files\e[0m";
sudo rsync -xa --info=progress2 $DST_NFS_ETH0/$RPD_LITE-root/*  $DST_NFS_ETH0/$RPI_SN0_ROOT/
}

[ -d "$DST_NFS_ETH0/$RPI_SN0_BOOT/ssh" ] || {
sudo touch $DST_NFS_ETH0/$RPI_SN0_BOOT/ssh
}

grep -q mod_install_server $DST_NFS_ETH0/$RPI_SN0_BOOT/cmdline.txt || {
sudo sh -c "echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT rw ip=dhcp rootwait elevator=deadline  --  mod_install_server' > $DST_NFS_ETH0/$RPI_SN0_BOOT/cmdline.txt";
}

grep -q mod_install_server $DST_NFS_ETH0/$RPI_SN0_ROOT/etc/fstab || {
sudo sh -c "echo '########################################
## mod_install_server

proc  /proc  proc  defaults  0  0
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_BOOT  /boot  nfs   defaults,nofail,noatime  0  2
$IP_ETH0:$DST_NFS_ETH0/$RPI_SN0_ROOT  /      nfs   defaults,nofail,noatime  0  1
' > $DST_NFS_ETH0/$RPI_SN0_ROOT/etc/fstab";
}

grep -q mod_install_server $DST_NFS_ETH0/$RPI_SN0_BOOT/config.txt || {
sudo sh -c "echo '########################################
## mod_install_server
dtparam=audio=on

max_usb_current=1
force_turbo=1

disable_overscan=1
hdmi_force_hotplug=1
config_hdmi_boost=4
hdmi_drive=2
hdmi_ignore_cec_init=1
cec_osd_name=NetBoot

########################################
##4k@15Hz custom DMT - mode
#hdmi_group=2
#hdmi_mode=87
#hdmi_cvt 3840 2160 15
#max_framebuffer_width=3840
#max_framebuffer_height=2160
#hdmi_pixel_freq_limit=400000000
' > $DST_NFS_ETH0/$RPI_SN0_BOOT/config.txt";
}


######################################################################
#sudo chmod 755 $(find $DST_TFTP_ETH0/ -type d) 2>/dev/null
#sudo chmod 644 $(find $DST_TFTP_ETH0/ -type f) 2>/dev/null
#sudo chmod 755 $(find $DST_TFTP_ETH0/ -type l) 2>/dev/null
#sudo chown -R root:root /srv/ 2>/dev/null
#sudo chown -R root:root $DST_TFTP_ETH0 2>/dev/null
#sudo chown -R root:root $DST_TFTP_ETH0/ 2>/dev/null


######################################################################
grep -q mod_install_server /etc/network/interfaces || {
echo -e "\e[32msetup networking, disable dhcpcd\e[0m";
sudo sh -c "echo '########################################
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
auto eth0
iface eth0 inet static
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
' > /etc/network/interfaces";

echo "nameserver $IP_ETH0_DNS" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
sudo rm /etc/resolvconf/update.d/dnsmasq
sudo systemctl disable dhcpcd.service;
sudo systemctl enable networking.service;
}


######################################################################
## network bridge
#bridge#grep -q mod_install_server /etc/sysctrl.conf 2> /dev/null || {
#bridge#echo -e "\e[32msetup sysctrl for bridging\e[0m";
#bridge#sudo sh -c "echo '########################################
#bridge### mod_install_server
#bridge#net.ipv4.ip_forward=1
#bridge#net.ipv6.conf.all.forwarding=1
#bridge##net.ipv6.conf.all.disable_ipv6 = 1
#bridge#' >> /etc/sysctl.conf";
#bridge#}


######################################################################
## network bridge
#bridge#sudo iptables -t nat --list | grep -q MASQUERADE 2> /dev/null || {
#bridge#echo -e "\e[32msetup iptables for bridging\e[0m";
#bridge#sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#bridge#sudo dpkg-reconfigure iptables-persistent
#bridge#}


######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
