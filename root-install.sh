#!/bin/bash -e

hostname="arch"

kbl="us"
locale="en_AU.UTF-8 UTF-8"
timezone="/usr/share/zoneinfo/Australia/Melbourne"

function create_nonroot_user() {
	echo "Enter non-root username:"
	read username
	useradd -m -g users -s /bin/bash $username
	passwd $username
}

function do_locale() {
	echo "$hostname" > /etc/hostname
	ln -s $timezone /etc/localtime

	echo "KEYMAP=$kbl" > /etc/vconsole.conf
	echo "FONT=lat9w-16" >> /etc/vconsole.conf
	echo "FONT_MAP=8859-1_to_uni" >> /etc/vconsole.conf

	echo $locale > /etc/locale.gen
	locale-gen
	locale > /etc/locale.conf
}

function do_iptables() {
	cp iptables.rules /etc/iptables/iptables.rules
	cp ip6tables.rules /etc/iptables/ip6tables.rules

	chmod 700 /etc/iptables/
}

function do_ntp() {
	ntpd -qg
	hwclock -w
}

function do_services() {
	systemctl enable dhcpcd.service
	systemctl enable iptables.service
	systemctl enable ip6tables.service

	systemctl start iptables.service
	systemctl start ip6tables.service

	chmod 700 /etc/systemd/
}

function replace_root_pw() {
	echo "Changing root password..."
	passwd root
}

function update_mirrorlist() {
	curl "https://www.archlinux.org/mirrorlist/?country=AU" | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist
}

do_locale
update_mirrorlist
do_ntp
do_iptables
do_services
create_nonroot_user
replace_root_pw
visudo
