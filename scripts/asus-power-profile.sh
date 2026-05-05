#!/usr/bin/env bash
set -euo pipefail

bin=/run/current-system/sw/bin
asusctl="$bin/asusctl"
systemctl="$bin/systemctl"
awk="$bin/awk"
cat="$bin/cat"
pkill="$bin/pkill"
sudo=/run/wrappers/bin/sudo

balanced_cpu_curve="45c:0,50c:15,53c:18,57c:28,61c:40,70c:70,82c:100,98c:142"
balanced_gpu_curve="45c:0,50c:20,53c:24,57c:34,61c:48,66c:80,70c:110,98c:147"
performance_cpu_curve="45c:0,48c:18,52c:22,56c:32,60c:45,64c:80,68c:120,98c:163"
performance_gpu_curve="45c:0,48c:20,52c:26,56c:36,60c:52,64c:90,68c:130,98c:175"

usage() {
  echo "Usage: $0 status|toggle|set <Quiet|Balanced|Performance>" >&2
  exit 2
}

active_profile() {
  local profile

  if [[ ! -r /sys/firmware/acpi/platform_profile ]]; then
    echo "Unknown"
    return
  fi

  profile="$("$cat" /sys/firmware/acpi/platform_profile)"
  case "$profile" in
    quiet) echo Quiet ;;
    balanced) echo Balanced ;;
    performance) echo Performance ;;
    *) echo "Unknown" ;;
  esac
}

validate_profile() {
  case "$1" in
    Quiet | Balanced | Performance) ;;
    *) usage ;;
  esac
}

set_profile_for_ac_and_battery() {
  local profile="$1"

  "$asusctl" profile set --ac "$profile"
  "$asusctl" profile set --battery "$profile"
  "$asusctl" profile set "$profile"
}

set_curve() {
  local profile="$1"
  local cpu_curve="$2"
  local gpu_curve="$3"

  "$asusctl" fan-curve --mod-profile "$profile" --fan cpu --data "$cpu_curve"
  "$asusctl" fan-curve --mod-profile "$profile" --fan gpu --data "$gpu_curve"
  "$asusctl" fan-curve --mod-profile "$profile" --enable-fan-curves true
}

disable_curve() {
  local profile="$1"

  "$asusctl" fan-curve --mod-profile "$profile" --enable-fan-curves false
}

set_cpu_max_freq() {
  local value="$1"
  local unit="cpu-max-freq@${value}.service"

  if [[ "${EUID}" -eq 0 ]]; then
    "$systemctl" start "$unit"
  else
    "$sudo" -n "$systemctl" start "$unit"
  fi
}

refresh_waybar() {
  "$pkill" -RTMIN+12 waybar 2>/dev/null || true
}

apply_profile() {
  local profile="$1"
  validate_profile "$profile"

  case "$profile" in
    Quiet)
      disable_curve Balanced
      disable_curve Performance
      set_profile_for_ac_and_battery Quiet
      set_cpu_max_freq 3200000
      ;;
    Balanced)
      set_curve Balanced "$balanced_cpu_curve" "$balanced_gpu_curve"
      set_profile_for_ac_and_battery Balanced
      set_cpu_max_freq 3200000
      ;;
    Performance)
      set_curve Performance "$performance_cpu_curve" "$performance_gpu_curve"
      set_profile_for_ac_and_battery Performance
      set_cpu_max_freq restore
      ;;
  esac
}

status_json() {
  local active ac battery source icon class label

  active="$(active_profile)"
  ac="$("$awk" -F': ' '/platform_profile_on_ac/ {gsub(/,/, "", $2); print $2; exit}' /etc/asusd/asusd.ron 2>/dev/null || true)"
  battery="$("$awk" -F': ' '/platform_profile_on_battery/ {gsub(/,/, "", $2); print $2; exit}' /etc/asusd/asusd.ron 2>/dev/null || true)"

  source="Battery"
  if [[ -r /sys/class/power_supply/AC0/online ]] && [[ "$("$cat" /sys/class/power_supply/AC0/online)" == "1" ]]; then
    source="AC"
  fi

  case "$active" in
    Quiet)
      icon=""
      class="quiet"
      label="Quiet"
      ;;
    Balanced)
      icon=""
      class="balanced"
      label="Balanced"
      ;;
    Performance)
      icon=""
      class="performance"
      label="Turbo"
      ;;
    *)
      icon="?"
      class="unknown"
      label="Unknown"
      ;;
  esac

  printf '{"text":"%s","class":"%s","tooltip":"%s (active)\\nAC: %s\\nBattery: %s\\nSource: %s"}\n' \
    "$icon" "$class" "$label" "${ac:-unknown}" "${battery:-unknown}" "$source"
}

toggle_profile() {
  local current target

  current="$(active_profile || true)"
  case "$current" in
    Quiet) target=Balanced ;;
    Balanced) target=Performance ;;
    *) target=Quiet ;;
  esac

  apply_profile "$target"
  refresh_waybar
}

case "${1:-}" in
  status)
    status_json
    ;;
  toggle)
    toggle_profile
    ;;
  set)
    [[ $# -eq 2 ]] || usage
    apply_profile "$2"
    refresh_waybar
    ;;
  *)
    usage
    ;;
esac
