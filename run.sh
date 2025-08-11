#!/usr/bin/env bash
set -e

SRC_DIR=$(dirname ${BASH_SOURCE[0]})

DOCKER_CONTAINER=lfs-container
DOCKER_IMG=lfs-image

# Build image if not existing
if ! docker image inspect $DOCKER_IMG > /dev/null 2>&1; then
	echo "Building Docker image $DOCKER_IMG..."
	docker build -t $DOCKER_IMG $SRC_DIR
else
	echo "$DOCKER_IMG already built."
fi

# Create or start existing container
if [ "$(docker ps -a -q -f name=^/${DOCKER_CONTAINER}$)" ]; then
	echo "Starting existing Docker container $DOCKER_CONTAINER..."
	docker start -ai $DOCKER_CONTAINER
else
	echo "Create and run Docker container $DOCKER_CONTAINER..."
	docker run -it --privileged --name $DOCKER_CONTAINER \
		-v $SRC_DIR/lfs-shared:/home/lfs/shared \
		$DOCKER_IMG
fi
