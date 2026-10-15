#!/usr/bin/env bash
# Trusts a corporate network service's root CA in iOS simulators, so the app
# can reach Sherdog from a network that inspects TLS traffic. Simulators have
# their own trust store; trusting the CA on the Mac does not cover them.
#
# Usage: swift/scripts/trust_dev_proxy_cert.sh <cert.pem> [simulator-udid|booted|all]
# Default target: the booted simulator; `all` covers every simulator (shut-down
# ones are booted briefly). Keep the certificate out of git.
set -euo pipefail

CERT="${1:-}"
TARGET="${2:-booted}"

if [[ -z "$CERT" || ! -f "$CERT" ]]; then
  echo "Usage: $0 <cert.pem> [simulator-udid|booted|all]" >&2
  exit 1
fi

if [[ "$TARGET" == "all" ]]; then
  ids=$(xcrun simctl list devices available -j | python3 -I -c \
    'import json,sys; print("\n".join(d["udid"] for r in json.load(sys.stdin)["devices"].values() for d in r))')
else
  ids="$TARGET"
fi

# The keychain can only be changed on a booted simulator: boot the ones that
# are shut down, trust the CA, then shut them down again.
for id in $ids; do
  booted_here=0
  if [[ "$id" != "booted" ]] && ! xcrun simctl list devices | grep "$id" | grep -q Booted; then
    xcrun simctl boot "$id" && booted_here=1
    xcrun simctl bootstatus "$id" -b >/dev/null 2>&1 || true
  fi
  xcrun simctl keychain "$id" add-root-cert "$CERT" && echo "trusted $(basename "$CERT") on $id"
  if [[ $booted_here == 1 ]]; then xcrun simctl shutdown "$id"; fi
done
