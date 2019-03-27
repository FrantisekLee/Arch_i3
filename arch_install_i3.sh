#!/usr/bin/env bash
#
# pos-arch.in: Pos Arch Install i3 and Apps
#
# Copyright (c) 2019 Frantisek Lee
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

shopt -s extglob

usage() {
  cat <<EOF

usage: ${0##*/} [flags] [options]

  Options:

    --mirror, -m                         Update mirror (Only for Slovakia)
    --sudouser, -su  <user> <password>   Create name to user with privilegies root/sudo
    --install, -i                        Install all packages
    --version, -v                        Show version
    --help, -h                           Show this is message

EOF
}


if [[ -z $1 || $1 = @(-h|--help) ]]; then
  usage
  exit $(( $# ? 0 : 1 ))
fi

version="${0##*/} version 1.0"
_site="https://gitlab.com/FrantisekLee"
repo="Arch_i3"
video="xf86-video-intel"
video_default="xf86-video-vesa"
treminal="rxvt-unicode"
# terminal="xterm"


set_configs(){

	systemctl enable lightdm
	sed -i 's/^#greeter-session.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
	sed -i '/^#greeter-hide-user=/s/#//' /etc/lightdm/lightdm.conf
#	wget "$_site/$repo/arch_desktop.jpg" -O /usr/share/pixmaps/arch_desktop.jpg 2>/dev/null
#	wget "$_site/$repo/10-evdev.conf" -O /etc/X11/xorg.conf.d/10-evdev.conf 2>/dev/null
	cp arch_desktop.jpg /usr/share/pixmaps/ 2>/dev/null
	cp 10-evdev.conf /etc/X11/xorg.conf.d/ 2>/dev/null
	echo -e "[greeter]\nbackground=/usr/share/pixmaps/arch_desktop.jpg" > /etc/lightdm/lightdm-gtk-greeter.conf
	cp i3wm_config /home/${muser}/.config/i3/config 2>/dev/null
}

set_mirror(){

    [[ ! "$(which wget)" ]] && echo "Need install wget." && exit 1
#	wget "$_site/dotfiles/mirror-sk" -O /etc/pacman.d/mirrorlist 2>/dev/null
	cp mirror-sk /etc/pacman.d/mirrorlist 2>/dev/null
}

set_sudouser(){

    [[ -z "$2" ]] && echo "Set name user." && exit 1
    muser=$(echo "$2" | tr -d ' _-' | tr 'A-Z' 'a-z')
    
    echo "Your user: $muser. Enter and repeat your password:"
	useradd -m -g users -G wheel,storage,power,video,network -s /bin/bash "$muser"    
	passwd "$muser"
	pacman -S sudo --noconfirm
	sed -i "s/^root ALL=(ALL) ALL$/root ALL=(ALL) ALL\n${muser} ALL=(ALL) ALL\n/" /etc/sudoers
#	wget "$_site/dotfiles/.Xresources" -O /home/${muser}/.Xresources 2>/dev/null
	git clone https://github.com/FrantisekLee/dotfiles.git
	cp dotfiles/.Xresources /home/${muser}/.Xresources 2>/dev/null
	echo "exec i3" > /home/${muser}/.xinitrc && echo "tput bold" >> /home/${muser}/.bashrc
	echo "xrdb .Xresources" >> /home/${muser}/.bashrc
	echo "Success: user create and included on group sudo"
    
}

set_install(){

    pacman -S vim xorg-server xf86-input-mouse xf86-input-keyboard ${video_default} xorg-xinit i3-wm i3status i3lock dmenu awesome-terminal-fonts terminus-font ttf-dejavu ${terminal} lightdm lightdm-gtk-greeter firefox firefox-i18n-en-us bash-completion --noconfirm
    set_configs
    
}



case "$1" in

    "--mirror"|"-m") set_mirror ;;
    "--sudouser"|"-su") set_sudouser "$@";;
    "--install"|"-i") set_install;;
    "--version"|"-v") echo $version ;;
    "--help"|"-h") usage ;;
    *) echo "Invalid option." && usage ;;

esac


# TODO check VGA card on system and install right package


exit 0
