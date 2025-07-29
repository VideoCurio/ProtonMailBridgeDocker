#!/usr/bin/env bash

set -exuo pipefail

echo "Welcome to my Proton Mail Bridge docker container ${PROTONMAIL_BRIDGE_VERSION:-Unknown Version} !"
echo "Copyright (C) 2025  David BASTIEN - See /app/LICENSE.txt "

# Check if the gpg key exist, if not created it. Should be run only on first launch.
if [ ! -d "/root/.password-store/" ]; then
  gpg --generate-key --batch /app/GPGparams.txt
  gpg --list-keys
  pass init ProtonMailBridge
fi

# Check if some env variables exist.
PROTON_BRIDGE_SMTP_PORT=${PROTON_BRIDGE_SMTP_PORT:?"is unset or null"}
PROTON_BRIDGE_IMAP_PORT=${PROTON_BRIDGE_IMAP_PORT:?"is unset or null"}
PROTON_BRIDGE_HOST=${PROTON_BRIDGE_HOST:?"is unset or null"}
CONTAINER_SMTP_PORT=${CONTAINER_SMTP_PORT:?"is unset or null"}
CONTAINER_IMAP_PORT=${CONTAINER_IMAP_PORT:?"is unset or null"}

echo "Build for ${ENV_TARGET_PLATFORM} platform."

# Proton mail bridge listen only on 127.0.0.1 interface, we need to forward TCP traffic on SMTP and IMAP ports:
socat TCP-LISTEN:"$CONTAINER_SMTP_PORT",fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_SMTP_PORT" &
socat TCP-LISTEN:"$CONTAINER_IMAP_PORT",fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_IMAP_PORT" &

# Start a default Proton Mail Bridge on a fake tty, so it won't stop because of EOF
rm -f faketty
mkfifo faketty
cat faketty | /app/bridge --cli

echo "Done."