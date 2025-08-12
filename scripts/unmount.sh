#!/usr/bin/env bash
set -e

LFS=/mnt/lfs
LOOP_DEV=${1:-loop0}

# Unmount virtual file systems
mountpoint -q $LFS/dev/shm && umount -v $LFS/dev/shm

umount -v $LFS/dev/pts
umount -v $LFS/sys
umount -v $LFS/proc
umount -v $LFS/run
umount -v $LFS/dev

# Unmount loop device filesystems
swapoff -v /dev/${LOOP_DEV}p3
umount -v $LFS/efi
umount -v $LFS/boot
umount -v $LFS
