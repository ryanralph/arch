#!/bin/bash -e

device="sda"
bootsize="100M"

bootfs="ext2"
rootfs="ext4"

packages=$(cat core.txt)

function do_install() {
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

	mkfs -t "$bootfs" /dev/"$device"1
	mkfs -t "$rootfs" /dev/"$device"2
	mount /dev/"$device"2 /mnt

	mkdir /mnt/boot
	mount /dev/"$device"1 /mnt/boot

	pacstrap /mnt $packages
	genfstab -p /mnt >> /mnt/etc/fstab

	syslinux-install_update -c /mnt -i -a -m
	sed -i "s/sda3/"$device"2/g" /mnt/boot/syslinux/syslinux.cfg

	umount -R /mnt
}
