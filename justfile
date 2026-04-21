# Just recipes
# variables
name := 'ProtonMailBridgeDocker'
owner := 'VideoCurio'

# Default option list available recipes.
default:
  @just --list

# Verify the required Go version from the source matches our pinned version.
check-go-version VERSION:
  #!/usr/bin/env bash
  echo "Verifying Go version requirement for Proton Bridge {{VERSION}}..."
  REQUIRED_GO=$(curl -sSLf "https://raw.githubusercontent.com/ProtonMail/proton-bridge/{{VERSION}}/go.mod" | grep "^go " | awk '{print $2}')
  if [ -z "$REQUIRED_GO" ]; then
    echo "ERROR: Could not find Go version in go.mod for {{VERSION}} (Is the tag valid?)"
    exit 1
  fi
  if [[ ! "$REQUIRED_GO" =~ ^1\.26 ]]; then
    echo "ERROR: Proton Bridge {{VERSION}} requires Go $REQUIRED_GO, but this Dockerfile is pinned to 1.26.x"
    exit 1
  fi
  echo "Go version $REQUIRED_GO is compatible."
  echo "{{VERSION}}" > VERSION

# Build a multi-arch docker image
build VERSION: (check-go-version VERSION)
  @echo "Checking for multi-arch builder..."
  docker buildx ls | grep -q multiarch-builder || docker buildx create --use --name multiarch-builder
  docker buildx use multiarch-builder
  @echo "Building Debian multi-platform image..."
  docker pull --platform linux/amd64 golang:1.26-trixie
  docker pull --platform linux/amd64 debian:trixie-slim
  docker buildx build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="{{VERSION}}" --pull --push --platform=linux/amd64,linux/arm64 --tag ghcr.io/videocurio/proton-mail-bridge:"{{VERSION}}" --tag ghcr.io/videocurio/proton-mail-bridge:latest .
  docker pull ghcr.io/videocurio/proton-mail-bridge:"{{VERSION}}"
  docker pull ghcr.io/videocurio/proton-mail-bridge:latest

# Build a local docker image(for developers) - pass a valid tag version from https://github.com/ProtonMail/proton-bridge
build-local VERSION: (check-go-version VERSION)
  @echo "Building Debian Trixie-slim AMD64 image..."
  docker pull --platform linux/amd64 golang:1.26-trixie
  docker pull --platform linux/amd64 debian:trixie-slim
  docker build --build-arg ENV_PROTONMAIL_BRIDGE_VERSION="{{VERSION}}" --build-arg TARGET_PLATFORM="linux/amd64" --platform linux/amd64 --tag=ghcr.io/videocurio/dev-debian:"{{VERSION}}" .
  docker image tag ghcr.io/videocurio/dev-debian:"{{VERSION}}" ghcr.io/videocurio/dev-debian:latest
  #docker push ghcr.io/videocurio/dev-debian:"{{VERSION}}"
  #docker push ghcr.io/videocurio/dev-debian:latest

# Inspect docker image
inspect:
  docker manifest inspect --verbose ghcr.io/videocurio/proton-mail-bridge:latest

# Linting Bash scripts.
lint:
  @echo 'Linting Bash files...'
  shellcheck --color=always -f tty -x -P ./*.sh && echo 'Shellcheck: SUCCESS'

# login to ghcr.io for docker image push
login-ghcr EMAIL:
  #!/usr/bin/env bash
  envFilePath="./.env"
  if [ ! -f "$envFilePath" ]; then
    echo "Local environment file .env not found! Please create one with GH_TOKEN="
    exit 1
  fi
  source "$envFilePath"

  if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN is not defined or empty"
    exit 1
  fi
  echo "Log in ghcr.io..."
  echo "$GH_TOKEN" | docker login ghcr.io -u {{EMAIL}} --password-stdin

# Check the health status of the production container
health:
  @docker inspect --format='{{ '{{' }}json .State.Health{{ '}}' }}' protonmail_bridge

# Check the health status of the development container
health-dev:
  @docker inspect --format='{{ '{{' }}json .State.Health{{ '}}' }}' dev_debian

# Print logs for production
logs:
  docker compose -f compose.yaml logs -f

# Print logs for development
logs-dev:
  docker compose -f compose-dev.yaml logs -f

# Restart the docker container
restart:
  docker compose -f compose.yaml restart

# Restart the docker container of the developers image
restart-dev:
  docker compose -f compose-dev.yaml restart

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

