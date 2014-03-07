#!/bin/bash -e

device="sda"
bootsize="100M"
bootfs="ext2"
rootfs="ext4"

packages=`cat core.txt`

echo "Remove all partitions on $device..."
fdisk /dev/$device
fdisk /dev/$device << EOF
n
p
1

+$bootsize
a
n
p
2


p
w
EOF

mkfs -t "$bootfs" /dev/"$device"1
mkfs -t "$rootfs" /dev/"$device"2
mount /dev/"$device"2 /foo

mkdir /foo/boot
mount /dev/"$device"1 /foo/boot

pacstrap /foo $packages
genfstab -p /foo >> /foo/etc/fstab

syslinux-install_update -c /foo -i -a -m
sed -i "s/sda3/"$device"2/g" /foo/boot/syslinux/syslinux.cfg

umount -R /foo
