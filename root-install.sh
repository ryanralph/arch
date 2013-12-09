#!/bin/bash -e

function create_nonroot_user() {
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

function do_sshd() {
	cp sshd_config /etc/ssh/sshd_config
#	systemctl start sshd.service
}

function do_powersaving() {
	yaourt -S pm-utils
      cp pm-powersave.service /etc/systemd/system/

      systemctl enable pm-powersave.service
      systemctl start pm-powersave.service
}

function replace_root_pw() {
	echo "Changing root password..."
	passwd root
}

function update_mirrorlist() {
	curl "https://www.archlinux.org/mirrorlist/?country=AU" | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist
}

function laptop_install() {
	yaourt -S wpa_supplicant
	desktop_install
	do_powersaving
}

function desktop_install() {
	replace_root_pw
	create_nonroot_user
	visudo
	do_locale
	update_mirrorlist
	do_ntp
	do_iptables
	do_services
}
