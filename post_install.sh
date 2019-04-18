#!/bin/bash
#
# Chroot to new system
# Set install variables
#

 USER="winter"
 HOSTNAME="CAMP"
 LOCALE="en_GB.UTF-8"
 TIMEZONE="/usr/share/zoneinfo/Europe/Warsaw"
 KEYMAP="pl"
 
#
# Begin install
#

echo "[MESSAGE]Generate locale..."
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo LANG=$LOCALE > /etc/locale.conf
echo KEYMAP=$KEYMAP > /etc/vconsole.conf

echo "[MESSAGE]Set timezone..."
ln -sf $TIMEZONE /etc/localtime
hwclock --systohc --utc

echo "[MESSAGE]Set hosts..."
echo "127.0.0.1 localhost.localdomain localhost $HOSTNAME" > /etc/hosts
echo $HOSTNAME > /etc/hostname

echo "[MESSAGE]Create User..."
useradd -m -G wheel -s /bin/bash $USER
passwd $USER

echo "[MESSAGE]Set up root password and sudoers..."
passwd
visudo /etc/sudoers

echo "[MESSAGE]Done!"

#
# AUR install
#  dwm
#  st
#
#END