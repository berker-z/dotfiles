#!/usr/bin/env bash

target_directory=~/.dotfiles

cd "$target_directory" || exit 1
git fetch origin main || exit 1
git merge origin/main || exit 1

echo "Git fetch and merge from origin/main completed successfully."