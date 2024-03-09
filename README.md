# Proton Mail Bridge docker

A docker version of the [Proton mail Bridge](https://proton.me/mail/bridge) command line interface. It creates a local SMTP server, so other docker containers can send emails via your Proton email account.

__!WARNING!__ As of the time of this writing, you need a paid plan (Mail Plus, Proton Unlimited or Proton for Business) to be able to log in. It won't work for free account.

## Install

Download the latest docker image from:
```bash
docker pull ghcr.io/videocurio/proton-mail-bridge:latest
```
(Optional) It is recommended to set up a custom docker network for all of your containers to use, for DNS / network-alias resolution:
```bash
sudo docker network create --subnet 172.20.0.0/16 network20
```

Launch it with the following command to map TCP ports 12025 for SMTP and 12143 for IMAP on your local loopback.
**You SHOULD provide a path volume storage**.
```bash
docker run -d --name=protonmail_bridge -v /path/to/your/volume/storage:/root -p 127.0.0.1:12025:25/tcp -p 127.0.0.1:12143:143/tcp --network network20 --restart=unless-stopped ghcr.io/videocurio/proton-mail-bridge:latest
```

(Optional) Make sure the container is running:
```bash
docker ps
CONTAINER ID   IMAGE                                          COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
d9932fb7136b   ghcr.io/videocurio/proton-mail-bridge:latest   "/protonmailbridge/e…"   About a minute ago   Up About a minute   127.0.0.1:12025->1025/tcp, 127.0.0.1:12143->1143/tcp   protonmail_bridge
```

## Setup

Now, you need to open a bash terminal on the current running container and use the Proton Bridge interactive command line:
```bash
docker exec -it protonmail_bridge /bin/bash
```
```
# First we need to kill the default bridge startup instance (only one instance of bridge can run at the same time)
root@8972584f86d4:/protonmailbridge# pkill bridge
# Login to your Proton account:
root@8972584f86d4:/protonmailbridge# ./bridge --cli
....
      Welcome to Proton Mail Bridge interactive shell
....
>>> info
No active accounts. Please add account to continue.

# Type help for a list of all commands:
>>> help
# Login to a Proton account (!MUST! be a paid plan to use this client), follow the instructions on screen:
# Tip: Use Ctrl+Shift+V to paste on most Linux terminal.
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

# IF you are using multiple domain names or email addresses, you SHOULD switch to split address mode (it will set credentials for each address in the account):
# It will sync the account again, time to grab a coffee.
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

Use the following information to connect via an SMTP client. The port numbers for the SMTP/IMAP connections are 12025 and 12143 (See your previous Docker container launch command).

You **MUST copy the username AND password** from the info command:
```
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
root@8972584f86d4:/protonmailbridge# exit
```
See a list of [all Proton bridge commands available here](https://proton.me/support/bridge-cli-guide) or use the `help` command.

We have killed the default bridge instance by exiting it during the previous step, so we have to restart the container:
```bash
docker container restart protonmail_bridge
```

(Optionnal) You can check the bridge command line output with:
```bash
docker container logs protonmail_bridge
```
It should end with `A sync has finished for test_account`

## Developers notes

Build docker image, see: [Docker documentation](https://docs.docker.com/language/python/containerize/)
```bash
# Local tests:
git clone https://github.com/VideoCurio/ProtonMailBridgeDocker.git
cd /path/to/ProtonMailBridgeDocker/
docker build --tag=ghcr.io/videocurio/proton-mail-bridge .
docker images | grep videocurio

docker image tag ghcr.io/videocurio/proton-mail-bridge:latest ghcr.io/videocurio/proton-mail-bridge:3.9.1a
docker push ghcr.io/videocurio/proton-mail-bridge:3.9.1a
docker push ghcr.io/videocurio/proton-mail-bridge:latest
```

## Sources:

Made from [Debian 12 (bookworm) Go image](https://hub.docker.com/_/golang/) and [Proton Mail Bridge sources](https://github.com/ProtonMail/proton-bridge/tree/master) v3.9.1

## Notes

An experimental [Alpine Linux](https://www.alpinelinux.org/) version for a small image base footprint is available in the Alpine directory - BUGGED - Do not use it yet in production!