# Proton Mail Bridge docker - Alpine Linux version

A lightweight version based on [Alpine Linux](https://www.alpinelinux.org/).

```bash
docker pull ghcr.io/videocurio/proton-mail-bridge-alpine:latest
```
```bash
docker run -d --name=protonmail_bridge_alpine -v /path/to/your/volume/storage-alpine:/root -p 127.0.0.1:14025:25/tcp -p 127.0.0.1:14143:143/tcp --network network20 --restart=unless-stopped ghcr.io/videocurio/proton-mail-bridge-alpine:latest
```

For install and setup, see [README](https://github.com/VideoCurio/ProtonMailBridgeDocker).

## Developers notes

Build docker image, see: [Docker documentation](https://docs.docker.com/language/python/containerize/)
```bash
# Local tests:
git clone https://github.com/VideoCurio/ProtonMailBridgeDocker.git
cd /path/to/ProtonMailBridgeDocker/Alpine/
docker build --tag=ghcr.io/videocurio/proton-mail-bridge-alpine .
docker images | grep videocurio

docker image tag ghcr.io/videocurio/proton-mail-bridge-alpine:latest ghcr.io/videocurio/proton-mail-bridge-alpine:3.9.1a
docker push ghcr.io/videocurio/proton-mail-bridge-alpine:3.9.1a
docker push ghcr.io/videocurio/proton-mail-bridge-alpine:latest

docker run -it --rm --entrypoint /bin/bash ghcr.io/videocurio/proton-mail-bridge-alpine:latest

mkdir /path/to/your/volume/storage-alpine
docker run -d --name=protonmail_bridge_alpine -v /path/to/your/volume/storage-alpine:/root -p 127.0.0.1:14025:25/tcp -p 127.0.0.1:14143:143/tcp --network network20 --restart=unless-stopped ghcr.io/videocurio/proton-mail-bridge-alpine:latest

docker container logs protonmail_bridge_alpine
```
