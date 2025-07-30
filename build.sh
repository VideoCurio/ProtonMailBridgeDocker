#!/usr/bin/env bash

set -e

PROTONMAIL_BRIDGE_VERSION=$(cat VERSION)

#export GH_TOKEN=XXXXXXXXX
#echo $GH_TOKEN | docker login ghcr.io -u dxxxx@xxxxxxx.com --password-stdin

echo "Building Proton Mail Bridge docker images ${PROTONMAIL_BRIDGE_VERSION} !"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Debian multi-platform image..."
# QEMU and binfmt required
# Multi-platform images MUST be pushed to a container registry (like github), cannot be stored locally.
docker buildx build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --pull --push --platform=linux/amd64,linux/arm64 -t ghcr.io/videocurio/dev-debian:"$PROTONMAIL_BRIDGE_VERSION" .
#docker pull ghcr.io/videocurio/dev-debian:"$PROTONMAIL_BRIDGE_VERSION"

# Build a local image
#printf "\e[32m================================\e[0m \n"
#printf "\e[32m================================\e[0m \n"
#echo "Building Debian AMD64 image..."
#docker pull --platform linux/amd64 golang:bookworm
#docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --build-arg TARGET_PLATFORM="linux/amd64" --platform linux/amd64 --tag=ghcr.io/videocurio/proton-mail-bridge .
#docker image tag ghcr.io/videocurio/proton-mail-bridge:latest ghcr.io/videocurio/proton-mail-bridge:"$PROTONMAIL_BRIDGE_VERSION"

cd Alpine/ || exit
cp ../VERSION VERSION
printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Alpine multi-platform image..."
docker buildx build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="$PROTONMAIL_BRIDGE_VERSION" --pull --push --platform=linux/amd64,linux/arm64 -t ghcr.io/videocurio/dev-alpine:"$PROTONMAIL_BRIDGE_VERSION" .

# Tests images
# docker stop protonmail_bridge && docker rm protonmail_bridge
# docker stop protonmail_bridge_alpine && docker rm protonmail_bridge_alpine
# Docker manifest
# docker manifest create ghcr.io/videocurio/proton-mail-bridge-alpine:latest --amend ghcr.io/videocurio/proton-mail-bridge-alpine-amd64:latest --amend ghcr.io/videocurio/proton-mail-bridge-alpine-arm64:latest
# docker manifest inspect --verbose ghcr.io/videocurio/proton-mail-bridge:latest
