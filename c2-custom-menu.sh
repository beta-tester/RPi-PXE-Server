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
# Add your custom entries to this file.
#
# Ensure your $CUSTOM_ENTRY name is unique
# and the same name as in handle_custom and url_custom

#========== BEGIN Example ==========
# if [[ -f "$FILE_MENU" ]] \                            # This line is needed on ALL entries
# && [[ -f "$DST_ISO/$CUSTOM_ENTRY.iso" ]]; then        # This file may be the iso itself, or any file in the iso. It just verifies the file exists
#    echo  -e "\e[36m    add $CUSTOM_ENTRY\e[0m";       # Use your $custom_entry name
#    cat << EOF | sudo tee -a $FILE_MENU &>/dev/null    # This line is needed on ALL entries
#    ########################################
#    LABEL $CUSTOM_ENTRY                                                 # This is best to use your $CUSTOM_ENTRY name, but can be any unique name with no whitespace
#        MENU LABEL My Customized Linux x64                              # This can be anything. This is what will be displayed on the Menu
#        KERNEL $FILE_BASE$NFS_ETH0/$CUSTOM_ENTRY/live/vmlinuz-5.7.7     # This entry and <unknown> entries below are what loads the OS. You'll have to determine these yourself
#        INITRD $FILE_BASE$NFS_ETH0/$CUSTOM_ENTRY/live/initrd-5.7.7.lz   # Look at other entries in the main p2-include-menu.sh for a similar distro and try those/similar settings
#        APPEND nfsroot=$IP_ETH0:$DST_NFS_ETH0/$CUSTOM_ENTRY ro netboot=nfs ip=dhcp boot=live union=overlay livecd-installer console=tty splash --
#        TEXT HELP
#            Boot into My Custom Linux version x64      # This can be anything. This is what will be displayed when the menu entry is selected
#        ENDTEXT
# EOF
# fi
#=========== END Example===========
