#!/bin/bash

here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
files="$here/files"
if [ -e /dev/nvme0n1 ]; then
  efi_drive="/dev/nvme0n1p1";
  system_drive="/dev/nvme0n1p2";
else
  efi_drive="/dev/sda1"
  system_drive="/dev/sda2"
fi

# update
pacman -Syu --noconfirm

# bootloader
bootctl install
cat > /boot/loader/loader.conf <<\EOL
default displayer
timeout 0
EOL
cat > /boot/loader/entries/displayer.conf <<EOL
title Displayer
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=$system_drive
EOL

# network
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager.service
systemctl enable NetworkManager-wait-online.service

# ssh
pacman -S --noconfirm openssh
systemctl enable sshd
if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
  echo "PermitRootLogin yes" >> "/etc/ssh/sshd_config"
fi
echo "root:displayer" | chpasswd
echo "displayer:displyer" | chpasswd

# keayboard layout
echo "KEYMAP=de" > /etc/vconsole.conf

# install gui
pacman -S --noconfirm openbox xorg-server xorg-xinit xf86-video-intel chromium
pacman -S --noconfirm ruby gtk3 base-devel gobject-introspection
pacman -S --noconfirm inotify-tools
# ruby gems in path
cat > /etc/profile.d/displayer.sh <<\EOL
#!/bin/sh
PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"
export PATH
EOL
chmod +x /etc/profile.d/displayer.sh
# add to path temporarily for rdoc not to fail on installation
PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"
su - displayer -c "gem install rdoc rake"
su - displayer -c "gem install gtk3 gio2"

# opt
mkdir -p /opt/displayer
cat "$files/opt/displayer/bootstrap" > /opt/displayer/bootstrap
cat "$files/opt/displayer/displayer-gui" > /opt/displayer/displayer-gui
cat "$files/opt/displayer/displayer-gui.glade" > /opt/displayer/displayer-gui.glade
cat "$files/opt/displayer/displayer-conf-watchdog" > /opt/displayer/displayer-conf-watchdog
touch /opt/displayer/display # deployed by displayer-conf-watchdog
chmod +x "/opt/displayer/"*
mkdir -p /opt/displayer/chrome-plugin
touch /opt/displayer/chrome-plugin/autologin.js # deployed by displayer-conf-watchdog
touch /opt/displayer/chrome-plugin/manifest.json # deployed by displayer-conf-watchdog
chmod -R 777 /opt/displayer

# create and configure displayer-user
useradd displayer
mkdir -p /home/displayer
cat "$files/home/displayer/bash_profile" > /home/displayer/.bash_profile
cat "$files/home/displayer/bashrc" > /home/displayer/.bashrc
cat "$files/home/displayer/xinitrc" > /home/displayer/.xinitrc
mkdir -p /home/displayer/.config/openbox
cat "$files/home/displayer/config/openbox/autostart" > /home/displayer/.config/openbox/autostart
cp /etc/xdg/openbox/rc.xml /home/displayer/.config/openbox/rc.xml
chown -R displayer:displayer /home/displayer

# /etc
mkdir -p /etc/displayer
if [ ! -f /etc/displayer/conf ]; then
  cat "$files/etc/displayer/conf" > /etc/displayer/conf
fi
chmod -R 777 /etc/displayer
cat "$files/etc/systemd/system/displayer-conf-watchdog.service" > /etc/systemd/system/displayer-conf-watchdog.service
systemctl enable displayer-conf-watchdog.service

# autologin displayer
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat "$files/etc/systemd/system/getty@tty1.service.d/override.conf" > /etc/systemd/system/getty@tty1.service.d/override.conf

# splashscreen
pacman -S --noconfirm --needed base-devel
pacman -S --noconfirm git
git clone https://aur.archlinux.org/plymouth.git /home/displayer/plymouth
chown -R displayer:displayer /home/displayer/plymouth
echo "displayer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/displayer
su - displayer -c "cd /home/displayer/plymouth; makepkg -si --noconfirm"
rm /etc/sudoers.d/displayer
cat > /etc/mkinitcpio.conf <<\EOL
MODULES=(i915)
BINARIES=()
FILES=()
HOOKS=(base udev plymouth autodetect modconf block filesystems keyboard fsck)
EOL
cat > /boot/loader/entries/displayer.conf <<\EOL
title Displayer
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/nvme0n1p2 quiet splash
EOL
cat > /etc/plymouth/plymouthd.conf <<\EOL
[Daemon]
Theme=spinner
# show splashscreen even on quickly booting systems
ShowDelay=0
# give the splashscreen enough time to initialize
DeviceTimeout=30
EOL
mkinitcpio -p linux

# install openvpn
pacman -S --noconfirm openvpn
# put openvpn-config under /etc/openvpn/client!
systemctl enable openvpn-client@client
echo "paste client cert: /etc/openvpn/client/client.conf"

# push version
