#!/usr/bin/env bash
set -e
SRC_DIR=$(dirname ${BASH_SOURCE[0]})

DOCKER_CONTAINER=lfs-container
DOCKER_IMG=lfs-image

DISK_IMG=lfs.img
DISK_IMG_SIZE=10240

VOLUME_MNT=$SRC_DIR/lfs-mnt
VOLUME_SHARED=$SRC_DIR/lfs-shared

# Trap function to unmount loop device
trap_unmount()
{
	echo "Unmounting disk image $1..."
	sudo umount $1
	sudo losetup -d $2
}

# Build image if not existing
if ! docker image inspect $DOCKER_IMG > /dev/null 2>&1; then
	echo "Building Docker image $DOCKER_IMG..."
	docker build -t $DOCKER_IMG $SRC_DIR
else
	echo "$DOCKER_IMG already built."
fi

# Create disk image if needed
if ! [ -f "$DISK_IMG" ]; then
	echo "Creating disk image $DISK_IMG..."
	dd if=/dev/zero of=$DISK_IMG bs=1M count=$DISK_IMG_SIZE
	mkfs.ext4 $DISK_IMG
else
	echo "$DISK_IMG already created."
fi

# Mount image if needed
if ! mountpoint -q "$VOLUME_MNT"; then
	echo "Mounting disk image $DISK_IMG..."

	# Setup the first loop device available
	LOOP_DEV=$(sudo losetup --find --partscan --show $DISK_IMG)
	echo "Loop device: $LOOP_DEV"

	# Mount root partition
	mkdir -p $VOLUME_MNT
	sudo mount $LOOP_DEV $VOLUME_MNT
	sudo chown $USER:$USER $VOLUME_MNT
	echo "$LOOP_DEV mounted to $VOLUME_MNT"

	# Trap to unmount disk image
	trap "trap_unmount $VOLUME_MNT $LOOP_DEV" EXIT
else
	echo "$VOLUME_MNT already mounted."
fi

# Create or start existing container
if [ "$(docker ps -a -q -f name=^/${DOCKER_CONTAINER}$)" ]; then
	echo "Starting existing Docker container $DOCKER_CONTAINER..."
	docker start -ai $DOCKER_CONTAINER
else
	echo "Create and run Docker container $DOCKER_CONTAINER..."
	docker run -it --name $DOCKER_CONTAINER \
		-v $VOLUME_MNT:/mnt/lfs \
		-v $VOLUME_SHARED:/home/lfs/shared \
		$DOCKER_IMG
fi
