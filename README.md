# Proton Mail Bridge docker

A docker version of the [Proton mail Bridge](https://proton.me/mail/bridge) command
line interface. It creates a local SMTP server, so other docker containers can send
emails via your Proton email account.

__!WARNING!__ As of the time of this writing, you need a paid plan (Mail Plus,
Proton Unlimited or Proton for Business) to be able to log in. It won't work for
free account.

![Logo Proton Mail Bridge docker](https://raw.githubusercontent.com/VideoCurio/ProtonMailBridgeDocker/master/logo.png "Merci à Korben pour le logo!")
_(Merci [Korben](https://korben.info/) pour le logo)_

## Install

Download the latest docker image from:

```bash
docker pull ghcr.io/videocurio/proton-mail-bridge:latest
```

__(Optional)__ It is recommended to set up a custom docker network for all of your
containers to use, for DNS / network-alias resolution:

```bash
sudo docker network create --subnet 172.20.0.0/16 network20
```

Launch it with the following command to expose TCP ports 12025 for SMTP and 12143
for IMAP on your local network interface.
___You MUST provide a path volume storage___ (`mkdir /path/to/your/volume/storage`).

```bash
docker run -d --name=protonmail_bridge -v /path/to/your/volume/storage:/root -p 127.0.0.1:12025:25/tcp -p 127.0.0.1:12143:143/tcp --network network20 --restart=unless-stopped ghcr.io/videocurio/proton-mail-bridge:latest
```

__OR__ (docker compose version):

```bash
wget https://raw.githubusercontent.com/VideoCurio/ProtonMailBridgeDocker/master/compose.yaml
docker compose up -d
```

__(Optional)__ Make sure the container is running:

```bash
docker ps
CONTAINER ID   IMAGE                                          COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
d9932fb7136b   ghcr.io/videocurio/proton-mail-bridge:latest   "/app/entrypoint.sh"     About a minute ago   Up About a minute   127.0.0.1:12025->25/tcp, 127.0.0.1:12143->143/tcp   protonmail_bridge
```

__(Optional)__ You can check the bridge command line output with, you should see
a bridge in ASCII art:

```bash
docker container logs protonmail_bridge
```

__OR__ (docker compose version):

```bash
docker compose logs
```

### Notes

The following error messages are expected in the container logs after the first
run or when launching the command `/usr/bin/bridge --cli`:

```bash
WARN[Apr 20 14:13:49.022] An issue occurred when reading the cache file  error="open /root/.cache/protonmail/bridge-v3/unleash_startup_cache/unleash_startup_flags.json: no such file or directory" pkg=unleash-startup
WARN[Apr 20 14:13:50.310] Failed to add test credentials to keychain    error="failed to open dbus connection: exec: \"dbus-launch\": executable file not found in $PATH" helper="*keychain.SecretServiceDBusHelper"
WARN[Apr 20 14:13:50.369] no vault key found, generating new            error="could not get keychain item: credentials not found in native keychain"
```

The docker container will use `gpg` and `pass` to store credentials not the
DBUS secret-service.

## Quick Management with Just

If you have [just](https://github.com/casey/just) installed, you can manage the
container with these simple commands:

* __Start:__ `just run`
* __Stop:__ `just stop`
* __Logs:__ `just logs`
* __Setup/Login:__ `just setup`
* __Terminal:__ `just terminal`

## Setup

Now, you need to login to your Proton account. Open a bash terminal on the current
running container:

```bash
docker exec -it protonmail_bridge /bin/bash
```

Once the interactive shell is open:

```bash
# First we need to kill the default bridge startup instance (only one instance of bridge can run at the same time)
root@8972584f86d4:/app# pkill bridge
# Login to your Proton account:
root@8972584f86d4:/app# /usr/bin/bridge --cli
....
      Welcome to Proton Mail Bridge interactive shell
....
>>> info
No active accounts. Please add account to continue.

# Type help for a list of all commands
>>> help
# Login to a Proton account (!MUST! be a paid plan to use this client), follow the instructions on screen
# Tip: Use Ctrl+Shift+V to paste on most Linux terminal
>>> login
Username: test_account@proton.me
Password:
Authenticating ...
Two factor code: 123456
Account test_account was added successfully.
>>> A sync has begun for test_account.
Sync (test_account): 1.0% (Elapsed: 0.5s, ETA: 46.0s)
...
Sync (test_account): 99.9% (Elapsed: 50.4s, ETA: 0.4s)
A sync has finished for test_account.
>>>
# Success
```

__IF__ you are using multiple domain names or email addresses, you __SHOULD__ switch
to split address mode (it will set credentials for each address in the account).

It will sync the account again, time to grab a coffee.

```bash
>>> change mode 0
Are you sure you want to change the mode for account test_account to split? yes/no: yes
Address mode for account test_account changed to split
>>> A sync has begun for test_account.
Sync (test_account): 1.0% (Elapsed: 0.3s, ETA: 32.6s)
...
Sync (test_account): 99.9% (Elapsed: 50.4s, ETA: 0.4s)
A sync has finished for test_account.
>>>
```

Use the following information to connect via an SMTP client. The port numbers for
the SMTP/IMAP connections are 12025 and 12143 (see command `docker ps`),
__NOT__ the one provided by the `info`command.

You ___MUST copy the username AND password___ from the info command (the password
is random and different from your Proton account):

```bash
>>> info
Configuration for test_account@proton.me
IMAP Settings
Address:   127.0.0.1
IMAP port: 1143
Username:  test_account@proton.me
Password:  abcedfGHI12345
Security:  STARTTLS

SMTP Settings
Address:   127.0.0.1
SMTP port: 1025
Username:  test_account@proton.me
Password:  abcedfGHI12345
Security:  STARTTLS

Configuration for another_account@proton.me
....

# Exit
>>> exit
root@8972584f86d4:/app# exit
```

See a list of [all Proton bridge commands available here](https://proton.me/support/bridge-cli-guide)
or use the `help` command.

We have killed the default bridge instance by exiting it during the previous step,
so we __MUST__ restart the container:

```bash
docker container restart protonmail_bridge
```

__OR__ (docker compose version):

```bash
docker compose restart
```

__(Optional)__ You can check the bridge command line output with:

```bash
docker container logs protonmail_bridge
```

It should end with `A sync has finished for <name_of_your_account>`

## Notes

1. Your email client might complain about the self-signed certificate used by Proton
   mail bridge server.
2. If you want other docker containers to only be able to send emails, you should
   only expose SMTP port 25.

### TrueNAS Scale 24.10 or superior (TrueNAS apps as docker containers)

The docker image was tested on the latest stable version of [TrueNAS Scale](https://www.truenas.com/truenas-scale/)
24.10 (at the time of writing), follow the [installation custom app screen](https://www.truenas.com/docs/truenasapps/usingcustomapp/)
documentation. You should define a [Dataset](https://www.truenas.com/docs/scale/24.10/scaleuireference/datasets/)
to save your Proton mail data before installing the app.

The recommended parameters are:

1. __Image Configuration__ - Image repository: `ghcr.io/videocurio/proton-mail-bridge`
   / Image tag: `latest` / Pull policy: `Always pull...`
2. __Container Configuration__ - Entrypoint: `/app/entrypoint.sh` / Restart
   Policy: `Unless stopped`
3. __Network Configuration__ - Add > Container Port: `25` / Host Port: `12025`
   (Or any other non-used port) / Protocol: `TCP`
4. __Storage Configuration__ - Storage Add > Type: `Host path` / Mount Path: `/root`
   / Host path: `/mnt/path/to/your/protonmail-dataset`
5. __Resource Configuration__ - `Check` Enable resource limits, configure the
   limits to your liking.

## Changelog

* 2026/04/19:
  * Alpine image marked as DEPRECATED and replaced by a Debian slim image.
  * Updated to Proton Mail Bridge v3.24.1
* 2025/07/30: Added multi-platform docker buildx support.
* 2025/07/15: Added ARM64/v8 platform image for the Alpine version.
* 2025/07/12: updated to Proton Mail Bridge v3.21.2 (bug fix update)
* 2025/06/16: updated to Proton Mail Bridge v3.21.1
* 2025/06/10: updated to Proton Mail Bridge v3.21.0
* 2025/06/03: updated to Proton Mail Bridge v3.20.1
* 2025/05/27: updated to Proton Mail Bridge v3.20.0
* 2025/03/21: updated to Proton Mail Bridge v3.19.0
* 2025/02/28: updated to Proton Mail Bridge v3.18.0, added environment variables
  CONTAINER_SMTP_PORT (default set to 25) and CONTAINER_IMAP_PORT (default set
  to 143), change this only if you have another MTA on the same docker network
  to prevent port conflict.
* 2025/02/21: updated to Proton Mail Bridge v3.17.0
* 2024/10/02: updated to Proton Mail Bridge v3.14.0
* 2024/09/13: updated to Proton Mail Bridge v3.13.0
* 2024/09/12: added a default compose yaml file for docker compose users.
* 2024/09/05: updated to Proton Mail Bridge v3.12.0, Alpine version: update to
  Golang 1.23
* 2024/04/30: updated to Proton Mail Bridge v3.11.0
* 2024/03/04: Initial public release, Proton Mail Bridge v3.9.1

## Developers notes

There is a [testing branch](https://github.com/VideoCurio/ProtonMailBridgeDocker/tree/testing)
available if you want to submit a Pull Request. Images `ghcr.io/videocurio/dev-debian`
is build on the `testing` branch. For development purpose only ! Do NOT use it in
production.

## License

Copyright (C) 2024-2026  David BASTIEN

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

## Sources

Made from [Debian 13 (trixie) Go image](https://hub.docker.com/_/golang/) and
latest [Proton Mail Bridge sources](https://github.com/ProtonMail/proton-bridge/tree/master)
