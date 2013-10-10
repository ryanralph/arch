#!/bin/bash -e

packages="dmenu mesa xorg-server xorg-server-utils xorg-xinit"
extra=$(cat extra.txt)

function get_driver() {
	echo "Select [initial] graphics driver:"
	select yn in "Nvidia" "Ati" "Intel" "None"; do
	      case $yn in
			Nvidia ) gpudriver=xf86-video-nouveau; break;;
			Ati ) gpudriver=xf86-video-ati; break;;
			Intel ) gpudriver=xf86-video-intel; break;;
			None ) break;;
	      esac
	done
}

function do_install() {
	if [ -z $(grep "archlinuxfr" /etc/pacman.conf) ]; then
		echo "[archlinuxfr]" >> /etc/pacman.conf
		echo "SigLevel = Never" >> /etc/pacman.conf
		echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

		pacman -Sy yaourt
	fi

	yaourt -Sy $packages $extra $gpudriver
}

# TODO FIXME (shouldn't be run as root...)
#function do_pkgbuilds() {
#	cd dwm
#	makepkg -fi --skipinteg --noconfirm
#
#	cd ../st
#	makepkg -fi --skipinteg --noconfirm
#}

get_driver
do_install
