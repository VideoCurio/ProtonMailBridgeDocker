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

# EXPOSE 1025/tcp
# EXPOSE 1143/tcp

RUN apt-get update && apt-get install -y bash socat pass ca-certificates libsecret-1-0
# Copy executables made during previous stage
WORKDIR /protonmailbridge/
COPY --from=build /build/proton-bridge/bridge /protonmailbridge/
COPY --from=build /build/proton-bridge/proton-bridge /protonmailbridge/

# Install needed scripts and files
COPY entrypoint.sh /protonmailbridge/
RUN chmod u+x /protonmailbridge/entrypoint.sh
COPY GPGparams.txt /protonmailbridge/

ENTRYPOINT ["/protonmailbridge/entrypoint.sh"]