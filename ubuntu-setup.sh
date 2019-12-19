#!/bin/bash
# 18.04

# run this first:
# mkdir ~/src; sudo apt install git; git clone http://github.com/n8wood/provision

sudo sh -c 'echo "n       ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/n'
sudo chmod 0440 /etc/sudoers.d/n

sudo apt update
sudo apt upgrade -y

sudo DEBIAN_FRONTEND=noninteractive apt install feh libtool libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev xutils-dev autoconf lxappearance compton scrot p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller ffmpeg libdvdread4 icedax libdvd-pkg easytag id3tool lame libxine2-ffmpeg libmad0 mpg321 libavcodec-extra gstreamer1.0-libav openjdk-8-jre openssh-client remmina screen terminator tcpdump transmission-gtk vlc gnome-tweak-tool vim arc-theme keepassxc libreoffice gimp pcmanfm i3lock dunst qt4-qtconfig libinput-tools powertop ethtool xdotool wmctrl hsetroot libconfuse-dev libasound2-dev libiw-dev asciidoc libpulse-dev libnl-genl-3-dev git cmake cmake-data libcairo2-dev libxcb-ewmh-dev libxcb-image0-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev libmpdclient-dev libcurl4-openssl-dev libxcb-composite0-dev libxcb-render0-dev libxcb-damage0-dev libxcb-sync-dev docker.io dnsmasq suckless-tools cmake-data python3-sphinx python-xcbgen libjsoncpp-dev gcalcli curl jq fonts-roboto libgl1-mesa-glx libxcb-xtest0 syncthing vim -y

cd ~/src/ 
read -s -p "enter github pw: " gitpw
git clone https://n8wood:${gitpw}@github.com/n8wood/dotfiles
git clone https://n8wood:${gitpw}@github.com/n8wood/docker 
cd
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
#ln -s ~/src/dotfiles/etc/dnsmasq.conf /etc/dnsmasq.conf
sudo ln -s ~/src/dotfiles/etc/dnsmasq.d/default /etc/dnsmasq.d/default
sudo update-alternatives --set editor /usr/bin/vim.basic
sudo systemctl set-default multi-user.target
sudo systemctl enable --now dnsmasq
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved
sudo sh -c 'echo "search stronghold.brown.edu services.brown.edu\nnameserver 127.0.0.1" > /etc/resolv.conf'
sudo vi /etc/NetworkManager/NetworkManager.conf #[main] dns=none
sudo sed -i 's/^\[main\]$/[main]\ndns=none/' /etc/NetworkManager/NetworkManager.conf
sudo apt autoremove

# add device w/ qr code
syncthing &

ubuntu-drivers autoinstall

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
sudo adduser n input
newgrp input
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
sudo make install

# docker
sudo adduser n docker
newgrp docker
~/src/docker/f5vpn/
sudo ~/src/docker/f5vpn/build-image.sh


# console boot 16x32 (hidpi)
sudo dpkg-reconfigure console-setup

# media keys
wget https://github.com/acrisci/playerctl/releases/download/v0.6.0/playerctl-0.6.0_amd64.deb
sudo dpkg -i playerctl-0.6.0_amd64.deb 

# dns suffix
sudo sh -c 'echo "supersede domain-name-server 127.0.0.1;\nprepend domain-search \"stronghold.brown.edu\", \"services.brown.edu\", \"dam.brown.edu\", \"ccv.brown.edu\";" >> /etc/dhcp/dhclient.conf'

# lid/sleep lock
sudo sh -c 'echo "[Unit]\nDescription=i3lock on suspend\nAfter=sleep.target\n\n[Service]\nUser=n\nType=forking\nEnvironment=DISPLAY=:0\nExecStart=/usr/bin/i3lock -i /home/n/img/lockscreen.png\n\n[Install]\nWantedBy=sleep.target\n" > /etc/systemd/system/lock.service'
sudo systemctl daemon-reload
sudo systemctl enable --now lock

# rc.local
sudo sh -c 'echo "[Unit]\nDescription=/etc/rc.local Compatibilit\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target\n" > /etc/systemd/system/rc-local.service'
sudo sh -c 'echo "#!/bin/bash\nexit 0" > /etc/rc.local'
sudo chmod +x /etc/rc.local
sudo systemctl daemon-reload
sudo systemctl enable --now rc-local

# grub
sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"$/GRUB_CMDLINE_LINUX_DEFAULT=\"text\"/" /etc/default/grub
sudo sed -i "s/^#GRUB_TERMINAL=console$/GRUB_TERMINAL=console/" /etc/default/grub
update-grub

## power dim. monitor udev events with: udevadm  --debug
sudo sh -c 'echo "SUBSYSTEM==\"power_supply\", ATTR{online}==\"0\", RUN+=\"/home/n/scripts/backlight.sh true\"\nSUBSYSTEM==\"power_supply\", ATTR{online}==\"1\", RUN+=\"/home/n/scripts/backlight.sh false\"\n" > /etc/udev/rules.d/99auto-backlight.rules'

#xdg setup
#for dd in /usr/share/applications ~/.local/share/applications; do
for dd in /usr/share/applications; do
  for d in $(ls $dd 2>/dev/null | grep "\\.desktop$"); do
    for m in $(grep MimeType $dd/$d | cut -d= -f2 | tr ";" " "); do
      echo xdg-mime default $d $m;
    done;
  done;
done

#xdg-mime default pcmanfm.desktop inode/directory
