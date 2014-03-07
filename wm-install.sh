#!/bin/bash -e

if [ -z $(grep "archlinuxfr" /etc/pacman.conf) ]; then
	echo "[archlinuxfr]" >> /etc/pacman.conf
	echo "SigLevel = Never" >> /etc/pacman.conf
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

	sudo pacman -Sy yaourt
fi

packages=`cat extra.txt`

echo "Select [initial] graphics driver:"
select yn in "Nvidia" "Ati" "Intel" "None"; do
	case $yn in
		Nvidia ) gpudriver=nvidia; break;;
		Ati ) gpudriver=xf86-video-ati; break;;
		Intel ) gpudriver=xf86-video-intel; break;;
		None ) break;;
	esac
done

yaourt -Sy $packages $gpudriver
