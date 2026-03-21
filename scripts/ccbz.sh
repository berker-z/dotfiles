#!/usr/bin/env bash
set -euo pipefail

tmp_session="$(mktemp)"
trap 'rm -f "$tmp_session"' EXIT

cat >"$tmp_session" <<'EOF'
launch wiremix
launch bluetuith
launch bash -lc 'clear; printf "NetworkManager CLI\n\n"; nmcli device status; printf "\n"; nmcli device wifi list --rescan yes || true; printf "\nExample: nmcli device wifi connect <SSID> --ask\n\n"; exec "${SHELL:-bash}"'
EOF

exec kitty --session "$tmp_session"
