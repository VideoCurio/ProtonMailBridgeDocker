# Just recipes
# variables
name := 'ProtonMailBridgeDocker'
owner := 'VideoCurio'

# Default option list available recipes.
default:
  @just --list

# Build a multi-arch docker image
build VERSION:
  @echo "Building Debian multi-platform image..."
  docker pull --platform linux/amd64 golang:trixie
  docker pull --platform linux/amd64 debian:trixie-slim
  docker buildx build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="{{VERSION}}" --pull --push --platform=linux/amd64,linux/arm64 --tag ghcr.io/videocurio/proton-mail-bridge:"{{VERSION}}" --tag ghcr.io/videocurio/proton-mail-bridge:latest .
  docker pull ghcr.io/videocurio/proton-mail-bridge:"{{VERSION}}"
  docker pull ghcr.io/videocurio/proton-mail-bridge:latest

# Build a local docker image(for developers) - pass a valid tag version from https://github.com/ProtonMail/proton-bridge
build-local VERSION:
  @echo "Building Debian Trixie-slim AMD64 image..."
  docker pull --platform linux/amd64 golang:trixie
  docker pull --platform linux/amd64 debian:trixie-slim
  docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="{{VERSION}}" --build-arg TARGET_PLATFORM="linux/amd64" --platform linux/amd64 --tag=ghcr.io/videocurio/dev-debian:"{{VERSION}}" .
  docker image tag ghcr.io/videocurio/dev-debian:"{{VERSION}}" ghcr.io/videocurio/dev-debian:latest

# Inspect docker image
inspect:
  docker manifest inspect --verbose ghcr.io/videocurio/proton-mail-bridge:latest

# Linting Bash scripts.
lint:
  @echo 'Linting Bash files...'
  shellcheck --color=always -f tty -x -P ./*.sh && echo 'Shellcheck: SUCCESS'

# login to ghcr.io for docker image push
login EMAIL:
  #!/usr/bin/env bash
  envFilePath="./.env"
  if [ ! -f "$envFilePath" ]; then
    echo "Local environment file .env not found! Please create one with GH_TOKEN="
    exit 1
  fi
  source "$envFilePath"
  if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN is not defined or empty in $envFilePath"
    exit 1
  fi
  echo "Log in ghcr.io..."
  echo "$GH_TOKEN" | docker login ghcr.io -u {{EMAIL}} --password-stdin

# Print logs for production
logs:
  docker compose -f compose.yaml logs -f

# Print logs for development
logs-dev:
  docker compose -f compose-dev.yaml logs -f

# Run the docker container of the multi-arch image
run:
  docker compose -f compose.yaml up -d

# Run the docker container of the developers image.
run-dev:
  docker compose -f compose-dev.yaml up -d

# Stop and remove production containers
stop:
  docker compose -f compose.yaml down

# Stop and remove development containers
stop-dev:
  docker compose -f compose-dev.yaml down

# Open a bash terminal inside the running production container
terminal:
  docker exec -it protonmail_bridge /bin/bash

# Open a bash terminal inside a running developer container.
terminal-dev:
  docker exec -it dev_debian /bin/bash

# Interactive setup (login) for production. Note: requires container restart after exit.
setup:
  docker exec -it protonmail_bridge pkill bridge || true
  docker exec -it protonmail_bridge /usr/bin/bridge --cli

# Interactive setup (login) for development. Note: requires container restart after exit.
setup-dev:
  docker exec -it dev_debian pkill bridge || true
  docker exec -it dev_debian /usr/bin/bridge --cli

# Docker remove all build cache
prune:
  docker builder prune -a

