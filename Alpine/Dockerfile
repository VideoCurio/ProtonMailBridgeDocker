FROM golang:1.22-alpine AS build
LABEL authors="David BASTIEN"

# Install dependencies
RUN apk update
RUN apk upgrade
RUN apk add bash
RUN apk add make gcc g++ libc-dev musl musl-dev sed grep
RUN apk add git libsecret libsecret-dev pass

# RUN rc-update add dbus
# RUN touch /run/openrc/softlevel
# RUN rc-service dbus start

# Build stage
WORKDIR /build/
RUN git clone https://github.com/ProtonMail/proton-bridge.git
WORKDIR /build/proton-bridge/
RUN make build-nogui

# Solve bug https://github.com/mattn/go-sqlite3/pull/1177
COPY fix_1177.sh.sh /build/
RUN chmod u+x /build/fix_117.sh
# go.mod => github.com/mattn/go-sqlite3 => github.com/leso-kn/go-sqlite3 v0.0.0-20230710125852-03158dc838ed
# go mod tidy
# RUN make build-nogui
# /build/proton-bridge/bridge --cli

# Working stage image
FROM golang:1.22-alpine
LABEL authors="David BASTIEN"

# Install dependencies
RUN apk update
RUN apk upgrade
RUN apk add bash libsecret pass ca-certificates

# Copy executables made during previous stage
WORKDIR /protonmailbridge/
COPY --from=build /build/proton-bridge/bridge /protonmailbridge/
COPY --from=build /build/proton-bridge/proton-bridge /protonmailbridge/

# Install needed scripts and files
COPY entrypoint.sh /protonmailbridge/
RUN chmod u+x /protonmailbridge/entrypoint.sh
COPY GPGparams.txt /protonmailbridge/

ENTRYPOINT ["/protonmailbridge/entrypoint.sh"]
CMD ["help"]