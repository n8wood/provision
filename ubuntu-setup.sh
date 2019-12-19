#!/bin/bash
# sudo apt install git
# git clone http://github.com/n8wood/provision

sudo apt update
sudo apt upgrade -y

sudo apt install feh libtool libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev xutils-dev autoconf lxappearance compton scrot p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller ffmpeg libdvdread4 icedax libdvd-pkg easytag id3tool lame libxine2-ffmpeg libmad0 mpg321 libavcodec-extra gstreamer1.0-libav openjdk-8-jre openssh-client remmina screen terminator tcpdump transmission-gtk vlc gnome-tweak-tool vim arc-theme keepassxc libreoffice gimp pcmanfm i3lock dunst qt4-qtconfig libinput-tools powertop ethtool xdotool wmctrl hsetroot libconfuse-dev libasound2-dev libiw-dev asciidoc libpulse-dev libnl-genl-3-dev git cmake cmake-data libcairo2-dev libxcb-ewmh-dev libxcb-image0-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev libmpdclient-dev libcurl4-openssl-dev libxcb-composite0-dev libxcb-render0-dev libxcb-damage0-dev libxcb-sync-dev docker.io dnsmasq suckless-tools cmake-data python3-sphinx python-xcbgen libjsoncpp-dev gcalcli curl jq fonts-roboto libgl1-mesa-glx libxcb-xtest0 syncthing vim

mkdir ~/src ; cd ~/src/ ; git clone https://github.com/n8wood/dotfiles ; git clone https://github.com/n8wood/docker ; cd
rm -rf ~/.config/user-dirs.dirs ~/.bashrc ~/.gtkrc-2.0 Desktop Music Videos Templates Documents Downloads
mkdir ~/tmp
ln -s ~/sync/doc ~/doc
ln -s ~/sync/img ~/img
ln -s ~/sync/txt ~/txt
ln -s ~/src/dotfiles/scripts ~/scripts
ln -s ~/src/dotfiles/.bashrc ~/.bashrc
ln -s ~/src/dotfiles/.xinitrc ~/.xinitrc
ln -s ~/src/dotfiles/.vimrc ~/.vimrc
ln -s ~/src/dotfiles/.profile.i3 ~/.profile
ln -s ~/src/dotfiles/.fonts ~/.fonts
ln -s ~/src/dotfiles/.icons ~/.icons
ln -s ~/src/dotfiles/etc/dnsmasq.conf /etc/dnsmasq.conf
sudo adduser n input

syncthing

# ubuntu-drivers autoinstall

update-alternatives --set editor /usr/bin/vim.basic
visudo  #n       ALL=(ALL) NOPASSWD:ALL

sudo systemctl set-default multi-user.target
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved
sudo echo -e "search stronghold.brown.edu services.brown.edu\nnameserver 127.0.0.1" > /etc/resolv.conf
sudo vi /etc/NetworkManager/NetworkManager.conf #[main] dns=none
sudo apt autoremove

# i3-gaps
cd ~/src
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
autoreconf --force --install
mkdir build
cd build
../configure --prefix=/usr --sysconfdir=/etc
make
sudo make install
# polybar
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install
# libinput gestures
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
sudo make install
# docker
sudo adduser n docker
newgrp docker
sudo ~/src/docker/f5vpn/build-image.sh

# grub
sudo vi /etc/defaults/grub
GRUB_CMDLINE_LINUX_DEFAULT="text"
GRUB_TERMINAL=console

update-grub


## power dim. monitor udev events with: udevadm  --debug
vi /etc/udev/rules.d/99auto-backlight.rules
SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/home/n/scripts/backlight.sh true"
SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/home/n/scripts/backlight.sh false"

#xdg setup
for dd in /usr/share/applications ~/.local/share/applications; do
  for d in $(ls $dd 2>/dev/null | grep "\\.desktop$"); do
    for m in $(grep MimeType $dd/$d | cut -d= -f2 | tr ";" " "); do
      echo xdg-mime default $d $m;
    done;
  done;
done

? xdg-mime default pcmanfm.desktop inode/directory

# console boot
sudo dpkg-reconfigure console-setup







# rdata
//oscarcifs.ccv.brown.edu/data /mnt/rdata cifs credentials=/etc/cifspw,noauto 0 0

# arc darker colors
dark gray - #373D48
darker gray - #29303a
blue - #5294E2
#5c616c

removed: gtk-chtheme


wget https://github.com/acrisci/playerctl/releases/download/v0.6.0/playerctl-0.6.0_amd64.deb
sudo dpkg -i playerctl-0.6.0_amd64.deb 


# or...
https://www.ubuntuupdates.org/package/getdeb_apps/xenial/apps/getdeb/polybar

# dns suffix
vi /etc/dhcp3/dhclient.conf
prepend domain-search "stronghold.brown.edu", "services.brown.edu", "ccv.brown.edu";

# rc.local
sudo vi /etc/systemd/system/rc-local.service
```
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
```
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local.service
sudo systemctl status rc-local.service

# lid lock
vi /etc/systemd/system/lock.service
```
[Unit]
Description=i3lock on suspend
After=sleep.target

[Service]
User=n
Type=forking
Environment=DISPLAY=:0
ExecStart=/usr/bin/i3lock -i /home/n/img/lockscreen.png

[Install]
WantedBy=sleep.target
```
systemctl daemon-reload
systemctl enable lock
