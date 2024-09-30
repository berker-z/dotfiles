#!/usr/bin/env bash

target_directory=~/.dotfiles

cd "$target_directory" || exit 1
git add . || exit 1
git commit -m "regular update" || exit 1
git push -u origin main || exit 1

echo "Pushed to git successfully."
notify-send "NixOS Configuration" "Pushed changes to GitHub."