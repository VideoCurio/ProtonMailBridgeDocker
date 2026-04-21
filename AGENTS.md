# Proton Mail Bridge Docker - AI Agent Guide

This guide provides the necessary context for AI agents to understand, maintain, and extend the Proton Mail Bridge Docker project.

## Project Overview

The goal of this project is to provide a lightweight, secure, and multi-arch Docker image for the [Proton Mail Bridge](https://github.com/ProtonMail/proton-bridge). Since Proton Mail does not offer public SMTP/IMAP servers, this bridge acts as a local intermediary.

## Technical Architecture

*   **Base OS:** `debian:trixie-slim` (chosen for the best balance between size and library compatibility, specifically for `glibc` and `libsecret`).
*   **Build System:** Multi-stage Docker build using `golang:1.26-trixie` for compilation and `debian:trixie-slim` for the runtime.
*   **Process Management:**
    *   `tini` is used as the init system (PID 1) to handle signal forwarding and zombie reaping.
    *   The bridge is a CLI application that listens only on `127.0.0.1`.
    *   `socat` is used to forward external traffic from the container's ports (default 25/143) to the bridge's internal ports (default 1025/1143).
    *   Secrets are managed via `gpg` and `pass` (standard requirement for Proton Bridge CLI).
*   **Task Runner:** `just` (see `justfile`).

## Key Files

*   `Dockerfile`: Defines the multi-stage build and runtime environment.
*   `entrypoint.sh`: Handles GPG/Pass initialization, starts `socat` proxies, and launches the bridge.
*   `justfile`: Contains recipes for building (`build`, `build-local`), logging into GHCR (`login`), and linting.
*   `VERSION`: Tracks the Proton Mail Bridge version being built.
*   `GPGparams.txt`: Batch configuration for non-interactive GPG key generation during the first run.

## Common Agent Workflows

### Building and Running
Use the `justfile` recipes instead of manual docker commands:
```bash
just build-local v3.24.1  # Local AMD64 build
just build v3.24.1        # Multi-arch build and push
just run                  # Start production container
just stop                 # Stop production container
just setup                # Interactive login (pkill + bridge --cli)
```

### Debugging
The image includes `net-tools` and `socat`. To check if the bridge is listening internally:
```bash
docker exec <container_name> netstat -ltnp
```

### Health Status
The container includes a `HEALTHCHECK` that monitors the availability of the SMTP and IMAP ports. To check the current health status:
```bash
docker inspect --format='{{json .State.Health}}' <container_name>
```
The health check runs every 30 seconds after a 15-second initial startup period.

### Environment Variables
| Variable | Description | Default |
| :--- | :--- | :--- |
| `CONTAINER_SMTP_PORT` | Port exposed by the container for SMTP | `25` |
| `CONTAINER_IMAP_PORT` | Port exposed by the container for IMAP | `143` |
| `PROTON_BRIDGE_SMTP_PORT` | Internal port the bridge listens on | `1025` |
| `PROTON_BRIDGE_IMAP_PORT` | Internal port the bridge listens on | `1143` |

## Design Constraints

1.  **No Alpine:** The Alpine version is deprecated due to persistent issues with `libsecret` and `gpg-agent/keyboxd` compatibility. Do not attempt to revive it unless specifically asked.
2.  **Port Forwarding:** Always ensure `socat` is running in the background; otherwise, the bridge will be unreachable from outside the container.
3.  **Persistence:** The `/root` volume is critical as it stores the GPG keys and the `pass` database containing Proton Mail credentials.

## Maintenance Notes

*   When updating the version, update the `VERSION` file and the `README.md` changelog.
*   Verify that new dependencies are added to both the `build` stage (dev libraries) and the `runtime` stage (shared libraries) in the `Dockerfile`.
