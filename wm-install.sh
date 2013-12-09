#!/bin/bash -e

if [ -z $(grep "archlinuxfr" /etc/pacman.conf) ]; then
	echo "[archlinuxfr]" >> /etc/pacman.conf
	echo "SigLevel = Never" >> /etc/pacman.conf
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

	pacman -Sy yaourt
fi

packages="dmenu mesa xorg-server xorg-server-utils xorg-xinit"
extra=$(cat extra.txt)

echo "Select [initial] graphics driver:"
select yn in "Nvidia" "Ati" "Intel" "None"; do
	case $yn in
		Nvidia ) gpudriver=xf86-video-nouveau; break;;
		Ati ) gpudriver=xf86-video-ati; break;;
		Intel ) gpudriver=xf86-video-intel; break;;
		None ) break;;
	esac
done

yaourt -Sy $packages $extra $gpudriver

#makepkg -fi --skipinteg --noconfirm
