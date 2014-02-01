#!/bin/bash -e

function create_nonroot_user() {
	echo "Changing root password..."
	passwd root

	echo "Enter non-root username:"
	read username
	useradd -m -g users -s /bin/bash $username
	passwd $username
}

function do_locale() {
	echo "arch" > /etc/hostname
	ln -s /usr/share/zoneinfo/Australia/Melbourne /etc/localtime

	cat ./etc/vconsole.conf > /etc/vconsole.conf

	echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	locale > /etc/locale.conf

	curl -s "https://www.archlinux.org/mirrorlist/?country=AU" | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist

	ntpd -qg
	hwclock -w
}

function do_services() {
	cp ./etc/systemd/journald.conf /etc/systemd/

	systemctl enable dhcpcd.service
	systemctl enable iptables.service
	systemctl enable ip6tables.service
#	systemctl enable ntpd.service
#	systemctl enable sshd.service

	cp -r ./etc/iptables /etc/iptables
#	cp ./etc/ssh/* /etc/ssh/

	systemctl start dhcpcd.service
	systemctl start iptables.service
	systemctl start ip6tables.service
#	systemctl start ntpd.service
#	systemctl start sshd.service

	chmod 700 /etc/iptables/
	chmod 700 /etc/systemd/
}

function do_powersaving() {
	pacman -Sy pm-utils
      cp ./etc/systemd/pm-powersave.service /etc/systemd/system/

      systemctl enable pm-powersave.service
      systemctl start pm-powersave.service
}

function laptop_install() {
	pacman -Sy wpa_supplicant
	desktop_install
	do_powersaving
}

function desktop_install() {
	create_nonroot_user
	visudo
	do_locale
	do_services
}
