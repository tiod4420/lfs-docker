#!/usr/bin/env bash
set -e

SRC_DIR=$(dirname ${BASH_SOURCE[0]})

DOCKER_CONTAINER=lfs-container
DOCKER_IMG=lfs-image

DISK_IMG=${1:-lfs.img}
EFI_SIZE=200
BOOT_SIZE=200
SWAP_SIZE=4096
ROOT_SIZE=${2:-20480}

SHARED_DIR=$SRC_DIR/shared

# Create LFS disk image
if ! [ -f "$DISK_IMG" ]; then
	echo "$DISK_IMG: creating disk image..."
	TOTAL_SIZE=$((${EFI_SIZE} + ${BOOT_SIZE} + ${SWAP_SIZE} + ${ROOT_SIZE}))
	dd if=/dev/zero of=$DISK_IMG bs=1M count=$TOTAL_SIZE

	# Create partitions
	echo "$DISK_IMG: creating partitions..."
	echo "label: gpt" | sfdisk $DISK_IMG
	echo "size=${EFI_SIZE}M, type=uefi" | sfdisk --append $DISK_IMG
	echo "size=${BOOT_SIZE}M, type=linux" | sfdisk --append $DISK_IMG
	echo "size=${SWAP_SIZE}M, type=swap" | sfdisk --append $DISK_IMG
	echo "type=linux" | sfdisk --append $DISK_IMG

	# Format file systems
	echo "$DISK_IMG: attaching to loop device..."
	LOOP_DEV=$(sudo losetup --find --partscan --show $DISK_IMG)
	echo "$DISK_IMG: attached to $LOOP_DEV"

	echo "$DISK_IMG: creating file systems..."
	sudo mkfs.fat -F32 ${LOOP_DEV}p1
	sudo mkswap ${LOOP_DEV}p2
	sudo mkfs.ext4 ${LOOP_DEV}p3
	sudo mkfs.ext4 ${LOOP_DEV}p4

	echo "$LOOP_DEV: detaching loop device"
	sudo losetup -d $LOOP_DEV
else
	echo "$DISK_IMG: already created"
fi

# Build image if not existing
if ! docker image inspect $DOCKER_IMG > /dev/null 2>&1; then
	echo "$DOCKER_IMG: building Docker image..."
	docker build -t $DOCKER_IMG $SRC_DIR
else
	echo "$DOCKER_IMG: already built"
fi

# Mount the LFS disk as a loop device
if ! losetup -j $DISK_IMG | grep -q .; then
	echo "$DISK_IMG: attaching to loop device..."
	LOOP_DEV=$(sudo losetup --find --partscan --show $DISK_IMG)
	echo "$DISK_IMG: attached to $LOOP_DEV"

	# Trap to unmount disk image
	trap "echo '$LOOP_DEV: detaching loop device...' && sudo losetup -d $LOOP_DEV" EXIT
else
	echo "$DISK_IMG: already attached"
fi

# Create or start existing container
if ! [ "$(docker ps -a -q -f name=^/${DOCKER_CONTAINER}$)" ]; then
	echo "$DOCKER_CONTAINER: creating Docker container..."
	docker create -it --privileged --name $DOCKER_CONTAINER -v $SHARED_DIR:/home/lfs/shared $DOCKER_IMG
else
	echo "$DOCKER_CONTAINER: already created"
fi

echo "$DOCKER_CONTAINER: starting container..."
docker start -ai $DOCKER_CONTAINER
