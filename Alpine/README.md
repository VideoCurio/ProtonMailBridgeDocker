# Proton Mail Bridge docker - Alpine Linux version

A version based on [Alpine Linux](https://www.alpinelinux.org/). Same functionalities but in a lightweight image.

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

## License

Copyright (C) 2024  David BASTIEN

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
