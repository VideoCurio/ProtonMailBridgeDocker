#!/usr/bin/env bash

set -e

VERSION=$(cat VERSION)

echo "Welcome to my Proton Mail Bridge docker container ${VERSION} !"
echo "Copyright (C) 2024  David BASTIEN - See /app/LICENSE.txt "

# Check if the gpg key exist, if not created it. Should be run only on first launch.
if [ ! -d "/root/.password-store/" ]; then
  gpg --generate-key --batch /app/GPGparams.txt
  gpg --list-keys
  pass init ProtonMailBridge
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

# Proton mail bridge listen only on 127.0.0.1 interface, we need to forward TCP traffic on SMTP and IMAP ports:
[[ $PROTON_BRIDGE_ENABLE_SMTP_FORWARD == 'yes' ]] && {
    echo "Start port forwarding from 25 to $PROTON_BRIDGE_HOST:$PROTON_BRIDGE_SMTP_PORT"
    socat TCP-LISTEN:25,fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_SMTP_PORT" &
}

[[ $PROTON_BRIDGE_ENABLE_IMAP_FORWARD == 'yes' ]] && {
    echo "Start port forwarding from 143 to $PROTON_BRIDGE_HOST:$PROTON_BRIDGE_IMAP_PORT"
    socat TCP-LISTEN:143,fork TCP:"$PROTON_BRIDGE_HOST":"$PROTON_BRIDGE_IMAP_PORT" &
}

# Start a default Proton Mail Bridge on a fake tty, so it won't stop because of EOF
rm -f faketty
mkfifo faketty
cat faketty | /app/bridge --cli

echo "Done."
