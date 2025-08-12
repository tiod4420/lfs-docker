#!/usr/bin/env bash
set -e

LFS=/mnt/lfs
LOOP_DEV=loop0

# Root
mkdir -p $LFS
mount /dev/${LOOP_DEV}p4 $LFS

# Boot
mkdir -p $LFS/boot
mount /dev/${LOOP_DEV}p2 $LFS/boot

# EFI
mkdir -p $LFS/efi
mount /dev/${LOOP_DEV}p1 $LFS/efi

# Swap
swapon /dev/${LOOP_DEV}p3

# Virtual file systems
mkdir -p $LFS/{dev,proc,sys,run}
mount --bind /dev $LFS/dev
mount -t devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -t proc proc $LFS/proc
mount -t sysfs sysfs $LFS/sys
mount -t tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
	install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
	mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
