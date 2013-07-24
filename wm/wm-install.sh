packages="dmenu mesa xorg-server xorg-server-utils xorg-xinit"
extra=$(cat extra.txt)

function do_drivers() {
	echo "Select [initial] graphics driver:"
	select yn in "Nvidia" "Ati" "Intel" "None"; do
	      case $yn in
			Nvidia ) pacman -Sy xf86-video-nouveua; break;;
			Ati ) pacman -Sy xf86-video-ati; break;;
			Intel ) pacman -Sy xf86-video-intel; break;;
			None ) break;;
	      esac
	done
}

function do_yaourt() {
	echo "[archlinuxfr]" >> /etc/pacman.conf
	echo "SigLevel = Never" >> /etc/pacman.conf
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

	pacman -Sy yaourt
	pacman -Sy $packages
	yaourt -Sy $extra
}


function do_pkgbuilds() {
	cd dwm
	makepkg -fi --skipinteg

	cd ../st
	makepkg -fi --skipinteg
}

do_drivers
do_pkgbuilds
do_yaourt
