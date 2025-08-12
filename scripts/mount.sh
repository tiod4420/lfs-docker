#!/usr/bin/env bash
set -e

LFS=/mnt/lfs
LOOP_DEV=${1:-loop0}

# Mount loop device filesystems
mkdir -pv $LFS
mount -v -t ext4 /dev/${LOOP_DEV}p4 $LFS
mkdir -pv $LFS/boot
mount -v -t ext4 /dev/${LOOP_DEV}p2 $LFS/boot
mkdir -pv $LFS/efi
mount -v -t vfat /dev/${LOOP_DEV}p1 $LFS/efi
swapon -v /dev/${LOOP_DEV}p3

# Mount virtual file systems
mkdir -pv $LFS/{dev,proc,sys,run}
mount -v --bind /dev $LFS/dev
mount -v -t devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -v -t proc proc $LFS/proc
mount -v -t sysfs sysfs $LFS/sys
mount -v -t tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
	install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
	mount -v -t tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
