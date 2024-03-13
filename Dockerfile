FROM golang:bookworm AS build
LABEL authors="David BASTIEN"

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential libsecret-1-dev

# Build stage
WORKDIR /build/
RUN git clone https://github.com/ProtonMail/proton-bridge.git
WORKDIR /build/proton-bridge/
RUN make build-nogui

# Working stage image
FROM golang:bookworm
LABEL authors="David BASTIEN"
LABEL org.opencontainers.image.source="https://github.com/VideoCurio/ProtonMailBridgeDocker"

# Define arguments and env variables
# Indicate (NOT define) the ports/network interface really used by Proton bridge mail.
# It should be 1025/tcp and 1143/tcp but on some k3s instances it could be 1026 and 1144 (why ?)
# Launch `netstat -ltnp` on a running container to be sure.
ARG ENV_BRIDGE_SMTP_PORT=1025
ARG ENV_BRIDGE_IMAP_PORT=1143
ARG ENV_BRIDGE_HOST=127.0.0.1
ENV PROTON_BRIDGE_SMTP_PORT=$ENV_BRIDGE_SMTP_PORT
ENV PROTON_BRIDGE_IMAP_PORT=$ENV_BRIDGE_IMAP_PORT
ENV PROTON_BRIDGE_HOST=$ENV_BRIDGE_HOST

# Install dependencies
RUN apt-get update && apt-get install -y bash socat net-tools pass ca-certificates libsecret-1-0
# Copy executables made during previous stage
WORKDIR /app/
COPY --from=build /build/proton-bridge/bridge /app/
COPY --from=build /build/proton-bridge/proton-bridge /app/

# Install needed scripts and files
COPY entrypoint.sh /app/
RUN chmod u+x /app/entrypoint.sh
COPY GPGparams.txt /app/

# Expose SMTP and IMAP ports
# The entrypoint script will forward this ports to the ports really used by Proton mail bridge.
EXPOSE 25/tcp
EXPOSE 143/tcp

# Volume to save pass and bridge configurations/data
VOLUME /root

ENTRYPOINT ["/app/entrypoint.sh"]