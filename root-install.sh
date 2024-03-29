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
	ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime

	cat _etc/vconsole.conf > /etc/vconsole.conf

	echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	locale > /etc/locale.conf

	curl -s "https://www.archlinux.org/mirrorlist/?country=AU" | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist

	ntpd -qg
	hwclock -w
}

function do_services() {
	cp _etc/systemd/journald.conf /etc/systemd/
	cp _etc/systemd/logind.conf /etc/systemd/

	echo "deny bootp" >> /etc/dhcpcd.conf
	systemctl enable dhcpcd.service
	systemctl start dhcpcd.service

	cp -r _etc/iptables /etc
	systemctl enable iptables.service
	systemctl enable ip6tables.service
	systemctl start iptables.service
	systemctl start ip6tables.service

#	systemctl enable ntpd.service
#	systemctl start ntpd.service

#	cp _etc/ssh/* /etc/ssh
#	systemctl enable sshd.service
#	systemctl start sshd.service

	systemctl disable remote-fs.target

	chmod 600 /etc/iptables/
	chmod 600 /etc/systemd/
}

function do_powersaving() {
	pacman -Sy pm-utils
	cp _etc/systemd/system/pm-powersave.service /etc/systemd/system/

	systemctl enable pm-powersave.service
	systemctl start pm-powersave.service
}

function laptop_install() {
	pacman -Sy wpa_supplicant
	touch /etc/wpa_supplicant.conf
	chmod 600 /etc/wpa_supplicant.conf

	desktop_install
	do_powersaving
}

function desktop_install() {
	create_nonroot_user
	EDITOR=vim visudo
	do_locale
	do_services
}
