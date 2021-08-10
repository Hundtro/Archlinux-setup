#!/bin/bash
#
# Set setup variables
#

 USER="username"
 HOSTNAME="userpc"
 LOCALE="en_GB.UTF-8"
 TIMEZONE="/usr/share/zoneinfo/Europe/Warsaw"
 KEYMAP="pl"
 
#
# Begin setup
#

echo "[MESSAGE]Syslinux setup"
syslinux-install_update -i -a -m

echo '[MESSAGE]Confugure syslinux'
vim /boot/syslinux/syslinux.cfg

echo "[MESSAGE]Generate locale"
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo LANG=$LOCALE > /etc/locale.conf
echo KEYMAP=$KEYMAP > /etc/vconsole.conf

echo "[MESSAGE]Set timezone"
ln -sf $TIMEZONE /etc/localtime
hwclock --systohc --utc

echo "[MESSAGE]Set hosts"
echo "127.0.0.1 localhost.localdomain localhost $HOSTNAME" > /etc/hosts
echo $HOSTNAME > /etc/hostname

echo "[MESSAGE]Create User"
useradd -m -G wheel -s /bin/bash $USER
echo "[MESSAGE]Enter password for $USER"
passwd $USER

echo "[MESSAGE]Enter password for root"
passwd

echo "[MESSAGE]Set up sudoers"
vim /etc/sudoers

echo "[MESSAGE]Done!"
#END
