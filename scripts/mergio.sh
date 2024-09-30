#!/usr/bin/env bash

target_directory=~/.dotfiles

cd "$target_directory" || exit 1
git fetch origin main || exit 1
git merge origin/main || exit 1

echo "Git fetch and merge from origin/main completed successfully."


#!/usr/bin/env bash

set -euo pipefail

target_directory=~/.dotfiles

cd "$target_directory" || exit 1

# Fetch the latest changes
git fetch origin main || exit 1

git stash || exit 1

# Reset to the latest commit on origin/main
git reset --hard origin/main || exit 1

echo "NixOS configuration synced from Github."
notify-send "NixOS Configuration" "Updated from GitHub."