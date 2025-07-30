#!/usr/bin/env bash

set -ex

VERSION=$(cat VERSION)

echo "Welcome to my Proton Mail Bridge docker container ${VERSION} !"
echo "Copyright (C) 2025  David BASTIEN - See /app/LICENSE.txt "

# Check if the gpg key exist, if not created it. Should be run only on first launch.
if [ ! -d "/root/.password-store/" ]; then
  gpg --generate-key --batch /app/GPGparams.txt
  gpg --list-keys
  pass init ProtonMailBridge
  sleep 1
fi

# Check if some env variables exist.
if ! [[ -v PROTON_BRIDGE_SMTP_PORT ]]; then
  echo "WARNING! Environment variable PROTON_BRIDGE_SMTP_PORT is not defined!"
fi
if ! [[ -v PROTON_BRIDGE_IMAP_PORT ]]; then
  echo "WARNING! Environment variable PROTON_BRIDGE_IMAP_PORT is not defined!"
fi
if ! [[ -v PROTON_BRIDGE_HOST ]]; then
  echo "WARNING! Environment variable PROTON_BRIDGE_HOST is not defined!"
fi
if ! [[ -v CONTAINER_SMTP_PORT ]]; then
  echo "WARNING! Environment variable CONTAINER_SMTP_PORT is not defined!"
fi
if ! [[ -v CONTAINER_IMAP_PORT ]]; then
  echo "WARNING! Environment variable CONTAINER_IMAP_PORT is not defined!"
fi

echo "Build for ${ENV_TARGET_PLATFORM} platform."

# Proton mail bridge listen only on 127.0.0.1 interface, we need to forward TCP traffic on SMTP and IMAP ports:
socat TCP-LISTEN:"$CONTAINER_SMTP_PORT",fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_SMTP_PORT" &
socat TCP-LISTEN:"$CONTAINER_IMAP_PORT",fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_IMAP_PORT" &

# Alpine GPG / keyboxd bug
#if [ -f "/root/.gnupg/S.keyboxd" ]; then
echo "Killing previous gpg keyboxd programs..."
pkill keyboxd || true
pkill gpg || true
#rm /root/.gnupg/S.keyboxd
rm /root/.gnupg/S.* || true
rm /root/.gnupg/*/*.lock || true
sleep 1
gpg-agent --daemon --allow-preset-passphrase
#fi

# Start a default Proton Mail Bridge on a fake tty, so it won't stop because of EOF
rm -f faketty
mkfifo faketty
cat faketty | /usr/bin/bridge --cli

echo "Done."