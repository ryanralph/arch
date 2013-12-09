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

	echo "KEYMAP=us" > /etc/vconsole.conf
	echo "FONT=lat9w-16" >> /etc/vconsole.conf
	echo "FONT_MAP=8859-1_to_uni" >> /etc/vconsole.conf

	echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	locale > /etc/locale.conf

	curl -s "https://www.archlinux.org/mirrorlist/?country=AU" | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist

	ntpd -qg
	hwclock -w
}

function do_services() {
	systemctl enable dhcpcd.service
	systemctl enable iptables.service
	systemctl enable ip6tables.service

	cp iptables.rules /etc/iptables/iptables.rules
	cp ip6tables.rules /etc/iptables/ip6tables.rules
#	cp sshd_config /etc/ssh/sshd_config

	systemctl start iptables.service
	systemctl start ip6tables.service
#	systemctl start sshd.service

	chmod 700 /etc/iptables/
	chmod 700 /etc/systemd/
}

function do_powersaving() {
	pacman -Sy pm-utils
      cp pm-powersave.service /etc/systemd/system/

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
