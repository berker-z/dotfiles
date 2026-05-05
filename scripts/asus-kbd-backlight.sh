#!/usr/bin/env bash
set -euo pipefail

asusctl=/run/current-system/sw/bin/asusctl
brightnessctl=/run/current-system/sw/bin/brightnessctl
led=/sys/class/leds/asus::kbd_backlight/brightness
max=/sys/class/leds/asus::kbd_backlight/max_brightness

usage() {
  echo "Usage: $0 next|prev" >&2
  exit 2
}

fallback() {
  local direction="$1"
  local current max_value target

  current="$(cat "$led")"
  max_value="$(cat "$max")"

  case "$direction" in
    next)
      target=$((current + 1))
      if ((target > max_value)); then
        target=0
      fi
      ;;
    prev)
      target=$((current - 1))
      if ((target < 0)); then
        target="$max_value"
      fi
      ;;
    *)
      usage
      ;;
  esac

  if ! "$brightnessctl" --device=asus::kbd_backlight set "$target" >/dev/null 2>&1; then
    printf '%s\n' "$target" >"$led"
  fi
}

case "${1:-}" in
  next | prev)
    # asusctl 6.3.7 can abort when Hyprland gives it an awkward stdout/stderr.
    "$asusctl" leds "$1" >/dev/null 2>&1 || fallback "$1"
    ;;
  *)
    usage
    ;;
esac
