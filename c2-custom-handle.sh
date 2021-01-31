#!/bin/bash

########################################################################
if [[ -z "$script_dir" ]]
then
  echo 'do not run this script directly !'
  echo 'this script is part of p2-update.sh'
  exit -1
fi
########################################################################


########################################################################
# Add your custom entries to this file.
#
# Example:
#   handle_item  '+'  iso   CUSTOM_ENTRY1;
#   handle_item  '+'  iso   CUSTOM_ENTRY2;
#
# Ensure your CUSTOM_ENTRY name is unique
# and the same name as in c2-custom-url.sh and c2-custom-menu.sh


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
#
#
# Note:
#     Do not put the $ in fornt of the VARIABLE name !!!
#     the handle_item functions do need the NAME of the VARIABLE (without _URL)

########################################################################
##-----------+----+-----+------------------------+----------------------
##exec       |act.|type |VAR. name of item       |optional options
#handle_item  '+'  iso   CUSTOM_ENTRY1            timestamping  ,custom_fstab_options;
#handle_item  '+'  iso   CUSTOM_ENTRY2            ,custom_fstab_options  vbladed 1 1;
