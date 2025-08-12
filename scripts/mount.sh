#!/usr/bin/env bash
set -e

LFS=/mnt/lfs
DEV=loop0

# Root
mkdir -p $LFS
mount /dev/${DEV}p4 $LFS

# Boot
mkdir -p $LFS/boot
mount /dev/${DEV}p2 $LFS/boot

# EFI
mkdir -p $LFS/efi
mount /dev/${DEV}p1 $LFS/efi

# Swap
swapon /dev/${DEV}p3
