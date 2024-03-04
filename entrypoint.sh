#!/usr/bin/env bash

set -ex

echo "Welcome to my Proton Mail Bridge docker container !"

# Check if the gpg key exist, if not created it. Should be run only on first launch.
if [ ! -d "/root/.password-store/" ]; then
  gpg --generate-key --batch /protonmailbridge/GPGparams.txt
  gpg --list-keys
  pass init ProtonMailBridge
fi

# Start Proton Bridge on a fake tty
rm -f faketty
mkfifo faketty
cat faketty | /protonmailbridge/bridge --cli "$@"

echo "Done."