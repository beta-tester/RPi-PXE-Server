#!/bin/bash

########################################################################
if [[ -z "$script_dir" ]]
then
  echo 'do not run this script directly !'
  echo 'this script is part of run.sh'
  exit -1
fi
########################################################################


########################################################################
#
# Action:
#   '+' = Add image to PXE service
#         Download if not there
#         Update if new version is available
#
#   '-' = Remove image from PXE service
#         Free resources on server
#         If backup exist, keep updating backup
#
#   '#' = Skip image handling
#         Keep everything untouched
#         Does not updating backup
#         Good, when timestamping option is set but want to keep the current version and you don't want to download each daily update
#
# Type:
#   iso     = Iso image (ISO, UDF, ISO_HYBRID)
#
#   img     = Hard drive image (MPT, GPT)
#
#   kernel  = Kernel
#
#   zip_img = Zip file containing a hard drive image (zip -> img -> MTP/GPT)
#
#   rpi_pxe = Only if you want to pxe boot a RPi3.
#               Copies files from its selected image boot & root partition to PXE server directories
#               Requires an already mounted hard drive image (img or zip_img)
#               Note: Action '-' does nothing for rpi_pxe. It is not implemented.
#                     You have to free resources for rpi_pxe by hand
# Note:
#     Do not put the $ in fornt of the VARIABLE name !!!
#     the handle_item functions do need the NAME of the VARIABLE (without _URL)

########################################################################
#-----------+----+-----+------------------------+-----------------------
#exec       |act.|type |VAR. name of item       |optional options
handle_item  '-'  iso   BLACKARCH_X64;
handle_item  '-'  iso   CLONEZILLA_X64;
handle_item  '-'  iso   CLONEZILLA_X86;
handle_item  '+'  iso   DEBIAN_X64;
handle_item  '-'  iso   DEBIAN_X86;
handle_item  '-'  iso   DEVUAN_X64;
handle_item  '-'  iso   DEVUAN_X86;
handle_item  '-'  iso   DRAGONOS_X64;
handle_item  '-'  iso   ESET_SYSRESCUE_X86;
handle_item  '+'  iso   FEDORA_X64;
handle_item  '-'  iso   GNURADIO_X64;
handle_item  '-'  iso   KALI_X64;
handle_item  '#'  iso   KASPERSKY_RESCUE_X86     timestamping;
handle_item  '-'  iso   KNOPPIX_X86;
handle_item  '#'  iso   LUBUNTU_DAILY_X64        timestamping;
handle_item  '-'  iso   LUBUNTU_LTS_X64;
handle_item  '-'  iso   LUBUNTU_LTS_X86;
handle_item  '-'  iso   LUBUNTU_X64;
handle_item  '-'  iso   LUBUNTU_X86;
handle_item  '-'  iso   MINT_X64;
handle_item  '#'  iso   OPENSUSE_RESCUE_X64      timestamping  ,gid=root,uid=root,norock,mode=292  vbladed 0 1;
handle_item  '+'  iso   OPENSUSE_X64             timestamping  ,gid=root,uid=root,norock,mode=292  vbladed 1 1;
handle_item  '-'  iso   PARROT_FULL_X64;
handle_item  '-'  iso   PARROT_LITE_X64;
handle_item  '#'  iso   PENTOO_BETA_X64          timestamping;
handle_item  '#'  iso   PENTOO_X64               timestamping;
handle_item  '#'  iso   RPDESKTOP_X86            timestamping;
handle_item  '-'  iso   SYSTEMRESCUE_X64;
handle_item  '+'  iso   TINYCORE_X64             timestamping;
handle_item  '#'  iso   TINYCORE_X86             timestamping;
handle_item  '#'  iso   UBUNTU_DAILY_X64         timestamping;
handle_item  '-'  iso   UBUNTU_LTS_X64;
handle_item  '-'  iso   UBUNTU_LTS_X86;
handle_item  '#'  iso   UBUNTU_STUDIO_DAILY_X64  timestamping;
handle_item  '-'  iso   UBUNTU_STUDIO_X64;
handle_item  '+'  iso   UBUNTU_X64;

#custom#
handle_item  '+'  iso   DESINFECT_X64;
handle_item  '+'  iso   DESINFECT_X86;
handle_item  '-'  iso   UBUNTU_NONPAE;
handle_item  '+'  iso   WIN_PE_X86;
handle_item  '+'  iso   WIN_PE_X64;

#broken#
handle_item  '-'  iso   ANDROID_X86;
handle_item  '-'  iso   CENTOS_X64;
handle_item  '-'  iso   TAILS_X64;

#discontinued# handle_item  '#'  iso    DEFT_X64;
#discontinued# handle_item  '#'  iso    DEFTZ_X64  ,gid=root,uid=root,norock,mode=292;


########################################################################
#-----------+----+-----+------------------------+-----------------------
#exec       |act.|type |VAR. name of item       |optional options
handle_item  '-'  img   UBUNTU_FWTS;


########################################################################
#-----------+----+--------+--------------------+------------------------
#exec       |act.|type    |VAR. name of item   |optional options
handle_item  '#'  kernel   ARCH_NETBOOT_X64     timestamping;


########################################################################
#-----------+----+--------+--------------------+------------------------
#exec       |act.|type    |VAR. name of item   |optional options
handle_item  '-'  zip_img  PI_CORE;
handle_item  '#'  zip_img  RPD_BASIC            timestamping;
handle_item  '#'  zip_img  RPD_FULL             timestamping;
handle_item  '#'  zip_img  RPD_LITE             timestamping;


########################################################################
## must be the last, because it requireas an already mounted image
########################################################################
#-----------+----+--------+----------+---------+------------------------
#exec       |act.|type    |VAR. name |VAR. sn  |optional options
handle_item  '-'  rpi_pxe  PI_CORE    RPI_SN0   bootcode,config,root;
handle_item  '-'  rpi_pxe  RPD_BASIC  RPI_SN0   bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
handle_item  '-'  rpi_pxe  RPD_FULL   RPI_SN0   bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
handle_item  '-'  rpi_pxe  RPD_LITE   RPI_SN0   bootcode,cmdline,config,ssh,root,fstab,wpa,history,apt;
