#!/usr/bin/env bash
set -euo pipefail

cdp_url="http://127.0.0.1:9222/json/version"
curl_bin="/run/current-system/sw/bin/curl"
sleep_bin="/run/current-system/sw/bin/sleep"
hyprctl_bin="/run/current-system/sw/bin/hyprctl"

# CDP is already available; leave the user's browser untouched.
if "$curl_bin" --fail --silent --show-error --max-time 2 "$cdp_url" >/dev/null 2>&1; then
  exit 0
fi

# The Hermes gateway is a system service, so explicitly import the active
# graphical session variables before talking to the user's Hyprland instance.
if command -v systemctl >/dev/null 2>&1 && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  while IFS='=' read -r key value; do
    case "$key" in
      DISPLAY|WAYLAND_DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE)
        export "$key=$value"
        ;;
    esac
  done < <(systemctl --user show-environment 2>/dev/null || true)
fi

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || [ -z "${WAYLAND_DISPLAY:-}" ]; then
  printf '%s\n' "Helium CDP is unavailable and no active Hyprland graphical session was found." >&2
  exit 1
fi

# Launch through the Nix/Home Manager-wrapped `helium` command. Its wrapper
# already supplies --remote-debugging-port=9222 and loopback binding.
"$hyprctl_bin" dispatch exec helium >/dev/null

for _ in $(seq 1 30); do
  if "$curl_bin" --fail --silent --show-error --max-time 2 "$cdp_url" >/dev/null 2>&1; then
    exit 0
  fi
  "$sleep_bin" 1
done

printf '%s\n' "Helium was requested through Hyprland but CDP did not become ready on 127.0.0.1:9222." >&2
exit 1
