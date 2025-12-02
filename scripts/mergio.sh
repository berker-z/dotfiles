#!/usr/bin/env bash

set -euo pipefail

target_directory=~/dotfiles

cd "$target_directory" || exit 1

# Fetch the latest changes
git fetch origin main || exit 1

git stash || exit 1

# Reset to the latest commit on origin/main
git reset --hard origin/main || exit 1

echo "NixOS configuration synced from Github."
notify-send  -t 1500 "NixOS Configuration" "Updated from GitHub."