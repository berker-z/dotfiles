#!/usr/bin/env bash
set -euo pipefail

pick_tool() {
  printf '%s\n' \
    "Bluetooth  bluetuith" \
    "Audio      wiremix" \
    "Network    impala" \
    "Quit" \
    | fzf \
      --prompt="control-center > " \
      --height=10 \
      --layout=reverse \
      --border \
      --cycle \
      --no-multi
}

run_tool() {
  local label="$1"
  local command="$2"

  clear
  printf 'Launching %s...\n\n' "$label"

  if ! "$command"; then
    printf '\n%s exited with an error. Press Enter to return to the launcher.' "$label"
    read -r _
  fi
}

while true; do
  clear
  selection="$(pick_tool || true)"

  case "$selection" in
    "Bluetooth  bluetuith")
      run_tool "bluetuith" bluetuith
      ;;
    "Audio      wiremix")
      run_tool "wiremix" wiremix
      ;;
    "Network    impala")
      run_tool "impala" impala
      ;;
    "Quit" | "")
      exit 0
      ;;
  esac
done
