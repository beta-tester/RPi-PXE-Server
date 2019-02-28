#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################

# v 2019-02-24

##########################################################################
##########################################################################
## url to iso images, with LiveDVD systems
## note:
##  update the url, if iso is outdated
##########################################################################
##########################################################################
ARCH_NETBOOT_X64=arch-netboot-x64
ARCH_NETBOOT_X64_URL=https://www.archlinux.org/static/netboot/ipxe.lkrn

CLONEZILLA_X64=clonezilla-x64
CLONEZILLA_X64_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.6.0-37/clonezilla-live-2.6.0-37-amd64.iso

CLONEZILLA_X86=clonezilla-x86
CLONEZILLA_X86_URL=https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.6.0-37/clonezilla-live-2.6.0-37-i686.iso

DEBIAN_KVER=4.9.0-8

DEBIAN_X64=debian-x64
DEBIAN_X64_URL=https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-9.8.0-amd64-xfce.iso

DEBIAN_X86=debian-x86
DEBIAN_X86_URL=https://cdimage.debian.org/debian-cd/current-live/i386/iso-hybrid/debian-live-9.8.0-i386-xfce.iso

DEFTZ_X64=deftz-x64
DEFTZ_X64_URL=https://na.mirror.garr.it/mirrors/deft/zero/deftZ-2018-2.iso

DEFT_X64=deft-x64
DEFT_X64_URL=https://na.mirror.garr.it/mirrors/deft/deft-8.2.iso

DEVUAN_X64=devuan-x64
DEVUAN_X64_URL=https://files.devuan.org/devuan_ascii/desktop-live/devuan_ascii_2.0.0_amd64_desktop-live.iso

DEVUAN_X86=devuan-x86
DEVUAN_X86_URL=https://files.devuan.org/devuan_ascii/desktop-live/devuan_ascii_2.0.0_i386_desktop-live.iso

FEDORA_X64=fedora-x64
FEDORA_X64_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/29/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-29-1.2.iso

GNURADIO_X64=gnuradio-x64
GNURADIO_X64_URL=https://s3-dist.gnuradio.org/ubuntu-16.04.2-desktop-amd64-gnuradio-3.7.11.iso

KALI_X64=kali-x64
KALI_X64_URL=https://cdimage.kali.org/current/kali-linux-2018.4-amd64.iso

KASPERSKY_RESCUE_X86=kaspersky-rescue-x86
KASPERSKY_RESCUE_X86_URL=https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso

LUBUNTU_DAILY_X64=lubuntu-daily-x64
LUBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/lubuntu/daily-live/pending/disco-desktop-amd64.iso

LUBUNTU_LTS_X64=lubuntu-lts-x64
LUBUNTU_LTS_X64_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04.2-desktop-amd64.iso

LUBUNTU_LTS_X86=lubuntu-lts-x86
LUBUNTU_LTS_X86_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.04/release/lubuntu-18.04.2-desktop-i386.iso

LUBUNTU_X64=lubuntu-x64
LUBUNTU_X64_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.10/release/lubuntu-18.10-desktop-amd64.iso

LUBUNTU_X86=lubuntu-x86
LUBUNTU_X86_URL=http://cdimage.ubuntu.com/lubuntu/releases/18.10/release/lubuntu-18.10-desktop-i386.iso

MINT_X64=mint-x64
MINT_X64_URL=https://mirrors.edge.kernel.org/linuxmint/stable/19.1/linuxmint-19.1-xfce-64bit.iso

PARROT_FULL_X64=parrot-full-x64
PARROT_FULL_X64_URL=https://cdimage.parrotsec.org/parrot/iso/4.5.1/Parrot-security-4.5.1_amd64.iso

PARROT_LITE_X64=parrot-lite-x64
PARROT_LITE_X64_URL=https://cdimage.parrotsec.org/parrot/iso/4.5.1/Parrot-home-4.5.1_amd64.iso

PENTOO_BETA_X64=pentoo-beta-x64
PENTOO_BETA_X64_URL=https://www.pentoo.ch/isos/latest-iso-symlinks/Beta/pentoo-full-beta-amd64-hardened-latest.iso

PENTOO_X64=pentoo-x64
PENTOO_X64_URL=https://www.pentoo.ch/isos/latest-iso-symlinks/pentoo-full-amd64-hardened-latest.iso

RPDESKTOP_X86=rpdesktop-x86
RPDESKTOP_X86_URL=https://downloads.raspberrypi.org/rpd_x86_latest

SYSTEMRESCUE_X86=systemrescue-x86
SYSTEMRESCUE_X86_URL=https://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/6.0.1/systemrescuecd-6.0.1.iso

TINYCORE_X64=tinycore-x64
TINYCORE_X64_URL=http://tinycorelinux.net/10.x/x86_64/release/TinyCorePure64-current.iso

TINYCORE_X86=tinycore-x86
TINYCORE_X86_URL=http://tinycorelinux.net/10.x/x86/release/TinyCore-current.iso

UBUNTU_DAILY_X64=ubuntu-daily-x64
UBUNTU_DAILY_X64_URL=http://cdimage.ubuntu.com/daily-live/pending/disco-desktop-amd64.iso

UBUNTU_FWTS=ubuntu-fwts
UBUNTU_FWTS_URL=http://fwts.ubuntu.com/fwts-live/fwts-live-18.12.00.img

UBUNTU_LTS_X64=ubuntu-lts-x64
UBUNTU_LTS_X64_URL=http://releases.ubuntu.com/18.04/ubuntu-18.04.2-desktop-amd64.iso

UBUNTU_LTS_X86=ubuntu-lts-x86
UBUNTU_LTS_X86_URL=http://releases.ubuntu.com/16.04/ubuntu-16.04.5-desktop-i386.iso

UBUNTU_STUDIO_DAILY_X64=ubuntu-studio-daily-x64
UBUNTU_STUDIO_DAILY_X64_URL=http://cdimage.ubuntu.com/ubuntustudio/dvd/pending/disco-dvd-amd64.iso

UBUNTU_STUDIO_X64=ubuntu-studio-x64
UBUNTU_STUDIO_X64_URL=http://cdimage.ubuntu.com/ubuntustudio/releases/18.10/release/ubuntustudio-18.10-dvd-amd64.iso

UBUNTU_X64=ubuntu-x64
UBUNTU_X64_URL=http://releases.ubuntu.com/18.10/ubuntu-18.10-desktop-amd64.iso


#custom#
DESINFECT_X64=desinfect-x64
DESINFECT_X64_URL=

DESINFECT_X86=desinfect-x86
DESINFECT_X86_URL=

UBUNTU_NONPAE=ubuntu-nopae
UBUNTU_NONPAE_URL=

WIN_PE_X86=win-pe-x86
WIN_PE_X86_URL=


#broken#
ANDROID_X86=android-x86
ANDROID_X86_URL=https://osdn.net/frs/redir.php?f=android-x86%2F69704%2Fandroid-x86_64-8.1-r1.iso

CENTOS_X64=centos-x64
CENTOS_X64_URL=http://ftp.rrzn.uni-hannover.de/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso

OPENSUSE_RESCUE_X64=opensuse-rescue-x64
OPENSUSE_RESCUE_X64_URL=https://download.opensuse.org/distribution/leap/15.1/live/openSUSE-Leap-15.1-Rescue-CD-x86_64-Current.iso

OPENSUSE_X64=opensuse-x64
OPENSUSE_X64_URL=https://download.opensuse.org/distribution/leap/15.1/live/openSUSE-Leap-15.1-GNOME-Live-x86_64-Current.iso

TAILS_X64=tails-x64
TAILS_X64_URL=https://mirrors.edge.kernel.org/tails/stable/tails-amd64-3.12.1/tails-amd64-3.12.1.iso


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


RPD_BASIC=rpi-raspbian-basic
RPD_BASIC_URL=https://downloads.raspberrypi.org/raspbian_latest

RPD_FULL=rpi-raspbian-full
RPD_FULL_URL=https://downloads.raspberrypi.org/raspbian_full_latest

RPD_LITE=rpi-raspbian-lite
RPD_LITE_URL=https://downloads.raspberrypi.org/raspbian_lite_latest

