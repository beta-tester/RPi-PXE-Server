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
# Add your custom entry URLs to this file
#
# Example:
#	CUSTOM_ENTRY1=my-custom-linux-x64
#	CUSTOM_ENTRY1_URL=https://isos.my-live-os.org/my_customized_linux-super-cool.iso
#	CUSTOM_ENTRY1_SUM=https://isos.my-live-os.org/my_customized_linux-super-cool.sum
#	CUSTOM_ENTRY1_SUM_TYPE=sha256
#
# For local files, use the full path starting from the root directory - /
# Example:
#	CUSTOM_ENTRY2=my-custom-linux-x64
#	CUSTOM_ENTRY2_URL=/home/pi/Downloads/my_customized_linux-super-cool.iso
#	CUSTOM_ENTRY2_SUM=/home/pi/Downloads/my_customized_linux-super-cool.sum
#	CUSTOM_ENTRY2_SUM_TYPE=sha256
#
# Note:
#   ..._SUM=       Optional. Url to a file that contains somewhere the hash value of the image file
#   ..._SUM_TYPE=  Optional. Hash function used to calculate the hash value of the image file
#
# Ensure your CUSTOM_ENTRY name is unique
# and the same name as in c2-custom-handle.sh and c2-custom-menu.sh
