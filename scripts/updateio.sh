#!/usr/bin/env bash

target_directory=~/.dotfiles

cd "$target_directory" || exit 1
git add . || exit 1
nix flake update
sudo nixos-rebuild switch --flake .#
echo "Updated system."