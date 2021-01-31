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
# You can override existing variables here: 
# Example:
#   CUSTOM_COUNTRY=DE
#   CUSTOM_KEYMAP=de-latin1-nodeadkeys
#   CUSTOM_KMAP=qwertz/de-latin1
#   CUSTOM_LANGUAGE=de
#   CUSTOM_LAYOUTCODE=de
#   CUSTOM_LOCALE=de_DE.UTF-8
#   CUSTOM_TIMEZONE=Europe/Berlin
#   CUSTOM_VARIANT=German
#
# Or add additional variables you want to use in your other custom files e.g.: c2-custom-menu.sh
# Example:
#   MY_CUSTOM_VARIABLE=my custom value
