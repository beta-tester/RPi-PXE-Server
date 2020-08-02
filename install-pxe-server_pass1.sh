#!/bin/bash

######################################################################
BACKUP_FILE=backup.tar.xz
BACKUP_TRANSFORM=s/^/$(date +%Y-%m-%dT%H_%M_%S)-pxe-server\\//

do_backup() {
    tar -ravf "$BACKUP_FILE" --transform="$BACKUP_TRANSFORM" -C / "$1" &>/dev/null
}


do_backup boot/cmdline.txt

######################################################################
grep -q max_loop /boot/cmdline.txt &>/dev/null || {
    echo -e "\e[32msetup cmdline.txt for more loop devices\e[0m";
    sudo sed -i '1 s/$/ max_loop=64/' /boot/cmdline.txt;
}

######################################################################
grep -q net.ifnames /boot/cmdline.txt &>/dev/null || {
    echo -e "\e[32msetup cmdline.txt for old style network interface names\e[0m";
    sudo sed -i '1 s/$/ net.ifnames=0/' /boot/cmdline.txt;
}


######################################################################
echo -e "\e[32msync...\e[0m" && sudo sync \
&& echo -e "\e[32mupdate...\e[0m" && sudo apt update \
&& echo -e "\e[32mupgrade...\e[0m" && sudo apt full-upgrade -y \
&& echo -e "\e[32mautoremove...\e[0m" && sudo apt autoremove -y --purge \
&& echo -e "\e[32mautoclean...\e[0m" && sudo apt autoclean \
&& echo -e "\e[32msync...\e[0m" && sudo sync \
&& echo -e "\e[32mDone.\e[0m" \
&& sync \
;


######################################################################
echo -e "\e[32minstall uuid\e[0m";
sudo apt install -y --no-install-recommends uuid;


######################################################################
echo -e "\e[32minstall nfs-kernel-server for pxe\e[0m";
sudo apt install -y --no-install-recommends nfs-kernel-server;
sudo systemctl enable nfs-kernel-server.service;
sudo systemctl restart nfs-kernel-server.service;


######################################################################
echo -e "\e[32menable port mapping\e[0m";
sudo systemctl enable rpcbind.service;
sudo systemctl restart rpcbind.service;


######################################################################
echo -e "\e[32minstall dnsmasq for pxe\e[0m";
sudo apt install -y --no-install-recommends dnsmasq
sudo systemctl enable dnsmasq.service;
sudo systemctl restart dnsmasq.service;


######################################################################
echo -e "\e[32minstall samba\e[0m";
sudo apt install -y --no-install-recommends samba;


######################################################################
echo -e "\e[32minstall rsync\e[0m";
sudo apt install -y --no-install-recommends rsync;


######################################################################
echo -e "\e[32minstall syslinux-common for pxe\e[0m";
sudo apt install -y --no-install-recommends pxelinux syslinux-common syslinux-efi;


######################################################################
echo -e "\e[32minstall lighttpd\e[0m";
sudo apt install -y --no-install-recommends lighttpd;
grep -q mod_install_server /etc/lighttpd/lighttpd.conf &>/dev/null || {
    do_backup etc/lighttpd/lighttpd.conf
    cat << EOF | sudo tee -a /etc/lighttpd/lighttpd.conf &>/dev/null
########################################
## mod_install_server
dir-listing.activate = "enable"
dir-listing.external-css = ""
dir-listing.external-js = ""
dir-listing.set-footer = "&nbsp;<br />"
dir-listing.exclude = ( "[.]*\.url" )
EOF
}
do_backup var/www/html/index.lighttpd.html
sudo rm /var/www/html/index.lighttpd.html


######################################################################
echo -e "\e[32minstall vblade\e[0m";
sudo apt install -y --no-install-recommends vblade vblade-persist;


######################################################################
$(dpkg --get-selections | grep -q -E "^(ntp|ntpd)[[:blank:]]*install$") || {
    echo -e "\e[32minstall chrony as ntp client and ntp server\e[0m";
    sudo apt install -y --no-install-recommends chrony;
    sudo systemctl enable chronyd.service;
    sudo systemctl restart chronyd.service;
}

######################################################################
## optional
echo -e "\e[32minstall tools to create initrd images\e[0m";
sudo apt install -y --no-install-recommends squashfs-tools initramfs-tools xz-utils;

######################################################################
sync
echo -e "\e[32mDone.\e[0m";
echo -e "\e[1;31mPlease reboot\e[0m";
