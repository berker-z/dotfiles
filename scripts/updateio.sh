#!/usr/bin/env bash

target_directory=~/.dotfiles

cd "$target_directory" || exit 1
git add . || exit 1
#nix flake update
sudo nixos-rebuild switch --flake .# || exit 1
echo "Updated system."
notify-send "Nixos" "System Rebuilt."