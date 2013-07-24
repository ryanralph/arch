packages="dmenu mesa xorg-server xorg-server-utils xorg-xinit"
extra=$(cat extra.txt)

function get_driver() {
	echo "Select [initial] graphics driver:"
	select yn in "Nvidia" "Ati" "Intel" "None"; do
	      case $yn in
			Nvidia ) gpudriver=xf86-video-nouveua; break;;
			Ati ) gpudriver=xf86-video-ati; break;;
			Intel ) gpudriver=xf86-video-intel; break;;
			None ) break;;
	      esac
	done
}

function do_yaourt() {
	echo "[archlinuxfr]" >> /etc/pacman.conf
	echo "SigLevel = Never" >> /etc/pacman.conf
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf


	yaourt -Sy $packages $extra $gpudriver
}

function do_pkgbuilds() {
	cd dwm
	makepkg -fi --skipinteg

	cd ../st
	makepkg -fi --skipinteg
}

do_pkgbuilds
get_driver
do_install
