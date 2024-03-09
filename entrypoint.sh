#!/usr/bin/env bash

set -ex

echo "Welcome to my Proton Mail Bridge docker container !"

# Check if the gpg key exist, if not created it. Should be run only on first launch.
if [ ! -d "/root/.password-store/" ]; then
  gpg --generate-key --batch /protonmailbridge/GPGparams.txt
  gpg --list-keys
  pass init ProtonMailBridge
fi

# Proton mail bridge listen only on 127.0.0.1 interface, we need to forward TCP traffic on SMTP and IMAP ports:
socat TCP-LISTEN:25,fork TCP:127.0.0.1:1025 &
socat TCP-LISTEN:143,fork TCP:127.0.0.1:1143 &

# Start a default Proton Mail Bridge on a fake tty, so it won't stop because of EOF
rm -f faketty
mkfifo faketty
cat faketty | /protonmailbridge/bridge --cli

echo "Done."