#!/bin/bash
# 
# Prepare partitions
# Connect to Internet
# Set install variables
#

 PT_ROOT='/dev/sda1'
 PT_SWAP='/dev/sda2'
 MAKE_SWAP=0
 
 PACS+=' sudo'                  #Sudo and visudo
 PACS+=' mesa xf86-video-intel' #Intel video drivers
 PACS+=' iw'                    #Basic wireless tool
 PACS+=' wpa_supplicant'        #For WPA/WPA2 networks
 PACS+=' dialog'                #For connect via wifi-menu
 PACS+=' intel-ucode'           #Intel microcode
 PACS+=' syslinux'              #Bootloader
 PACS+=' acpi'                  #Console power manager
 PACS+=' alsa-utils'            #For alsamixer
 PACS+=' xorg'                  #Basic X environment
 PACS+=' xorg-xinit'            #For xinit profile
 PACS+=' elinks'                #Console web browser
 PACS+=' ranger'                #Console file manager
 PACS+=' mupdf'                 #Console pdf viewer
 PACS+=' feh'                   #Console image viewer, set root wallpaper
 PACS+=' vim'                   #Console text editor
 PACS+=' p7zip'                 #Console archive manager for zip/rar
 PACS+=' moc'                   #Console music player (mocp)
 PACS+=' wget'                  #Console downloader
 PACS+=' git'                   #Git version control
#PACS+=' dmenu'                 #For dmw install
#PACS+=' xfce4'                 #Light desktop environment
#PACS+=' xfce4-goodies'         #Additional tools for xfce4
 PACS+=' qtcreator'             #IDE For C/C++ and Qt
 PACS+=' qutebrowser'           #Qt web browser
 PACS+=' xpdf'                  #Qt pdf viewer
 PACS+=' vlc'                   #Good media/video player
 PACS+=' gst-libav'             #Qutebrowser html5 plugins
 PACS+=' gst-plugins-base'      #Qutebrowser html5 plugins
 PACS+=' gst-plugins-good'      #Qutebrowser html5 plugins
 PACS+=' gst-plugins-bad'       #Qutebrowser html5 plugins
 PACS+=' gst-plugins-ugly'      #Qutebrowser html5 plugins
 PACS+=' wvdial'                #For 3G modem connection
 PACS+=' usb_modeswitch'        #For modem mode-change to 3G
 PACS+=' libreoffice-still'     #MS Office alternative
 PACS+=' gvfs'                  #Usb automount for desktops
#PACS+=' virtualbox'            #Environment for virtual OS
 PACS+=' ntfs-3g'               #For NTFS
 PACS+=' unrar'                 #For rar archives
 PACS+=' bc'                    #Console calculator
 PACS+=' exfat-utils'           #For exFAT
 
#
# Begin install
# 

echo '[MESSAGE]Check Internet connection.'
ping -q -c3 8.8.8.8

if [ $? -ne 0 ]; then
    echo '[MESSAGE]No Internet connection! Exit.'
	exit 1
else
    echo '[MESSAGE]Internet connection OK!'
fi

echo '[MESSAGE]Prepare partitions.'
mkfs.ext4 $PT_ROOT
mount $PT_ROOT /mnt

if [ $MAKE_SWAP -eq 1 ]; then
    mkswap $PT_SWAP
	swapon $PT_SWAP
fi

echo '[MESSAGE]Install Base packages.'
pacstrap /mnt base base-devel $PACS

if [ $? -ne 0 ]; then
    echo '[MESSAGE]Install Error! Exit.'
	exit 2
fi

echo '[MESSAGE]Generate fstab.'
genfstab -U -p /mnt >> /mnt/etc/fstab


echo '[MESSAGE]Configure bootloader in new system.'
echo '[MESSAGE]Chroot to new system.. Type the following:'
echo '[MESSAGE] syslinux-install_update -i -a -m'
echo '[MESSAGE] vim /boot/syslinux/syslinux.cfg'
echo '[MESSAGE] exit'
arch-chroot /mnt

echo '[MESSAGE]Done!'
#END
