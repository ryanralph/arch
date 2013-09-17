#!/bin/bash -e

device="sda"
bootsize="100M"

bootfs="ext2"
rootfs="ext4"

packages=$(cat core.txt)

function do_formatting() {
	mkfs -t "$bootfs" /dev/"$device"1
	mkfs -t "$rootfs" /dev/"$device"2
}

function do_fstab() {
	genfstab -p /mnt >> /mnt/etc/fstab
}

function do_mount() {
	mount /dev/"$device"2 /mnt
	mkdir /mnt/boot
	mount /dev/"$device"1 /mnt/boot
}

function do_pacstrap() {
	pacstrap /mnt $packages
}

function do_partition() {
	fdisk /dev/$device << EOF
d
1
d
2
d
n
p
1

+$bootsize
a
1
n
p
2


p
w
EOF
}

function do_syslinux() {
	syslinux-install_update -c /mnt -i -a -m
	sed -i "s/sda3/"$device"2/g" /mnt/boot/syslinux/syslinux.cfg
}

function unmount() {
	umount /mnt/boot
	umount /mnt
}

unmount
do_partition
do_formatting
do_mount
do_pacstrap
do_fstab
do_syslinux
unmount
