#!/bin/bash

echo '[INFO MESSAGE]Installing dmenu'
pacman -Sy dmenu

echo '[INFO MESSAGE]Installing st'
wget https://aur.archlinux.org/cgit/aur.git/snapshot/st.tar.gz
tar -x -f st.tar.gz
cp config/st/config.h st
cd st
makepkg --skipchecksums
sudo pacman -U *.pkg.tar.zst

cd ..

echo '[INFO MESSAGE]Installing dwm'
wget https://aur.archlinux.org/cgit/aur.git/snapshot/dwm.tar.gz
tar -x -f dwm.tar.gz
cp config/dwm/config.h dwm
cd dwm 
makepkg --skipchecksums
sudo pacman -U *.pkg.tar.zst

cd ..

echo '[INFO MESSAGE]Create bash profile'
cat > .bash_profile << EOF
[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ ! \$DISPLAY && \$XDG_VTNR -eq 1 ]]; then
  exec startx
fi
EOF
mv .bash_profile ~/

echo '[INFO MESSAGE]Create .xinitrc'
cat > .xinitrc << EOF
#!/bin/sh

#Set keyboard layout
setxkbmap "pl,ua,no" "grp:alt_shift_toggle"
setxkbmap -option "grp:alt_shift_toggle" 

#Load .Xresources file
xrdb -merge /etc/X11/xinit/.Xresources

#Read .xsessionrc (?)
sh ~/.xsessionrc &

#Status update
while true;
	do
	xsetroot -name "\$(acpi) \$(date +"|%H:%M|%d/%m/%Y|")"
	sleep 1
	done&

#Start some nice programs
feh --bg-scale "\$HOME/.config/w.jpg" &
exec dwm
EOF

mv .xinitrc ~/

echo '[INFO MESSAGE]Clean up'
rm -r st
rm -r dwm
rm st.tar.gz
rm dwm.tar.gz

echo '[INFO MESSAGE]Finish'
