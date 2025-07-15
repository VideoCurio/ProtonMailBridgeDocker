#!/usr/bin/env bash

PROTONMAIL_BRIDGE_VERSION=$(cat VERSION)

echo "Building Proton Mail Bridge docker images ${PROTONMAIL_BRIDGE_VERSION} !"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Debian AMD64 image..."
docker pull --platform linux/amd64 golang:bookworm
docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --build-arg TARGET_PLATFORM="linux/amd64" --platform linux/amd64 --tag=ghcr.io/videocurio/proton-mail-bridge .
docker image tag ghcr.io/videocurio/proton-mail-bridge:latest ghcr.io/videocurio/proton-mail-bridge:"$PROTONMAIL_BRIDGE_VERSION"

# printf "\e[32m================================\e[0m \n"
# printf "\e[32m================================\e[0m \n"
# echo "Building Debian ARM64 image..."
# docker pull --platform linux/arm64 golang:bookworm
# docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --build-arg TARGET_PLATFORM="linux/arm64" --platform linux/arm64 --tag=ghcr.io/videocurio/proton-mail-bridge-arm64 .
# docker image tag ghcr.io/videocurio/proton-mail-bridge-arm64:latest ghcr.io/videocurio/proton-mail-bridge-arm64:"$PROTONMAIL_BRIDGE_VERSION"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Alpine AMD64 image..."
cd Alpine/ || exit
cp ../VERSION VERSION

docker pull --platform linux/amd64 golang:alpine
docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --build-arg TARGET_PLATFORM="linux/amd64" --platform linux/amd64 --tag=ghcr.io/videocurio/proton-mail-bridge-alpine .
docker image tag ghcr.io/videocurio/proton-mail-bridge-alpine:latest ghcr.io/videocurio/proton-mail-bridge-alpine:"$PROTONMAIL_BRIDGE_VERSION"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Alpine ARM64 image..."
docker pull --platform linux/arm64 golang:alpine
docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --build-arg TARGET_PLATFORM="linux/arm64" --platform linux/arm64 --tag=ghcr.io/videocurio/proton-mail-bridge-alpine-arm64 .
docker image tag ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:latest ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:"$PROTONMAIL_BRIDGE_VERSION"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "See results:"
docker images | grep proton-mail

# Tests images
# docker stop protonmail_bridge && docker rm protonmail_bridge
# docker stop protonmail_bridge_alpine && docker rm protonmail_bridge_alpine
# Docker manifest
# docker manifest create ghcr.io/videocurio/proton-mail-bridge-alpine:latest --amend ghcr.io/videocurio/proton-mail-bridge-alpine-amd64:latest --amend ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:latest
# docker manifest inspect --verbose ghcr.io/videocurio/proton-mail-bridge:latest

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
while true; do

read -p "Push docker images to ghcr.io ? (y/n) " yn

case $yn in
  [yY] ) echo "Uploading docker images...";
    docker push ghcr.io/videocurio/proton-mail-bridge:"$PROTONMAIL_BRIDGE_VERSION";
    docker push ghcr.io/videocurio/proton-mail-bridge:latest;
    # docker push ghcr.io/videocurio/proton-mail-bridge-arm64:"$PROTONMAIL_BRIDGE_VERSION";
    # docker push ghcr.io/videocurio/proton-mail-bridge-arm64:latest;

    docker push ghcr.io/videocurio/proton-mail-bridge-alpine:"$PROTONMAIL_BRIDGE_VERSION";
    docker push ghcr.io/videocurio/proton-mail-bridge-alpine:latest;
    docker push ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:"$PROTONMAIL_BRIDGE_VERSION";
    docker push ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:latest;
    break;;
  [nN] ) echo "Exiting...";
    exit;;
  * ) echo "Invalid response";;
esac

done
