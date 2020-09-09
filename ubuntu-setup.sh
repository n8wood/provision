#!/bin/bash
# 18.04

# run this first:
# mkdir ~/src; sudo apt install git; git clone http://github.com/n8wood/provision

echo "Set hostname and /etc/hosts before proceeding"\n

read -s -p "enter sudo pw: " sudopw &&

echo $sudopw | sudo -S sh -c 'echo "n       ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/n'
echo $sudopw | sudo -S chmod 0440 /etc/sudoers.d/n

echo $sudopw | sudo -S apt update
echo $sudopw | sudo -S apt upgrade -y

echo $sudopw | sudo -S DEBIAN_FRONTEND=noninteractive apt install feh libtool libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev xutils-dev autoconf lxappearance compton scrot p7zip-rar p7zip-full unace zip unzip sharutils uudeview mpack arj cabextract file-roller ffmpeg icedax libdvd-pkg lame libxine2-ffmpeg libmad0 mpg321 libavcodec-extra gstreamer1.0-libav openjdk-8-jre openssh-client remmina screen terminator tcpdump transmission-gtk vlc gnome-tweak-tool vim arc-theme keepassxc libreoffice gimp i3lock dunst libinput-tools powertop ethtool xdotool wmctrl hsetroot libconfuse-dev libasound2-dev libiw-dev asciidoc libpulse-dev libnl-genl-3-dev git cmake cmake-data libcairo2-dev libxcb-ewmh-dev libxcb-image0-dev pkg-config xcb-proto libxcb-xrm-dev libmpdclient-dev libcurl4-openssl-dev libxcb-composite0-dev libxcb-render0-dev libxcb-damage0-dev libxcb-sync-dev docker.io dnsmasq suckless-tools cmake-data python3-sphinx libjsoncpp-dev gcalcli curl jq libgl1-mesa-glx libxcb-xtest0 syncthing vim playerctl i3-wm net-tools cifs-utils openssh-server fonts-croscore i3-wm dunst python3-xcbgen -y

timedatectl set-local-rtc 1 --adjust-system-clock

cd ~/src/ 
read -s -p "enter github pw: " gitpw && 
git clone "https://n8wood:${gitpw}@github.com/n8wood/dotfiles"
git clone https://n8wood:${gitpw}@github.com/n8wood/docker 
cd
rm -rf ~/.config/user-dirs.dirs ~/.bashrc ~/.profile ~/.gtkrc-2.0 Desktop Music Videos Templates Documents Downloads Public Pictures examples.desktop
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
echo $sudopw | sudo -S update-alternatives --set editor /usr/bin/vim.basic
echo $sudopw | sudo -S systemctl set-default multi-user.target
echo $sudopw | sudo -S apt autoremove -y

ubuntu-drivers autoinstall

# i3-gaps
#cd ~/src
#git clone https://www.github.com/Airblader/i3 i3-gaps
#cd i3-gaps
#autoreconf --force --install
#mkdir build
#cd build
#../configure --prefix=/usr --sysconfdir=/etc
#make
#echo $sudopw | sudo -S make install

# polybar
cd ~/src
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
echo $sudopw | sudo -S make install

# docker
echo $sudopw | sudo -S adduser n docker
newgrp docker
#~/src/docker/f5vpn/
#cd ~/src/docker/f5vpn/
#echo $sudopw | sudo -S ./build-image.sh
cd

# console boot 16x32 (hidpi)
#echo $sudopw | sudo -S dpkg-reconfigure console-setup

# media keys - available in repos
#wget https://github.com/acrisci/playerctl/releases/download/v0.6.0/playerctl-0.6.0_amd64.deb
#echo $sudopw | sudo -S dpkg -i playerctl-0.6.0_amd64.deb 

# dns suffix
echo $sudopw | sudo -S sh -c 'echo -e "supersede domain-name-server 127.0.0.1;\nprepend domain-search \"stronghold.brown.edu\", \"services.brown.edu\", \"dam.brown.edu\", \"ccv.brown.edu\";" >> /etc/dhcp/dhclient.conf'

# lid/sleep lock
echo $sudopw | sudo -S sh -c 'echo -e "[Unit]\nDescription=i3lock on suspend\nAfter=sleep.target\n\n[Service]\nUser=n\nType=forking\nEnvironment=DISPLAY=:0\nExecStart=/usr/bin/i3lock -i /home/n/img/lockscreen.png\n\n[Install]\nWantedBy=sleep.target\n" > /etc/systemd/system/lock.service'
echo $sudopw | sudo -S systemctl daemon-reload
echo $sudopw | sudo -S systemctl enable lock

# rc.local
echo $sudopw | sudo -S sh -c 'echo -e "[Unit]\nDescription=/etc/rc.local Compatibilit\nConditionPathExists=/etc/rc.local\n\n[Service]\nType=forking\nExecStart=/etc/rc.local start\nTimeoutSec=0\nStandardOutput=tty\nRemainAfterExit=yes\nSysVStartPriority=99\n\n[Install]\nWantedBy=multi-user.target\n" > /etc/systemd/system/rc-local.service'
echo $sudopw | sudo -S sh -c 'echo "#!/bin/bash\nexit 0" > /etc/rc.local'
echo $sudopw | sudo -S chmod +x /etc/rc.local
echo $sudopw | sudo -S systemctl daemon-reload
echo $sudopw | sudo -S systemctl enable --now rc-local

# grub
echo $sudopw | sudo -S sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"$/GRUB_CMDLINE_LINUX_DEFAULT=\"text\"/" /etc/default/grub
echo $sudopw | sudo -S sed -i "s/^#GRUB_TERMINAL=console$/GRUB_TERMINAL=console/" /etc/default/grub
echo $sudopw | sudo -S update-grub

## power dim. monitor udev events with: udevadm  --debug
echo $sudopw | sudo -S sh -c 'echo "SUBSYSTEM==\"power_supply\", ATTR{online}==\"0\", RUN+=\"/home/n/scripts/backlight.sh true\"\nSUBSYSTEM==\"power_supply\", ATTR{online}==\"1\", RUN+=\"/home/n/scripts/backlight.sh false\"\n" > /etc/udev/rules.d/99auto-backlight.rules'

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

# link to git dotfiles
if [[ -d ~/src/dotfiles/.config.${HOSTNAME} ]]; then
  cd ~/.config
  for config in $(ls ~/src/dotfiles/.config.${HOSTNAME} 2>/dev/null); do
    if [[ -d $config ]]; then
      rm -rf $config
    fi
    ln -s -f ~/src/dotfiles/.config.${HOSTNAME}/$config
  done
fi
if [[ -d ~/src/dotfiles/.config.default ]]; then
  cd ~/.config
  for config in $(ls ~/src/dotfiles/.config.default 2>/dev/null); do
    if [[ ! -L ~/.config/$config ]]; then
      if [[ -d $config ]]; then
        rm -rf $config
      fi
      ln -s ~/src/dotfiles/.config.default/$config
    fi
  done
fi

# dnsmasq setup
echo $sudopw | sudo -S ln -s ~/src/dotfiles/etc/dnsmasq.d/default /etc/dnsmasq.d/default
echo $sudopw | sudo -S systemctl enable --now dnsmasq
echo $sudopw | sudo -S systemctl disable systemd-resolved.service
echo $sudopw | sudo -S systemctl stop systemd-resolved
echo $sudopw | sudo -S rm -f /etc/resolv.conf
echo $sudopw | sudo -S sh -c 'echo -e "search stronghold.brown.edu services.brown.edu\nnameserver 127.0.0.1" > /etc/resolv.conf'
echo $sudopw | sudo -S sed -i 's/^\[main\]$/[main]\ndns=none\nrc-manager=unmanaged/' /etc/NetworkManager/NetworkManager.conf

# libinput gestures
cd ~/src
echo $sudopw | sudo -S adduser n input
#newgrp input
git clone https://github.com/bulletmark/libinput-gestures.git
cd libinput-gestures
echo $sudopw | sudo -S make install
libinput-gestures-setup autostart
libinput-gestures-setup start

unset gitpw
unset sudopw

echo "firefox hidpi: about:config layout.css.devPixelsPerPx 1.6\n"
# add device w/ qr code
syncthing &

# sudo dpkg-reconfigure libdvd-pkg
