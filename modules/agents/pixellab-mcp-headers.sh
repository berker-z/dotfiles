#!/usr/bin/env bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
token_file="$config_home/pixellab/api-token"

if [[ ! -r "$token_file" ]]; then
  printf 'PixelLab token not found at %s\n' "$token_file" >&2
  exit 1
fi

token="$(tr -d '\r\n' < "$token_file")"
if [[ -z "$token" ]]; then
  printf 'PixelLab token file is empty: %s\n' "$token_file" >&2
  exit 1
fi

exec @jq@ -cn --arg token "$token" '{Authorization: ("Bearer " + $token)}'
