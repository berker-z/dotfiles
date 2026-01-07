#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <max_khz|restore>" >&2
  exit 2
}

if [[ $# -ne 1 ]]; then
  usage
fi

arg="$1"

if [[ "$arg" != "restore" && ! "$arg" =~ ^[0-9]+$ ]]; then
  usage
fi

for policy in /sys/devices/system/cpu/cpufreq/policy*; do
  max_path="$policy/scaling_max_freq"
  info_path="$policy/cpuinfo_max_freq"
  [[ -w "$max_path" ]] || continue

  if [[ "$arg" == "restore" ]]; then
    target="$(cat "$info_path")"
  else
    target="$arg"
  fi

  echo "$target" >"$max_path"
done
