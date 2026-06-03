#!/usr/bin/env bash

# Minimal HTTP health endpoint for the Proton Mail Bridge container, served
# per-connection by socat (see entrypoint.sh) and meant to be polled by uptime
# monitors such as Uptime Kuma.
#
# It runs health-probe.sh and maps the result to an HTTP response:
#   - 200 healthy      : a real SMTP authentication against the bridge succeeded
#   - 503 unhealthy    : SMTP authentication failed (logged-out account / down)
#   - 503 unconfigured : BRIDGE_USER/BRIDGE_PASSWORD are not set

/app/health-probe.sh
rc=$?

case "$rc" in
  0)
    status="200 OK"
    body='{"status":"healthy","check":"smtp-auth"}'
    ;;
  2)
    status="503 Service Unavailable"
    body='{"status":"unconfigured","check":"smtp-auth","hint":"set BRIDGE_USER and BRIDGE_PASSWORD to enable the functional check"}'
    ;;
  *)
    status="503 Service Unavailable"
    body='{"status":"unhealthy","check":"smtp-auth"}'
    ;;
esac

printf 'HTTP/1.1 %s\r\nContent-Type: application/json\r\nContent-Length: %s\r\nConnection: close\r\n\r\n%s' \
  "$status" "${#body}" "$body"
