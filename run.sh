#!/usr/bin/env bash
set -e

SRC_DIR=$(dirname ${BASH_SOURCE[0]})
SHARED_DIR=$SRC_DIR/shared

DOCKER_CONTAINER=lfs-container
DOCKER_IMG=lfs-image

DISK_IMG=$SHARED_DIR/lfs.img

# Build image if not existing
if ! docker image inspect $DOCKER_IMG > /dev/null 2>&1; then
	echo "$DOCKER_IMG: building Docker image..."
	docker build -t $DOCKER_IMG $SRC_DIR
else
	echo "$DOCKER_IMG: already built"
fi

# Mount the LFS disk as a loop device
if ! losetup -j $DISK_IMG | grep -q .; then
	LOOP_DEV=$(sudo losetup --find --partscan --show $DISK_IMG)
	echo "$DISK_IMG: attaching to $LOOP_DEV..."

	# Trap to unmount disk image
	trap "echo '$LOOP_DEV: detaching...' && sudo losetup -d $LOOP_DEV" EXIT
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
