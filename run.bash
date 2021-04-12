#!/bin/bash

if [ "$1" == "" ]; then
    echo "$0: Please provide a workspace directory"
    exit 1
elif [ ! -d "$1" ]; then
    echo "$0: $1 is not a directory"
    exit 1
fi

WORKSPACE="$1"

xhost +local:

MAP_UID=${UID:-`id -u`}
MAP_GID=${GID:-`id -g`}

docker run -it --rm \
    -v ~/.Garmin:/home/developer/.Garmin \
    -v $WORKSPACE:/home/developer/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY \
    --ipc host \
    -u $MAP_UID:$MAP_GID \
    --privileged \
    kopa/connectiq:latest /bin/bash
