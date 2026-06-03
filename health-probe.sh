#!/usr/bin/env bash

# Health probe for the Proton Mail Bridge container.
#
# Exit codes:
#   0 = healthy      -> SMTP authentication against the bridge succeeded
#   2 = unconfigured -> BRIDGE_USER/BRIDGE_PASSWORD not set, real check skipped
#   1 = unhealthy    -> SMTP auth failed (logged-out account / bridge down), or
#                       (when unconfigured) the proxy ports are not listening
#
# The HTTP health endpoint (healthcheck-http.sh, polled by Uptime Kuma) only
# reports healthy on exit 0: a real SMTP authentication. There is deliberately
# no "ports listening" success path there, since an HTTP/TCP port check brings
# nothing over what Uptime Kuma already does natively.
#
# The docker HEALTHCHECK treats exit 2 as healthy too, so the image keeps a
# working liveness check out of the box even without credentials.
#
# Caveat: a silent session expiry where the bridge still accepts local AUTH but
# can no longer reach Proton is not detectable without actually sending mail.

set -uo pipefail

if [ -z "${BRIDGE_USER:-}" ] || [ -z "${BRIDGE_PASSWORD:-}" ]; then
  # No credentials: cannot run the functional check. Keep a minimal liveness
  # check for docker's own HEALTHCHECK, but signal "unconfigured" (exit 2) so
  # the HTTP endpoint does not report a false healthy.
  if netstat -ltn | grep -q ":${CONTAINER_SMTP_PORT} " &&
     netstat -ltn | grep -q ":${CONTAINER_IMAP_PORT} "; then
    exit 2
  fi
  exit 1
fi

# Real SMTP authentication: STARTTLS + AUTH LOGIN, then QUIT before sending
# anything. Talks to the bridge's internal port directly, which also verifies
# the bridge process itself is up (not merely the socat proxy).
if swaks \
    --server "${PROTON_BRIDGE_HOST:-127.0.0.1}" \
    --port "${PROTON_BRIDGE_SMTP_PORT:-1025}" \
    --auth LOGIN \
    --auth-user "$BRIDGE_USER" \
    --auth-password "$BRIDGE_PASSWORD" \
    --tls \
    --quit-after AUTH \
    --timeout 10 \
    --silent 3 >/dev/null 2>&1; then
  exit 0
fi

exit 1
