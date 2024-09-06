#!/usr/bin/env bash

VERSION=$(cat VERSION)

echo "Building Proton Mail Bridge docker images ${VERSION} !"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Updating sources images..."
docker pull golang:bookworm
docker pull golang:1.23-alpine

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Debian image..."
docker build --tag=ghcr.io/videocurio/proton-mail-bridge .
docker image tag ghcr.io/videocurio/proton-mail-bridge:latest ghcr.io/videocurio/proton-mail-bridge:"$VERSION"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "Building Alpine image..."
cd Alpine/ || exit
cp ../VERSION VERSION

docker build --tag=ghcr.io/videocurio/proton-mail-bridge-alpine .
docker image tag ghcr.io/videocurio/proton-mail-bridge-alpine:latest ghcr.io/videocurio/proton-mail-bridge-alpine:"$VERSION"

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
echo "See results:"
docker images | grep proton-mail

# Tests images
# docker stop protonmail_bridge && docker rm protonmail_bridge
# docker stop protonmail_bridge_alpine && docker rm protonmail_bridge_alpine

printf "\e[32m================================\e[0m \n"
printf "\e[32m================================\e[0m \n"
while true; do

read -p "Push docker images to ghcr.io ? (y/n) " yn

case $yn in
  [yY] ) echo "Uploading docker images...";
    docker push ghcr.io/videocurio/proton-mail-bridge:"$VERSION";
    docker push ghcr.io/videocurio/proton-mail-bridge:latest;
    docker push ghcr.io/videocurio/proton-mail-bridge-alpine:"$VERSION";
    docker push ghcr.io/videocurio/proton-mail-bridge-alpine:latest;
    break;;
  [nN] ) echo "Exiting...";
    exit;;
  * ) echo "Invalid response";;
esac

done
