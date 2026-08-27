#!/usr/bin/env bash
set -euo pipefail

projects_root="${HOME}/Projects"
apply=false

case "${1:-}" in
  "") ;;
  --apply) apply=true ;;
  *)
    printf 'Usage: %s [--apply]\n' "${0##*/}" >&2
    exit 2
    ;;
esac

if [[ ! -d "$projects_root" ]]; then
  printf 'Projects directory does not exist: %s\n' "$projects_root" >&2
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  printf 'cargo is not available on PATH.\n' >&2
  exit 1
fi

declare -A seen_workspaces=()
workspace_count=0

while IFS= read -r -d '' manifest; do
  workspace_manifest="$({
    cargo locate-project \
      --manifest-path "$manifest" \
      --workspace \
      --message-format plain 2>/dev/null ||
      printf '%s\n' "$manifest"
  })"

  if [[ -n "${seen_workspaces["$workspace_manifest"]+yes}" ]]; then
    continue
  fi

  seen_workspaces["$workspace_manifest"]=1
  workspace_count=$((workspace_count + 1))
  printf '%s: %s\n' "$([[ "$apply" == true ]] && printf 'Cleaning' || printf 'Found')" "${workspace_manifest%/Cargo.toml}"

  if [[ "$apply" == true ]]; then
    cargo clean --manifest-path "$workspace_manifest"
  fi
done < <(
  find "$projects_root" \
    \( -name .git -o -name .direnv -o -name node_modules -o -name target -o -name vendor \) -prune \
    -o -type f -name Cargo.toml -print0
)

if [[ "$apply" == true ]]; then
  printf 'Cleaned %d Rust workspace(s).\n' "$workspace_count"
else
  printf 'Found %d Rust workspace(s). Run cleanio --apply to clean them.\n' "$workspace_count"
fi
