#!/usr/bin/env bash
set -e

LFS=/mnt/lfs
NPROC=${1:-$(nproc)}

chroot "$LFS" /usr/bin/env -i \
	HOME=/root \
	TERM="$TERM" \
	PS1='(lfs chroot) \u:\w\$ ' \
	PATH=/usr/bin:/usr/sbin \
	MAKEFLAGS="-j${NPROC}" \
	TESTSUITEFLAGS="-j${NPROC}" \
	/bin/bash --login
