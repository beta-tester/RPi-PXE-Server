#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export, install for PXE boot
## or
## "_unhandle_iso  ...",
##  if you want to delete the entire iso and its nfs export to free disk space
##########################################################################
##########################################################################
_unhandle_iso  $CLONEZILLA_X64  $CLONEZILLA_X64_URL;
_unhandle_iso  $CLONEZILLA_X86  $CLONEZILLA_X86_URL;
_unhandle_iso  $DEBIAN_X64  $DEBIAN_X64_URL;
_unhandle_iso  $DEBIAN_X86  $DEBIAN_X86_URL;
_unhandle_iso  $DEFTZ_X64  $DEFTZ_X64_URL  ,gid=root,uid=root,norock,mode=292;
_unhandle_iso  $DEFT_X64  $DEFT_X64_URL;
_unhandle_iso  $DEVUAN_X64  $DEVUAN_X64_URL;
_unhandle_iso  $DEVUAN_X86  $DEVUAN_X86_URL;
_unhandle_iso  $ESET_SYSRESCUE_X86  $ESET_SYSRESCUE_X86_URL;
_unhandle_iso  $FEDORA_X64  $FEDORA_X64_URL;
_unhandle_iso  $GNURADIO_X64  $GNURADIO_X64_URL;
_unhandle_iso  $KALI_X64  $KALI_X64_URL;
_unhandle_iso  $KASPERSKY_RESCUE_X86  $KASPERSKY_RESCUE_X86_URL  timestamping;
_unhandle_iso  $KNOPPIX_X86  $KNOPPIX_X86_URL;
_unhandle_iso  $LUBUNTU_DAILY_X64  $LUBUNTU_DAILY_X64_URL  timestamping;
_unhandle_iso  $LUBUNTU_LTS_X64  $LUBUNTU_LTS_X64_URL;
_unhandle_iso  $LUBUNTU_LTS_X86  $LUBUNTU_LTS_X86_URL;
_unhandle_iso  $LUBUNTU_X64  $LUBUNTU_X64_URL;
_unhandle_iso  $LUBUNTU_X86  $LUBUNTU_X86_URL;
_unhandle_iso  $MINT_X64  $MINT_X64_URL;
_unhandle_iso  $PARROT_FULL_X64  $PARROT_FULL_X64_URL;
_unhandle_iso  $PARROT_LITE_X64  $PARROT_LITE_X64_URL;
_unhandle_iso  $PENTOO_BETA_X64  $PENTOO_BETA_X64_URL  timestamping;
_unhandle_iso  $PENTOO_X64  $PENTOO_X64_URL  timestamping;
_unhandle_iso  $RPDESKTOP_X86  $RPDESKTOP_X86_URL  timestamping;
_unhandle_iso  $SYSTEMRESCUE_X64  $SYSTEMRESCUE_X64_URL;
handle_iso  $TINYCORE_X64  $TINYCORE_X64_URL  timestamping;
_unhandle_iso  $TINYCORE_X86  $TINYCORE_X86_URL  timestamping;
_unhandle_iso  $UBUNTU_DAILY_X64  $UBUNTU_DAILY_X64_URL  timestamping;
_unhandle_iso  $UBUNTU_LTS_X64  $UBUNTU_LTS_X64_URL;
_unhandle_iso  $UBUNTU_LTS_X86  $UBUNTU_LTS_X86_URL;
_unhandle_iso  $UBUNTU_STUDIO_DAILY_X64  $UBUNTU_STUDIO_DAILY_X64_URL  timestamping;
_unhandle_iso  $UBUNTU_STUDIO_X64  $UBUNTU_STUDIO_X64_URL;
handle_iso  $UBUNTU_X64  $UBUNTU_X64_URL;

#custom#
#handle_iso  $DESINFECT_X64  $DESINFECT_X64_URL;
#handle_iso  $DESINFECT_X86  $DESINFECT_X86_URL;
#_unhandle_iso  $UBUNTU_NONPAE  $UBUNTU_NONPAE_URL;
#handle_iso  $WIN_PE_X86  $WIN_PE_X86_URL;

#broken#
#_unhandle_iso  $ANDROID_X86  $ANDROID_X86_URL;
#_unhandle_iso  $CENTOS_X64  $CENTOS_X64_URL;
#_unhandle_iso  $OPENSUSE_RESCUE_X64  $OPENSUSE_RESCUE_X64_URL  timestamping  ,gid=root,uid=root,norock,mode=292;
#_unhandle_iso  $OPENSUSE_X64  $OPENSUSE_X64_URL  timestamping  ,gid=root,uid=root,norock,mode=292;
#_unhandle_iso  $TAILS_X64  $TAILS_X64_URL;

##########################################################################
#_unhandle_img  $UBUNTU_FWTS  $UBUNTU_FWTS_URL;

##########################################################################
handle_kernel  $ARCH_NETBOOT_X64  $ARCH_NETBOOT_X64_URL  timestamping;


##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to download, mount, export
##########################################################################
##########################################################################
_unhandle_zip_img  $PI_CORE   $PI_CORE_URL;
_unhandle_zip_img  $RPD_BASIC $RPD_BASIC_URL timestamping;
_unhandle_zip_img  $RPD_FULL  $RPD_FULL_URL  timestamping;
_unhandle_zip_img  $RPD_LITE  $RPD_LITE_URL  timestamping;

##########################################################################
##########################################################################
## comment out those entries,
##  you don't want to have as pi 3 pxe network booting
##########################################################################
##########################################################################
#handle_rpi_pxe  $PI_CORE  $RPI_SN0  bootcode,config,root;
#handle_rpi_pxe  $RPD_BASIC $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
#handle_rpi_pxe  $RPD_FULL  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
#handle_rpi_pxe  $RPD_LITE  $RPI_SN0  bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
