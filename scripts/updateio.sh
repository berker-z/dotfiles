#!/usr/bin/env bash
set -euo pipefail

target_directory=~/dotfiles

cd "$target_directory" || exit 1
git add . || exit 1
#nix flake update
host="$(hostname)"
# Marcel's development revisions are not all published to Cachix, and
# Copland's box is only published on release tags. Refuse to turn a routine
# system update into a full GPUI/Rust source build on a miss.
for pkg in marcel-rs copland; do
  echo "Checking ${pkg} is installed or available from the binary cache..."
  if ! nix build --no-link --max-jobs 0 \
    ".#nixosConfigurations.${host}.pkgs.${pkg}"; then
    echo "${pkg} could not be obtained without a local build." >&2
    echo "Check the cache/network, or publish the pinned ${pkg} revision with its cache workflow before retrying." >&2
    exit 1
  fi
done
# Apply the concurrency limits to this build too: new nix.settings only take
# effect after the new system has been successfully built and activated.
sudo nixos-rebuild switch --flake .# --max-jobs 4 --cores 4
echo "Updated system."
notify-send "Nixos" "System Rebuilt."
