# install-pxe-server
setup a Raspberry Pi as a PXE-Server.<br />
it is a private project i have made for myself.<br />
i did not keep an eye on network security.

**the script will override some existing configurations**<br />
(a backup of the changed configuration files will be stored to **backup.tar.xz**)

**USE IT AT YOUR OWN RISK.**

## what is it good for?
the scripts installs necessary packages to let your RPi act as a DHCP, TFTP, Samba, NFS, HTML, NTP, VBLADE, PXE server.
and it will download LiveDVD ISOs you can boot your PXE client (Desktop PC) to.

the script can easily be modified to add additional ISOs or update ISOs if updated ones are available.

it also is able to act as server for NETWORK BOOTING for a Raspberry Pi 3 (see **note4**)

**Please give me a '_Star_', if you find that project useful.**

### overview schematic:
```
      ╔══════════╗   ╔═══╗       ╔══════╗╔═════════╗
WAN───╢DSL router╟───╢ s ║       ║RPi-  ╠╣USB-stick║
      ╚══════════╝   ║ w ║       ║PXE-  ║╚═════════╝
                     ║ i ║       ║server║        ╔═══════════════════════╗
       ╔══════╗      ║ t ╟───eth0╢──┬───╟wlan0───╢ PC4 IP:192.168.251.100║
       ║ RPi3 ╟──────╢ c ║       ║  │NAT║       ╔╩══════════════════════╗╝
       ╚══════╝   ┌──╢ h ╟──┐    ║  └───╟eth1───╢ PC3 IP:192.168.250.100║
                  │  ╚═══╝  │    ╚══════╝       ╚═══════════════════════╝
               ╔══╧══╗   ╔══╧══╗
               ║ PC1 ║   ║ PC2 ║
               ╚═════╝   ╚═════╝
```

## requirements
### hardware:
- Raspberry Pi (with LAN)
- SD card (big enough to hold entire ISO images of desired Live DVDs), (e.g. 64GByte)
- USB memory stick (optional, to store preloaded iso images), (e.g. 64GByte)
- working network environment with a connection to internet
- optional: second Ethernet interface (via USB)
- optional: built-in WLAN interface (as that one of RPi3, or an external one via USB)

optional, if your SD card is too small or you don't want to have all the server content on the SD card, you can use the USB memory stick to hold all content. for that you have to do small tiny changes on the '**p2-include-var-sh**' script, by changing '**DST_ROOT=/srv**' to something else.

### software:
- **Raspberry Pi OS Buster** or **Raspberry Pi OS Buster Lite** (2020-02-13), https://www.raspberrypi.org/downloads/raspbian/)

## installation:
assuming,
- your Raspberry Pi is running Raspberry Pi OS Buster (or Lite) from 2020-02-13,
- and has a proper connection to the internet via LAN (eth0).
- and your SD card can hold all the iso images (16GB when you use unmodified script)

and optional:
- you have plugged an USB-memory-stick that is mounted at /media/server (SRC_MOUNT=/media/server)
- and the following folder structure on the USB memory stick:
```
<mount_point>
└── backup
    ├── img
    └── iso

mkdir -p <mount_point>/backup/img
mkdir -p <mount_point>/backup/iso
```

optional structure for win-pe pxe boot
```
<mount_point>
└── backup
    └── tftp
        ├── Boot
        └── EFI

mkdir -p <mount_point>/backup/tftp/Boot
mkdir -p <mount_point>/backup/tftp/EFI
```
replace **<mount_point>** with the path, where you mounted your USB stick.

1. run `bash install-pxe-server_pass1.sh` to install necessary packages<br />
(use **_bash_** and do not run it from **_sudo_**)
2. reboot your RPi with `sudo reboot`
3. run `bash install-pxe-server_pass2.sh` to copy/download iso images of LiveDVDs, mount and export them and setup PXE menu according installed images.<br />
(use **_bash_** and do not run it from **_sudo_**)
4. reboot your RPi with `sudo reboot`

done.

## update:
to update your images, update the url in the **p2-include-url.sh** file<br />
and re-run `bash install-pxe-server_pass2.sh`.
this will download all updated iso files.

## modifying the script:
### p2-include-var.sh
includes all important variables like source and destination directories, ip-addresses, and so on.
e.g.: by changing '**DST_ROOT=/srv**' you can tell the script to download and store all iso to an external storage, instead of storing to the internal SD card.

### p2-include-url.sh
includes all url and name of images
```
e.g.
DEBIAN_X64=debian-x64
DEBIAN_X64_URL=https://...
```

### p2-include-menu.sh
includes all pxe-menu entries and kernel parameters
in the script, for each image there is a pxe-menu entry enclosed by<br />
`#========== BEGIN ==========`<br />
and<br />
`#=========== END ===========`<br />
comments.

### p2-include-handle.sh
includes all handler to control what image to download and expose to the pxe-server
**if you don't want some iso images getting downloaded and mounted, you can comment out lines to do not handle the image.<br />
or rename handle to __unhandle to uninstall the previous downloaded image and undo all mounting stuff for that image to free disk space.<br />
e.g.:**
```
#handle_iso  $DEBIAN_X64  $DEBIAN_X64_URL;
_unhandle_iso  $DEBIAN_X86  $DEBIAN_X86_URL;
...
```
**same procedure, if you don't want some disk images getting downloaded and mounted, you can comment out those lines
e.g.:**
```
######################################################################
handle_zip_img  $RPD_LITE  $RPD_LITE_URL;
# handle_zip_img  $RPD_FULL  $RPD_FULL_URL;
```

## what else you should know, when you make modification to the script...
there are three important locations for the pxe boot and the pxe menu that must fit. otherwise the pxe menu and the following boot process can not find required files.
1. the ISO or NFS path relative to the pxe boot menu root path<br />
(on disk `/srv/tftp/menu-bios/iso`, `/srv/tftp/menu-bios/iso` as symbolic link).
2. the ISO or NFS path relative to the nfs root path<br />
(on disk `/srv/iso`, `/srv/nfs`).
3. the ISO, IMG or NFS path located at /var/www/html<br />
(on disk `/var/www/html/iso`, `/var/www/html/img`, `/var/www/html/nfs`).
```
/
├── srv
|   ├── img    (the real physical location of IMG files)
|   ├── iso    (the real physical location of ISO files)
|   ├── nfs    (the real physical location of NFS files or mountpoints)
|   |
|   └── tftp       (TFTP root)
|       |
|       └── menu-bios  (PXE boot menu root for BIOS)
|           ├── iso    (only a symbolic link to ISO files)
|           └── nfs    (only a symbolic link to NFS files)
|
└── var
    └── www
        └── html     (HTML root)
            ├── img  (only a symbolic link to IMG files)
            ├── iso  (only a symbolic link to ISO files)
            └── nfs  (only a symbolic link to NFS files)
```

if you make any changes to your script and/or file structure on disk, keep an eye to changes you made and adapt everything to match
pxe menu entries to file structure on disk.

what the root of TFTP and PXE boot menu are, is defined in the **_dnsmasq_** configuration file `/etc/dnsmasq.d/pxe-server`.<br />
the root for NFS is defined in `/etc/exports`.<br />
the root for HTML is defined in the **_lighttpd_** configuration file `/etc/lighttpd/lighttpd.conf`.
## mount scenarios for pxe boot:
### direct read-only mounting content of ISO:
e.g. ubuntu-lts-x64 iso image<br />
no problems. pxe boot job can access to required content.
```
╔═════════════╗
║iso-file     ║
║             ║
║ ┌───────────╨─┐
║ │mount loop   │
║ │             │
║ │             ├───┤nfs*
║ │             │
║ └───────────╥─┘
╚═════════════╝
```
### mounting content of disk image and make content read/writable by overlayfs:
e.g. rpi-raspbian-full<br />
this disk image contains two partitions. the first is the boot partition and the second is the root partition.
to make the images read/writable, there is an overlayfs putted on top.<br />
(lowerdir is the read-only source, upperdir is the writable difference, workdir is an temporarily workfolder for internal use. the mergeddir is the sum of lower + upper. write access happens only on the upperdir with white-out and write-on-modify capability)<br />
but unfortunately overlayfs can't get exported directly for nfs. so putting a bindfs on top of the overlayfs makes it possible to get exported for nfs.<br />
and another issue is, overlayfs can't handle **vfat** partitions as source (lowerdir). putting bindfs between makes overlayfs happy.<br />
**note: this overlayfs+bindfs construction does NOT work reliably - data loss!**
```
╔═════════════╗
║img-file     ║
║             ║
║ ┌───────────╨─┐ ┌─────────────┐ ┌─────────────────┐   ┌─────────────┐
║ │mount loop   │ │mount bindfs │ │mount overlayfs  │   │mount bindfs │
║ │  vfat       │ │  prepare to │ ├───────┐ ┌───────┴─┐ │  prepage to │
║ │  boot       ├─┼  overlayfs  ├─┼ lower │ │merged   ├─┼  export nfs ├───┤nfs*
║ │             │ └─────────────┘ ├───────┘ └───────┬─┘ └─────────────┘
║ │             │                 │         ┌───────┴─┐
║ │  vfat       │                 │         │upper    ├─┤diff*
║ │  can't be   │                 │can't be └───────┬─┘
║ │  handled    │                 │handled  ┌───────┴─┐
║ │  by         │                 │by       │work     ├─┤tmp*
║ │  overlayfs  │                 │exportfs └───────┬─┘
║ └───────────╥─┘                 └─────────────────┘
║ ┌───────────╨─┐                 ┌─────────────────┐   ┌─────────────┐
║ │mount loop   │                 │mount overlayfs  │   │mount bindfs │
║ │  ext4       │                 ├───────┐ ┌───────┴─┐ │  prepare to │
║ │  root       ├─────────────────┼ lower │ │merged   ├─┼  export nfs ├───┤nfs*
║ │             │                 ├───────┘ └───────┬─┘ └─────────────┘
║ │             │                 │         ┌───────┴─┐
║ │             │                 │         │upper    ├─┤diff*
║ │             │                 │can't be └───────┬─┘
║ │             │                 │handled  ┌───────┴─┐
║ │             │                 │by       │work     ├─┤tmp*
║ │             │                 │exportfs └───────┬─┘
║ └───────────╥─┘                 └─────────────────┘
╚═════════════╝
```

## note2:
some of the PXE-menu entries has additional parameters, that lets the Live systems boot with German language (keyboard layout).
if you don't like or want, remove those additional parameters just behind the ' --' in the menu entries

to easily change the language to your favorite ones, there are variables on the top part of the script.
```
CUSTOM_LANG=de
CUSTOM_LANG_LONG=de_DE
CUSTOM_LANG_UPPER=DE
CUSTOM_LANG_WRITTEN=German
CUSTOM_LANG_EXT=de-latin1-nodeadkeys
CUSTOM_TIMEZONE=Europe/Berlin
```

## note3:
it is prepared for BIOS, UEFI 32bit and UEFI 64bit boot, but UEFI is not tested yet by me, because of lack of hardware for UEFI boot.

## note4: NETWORK BOOTING for Raspberry Pi 3 client
the server is prepared for to boot a Raspberry Pi 3 client via network.
in the script ```install-pxe-server_pass2.sh```, there is a ```RPI_SN0=--------``` line, change the ```--------``` to the serial number of the RPi3-**client**, that will boot from network later on.<br />
skip the leading '00000000'. take only the last 8 digits!<br />
e.g.
```
pi@raspberry-$ cat /proc/cpuinfo | grep Serial
Serial          : 0000000087654321
```
then take ```RPI_SN0=87654321```.<br />
if you have more than one RPi3-client for network booting you have to add them by hand to the ```/srv/tftp``` folder on the PXE-server.

the script will download Raspberry Pi OS Buster Lite and prepare it for the RPi3-client with the given serial number.

by default, a RPi3-client is not enabled for network booting. you have to enable it once.

for more information,

see: [Network Booting](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net.md)<br/>
see: [Network Boot Your Raspberry Pi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net_tutorial.md)
