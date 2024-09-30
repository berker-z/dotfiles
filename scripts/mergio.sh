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

# Check if there are any changes
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
    # Stash any local changes
    git stash

    # Reset to the latest commit on origin/main
    git reset --hard origin/main

    echo "NixOS configuration synced from Github."
    notify-send "NixOS Configuration" "Updated from GitHub."
    # Optionally, you can add a notification here
    # notify-send "NixOS Configuration" "Updated and rebuilt from GitHub"
else
    echo "Already up to date. No changes to apply."
    notify-send "NixOS Configuration" "No changes on GitHub."

fi