#!/usr/bin/env bash

# Garbage collection for user
echo "Collecting user garbage..."
nix-collect-garbage -d

# Garbage collection for system (requires sudo)
echo "Collecting system garbage..."
sudo nix-collect-garbage -d

# Optimize nix store (deduplicate)
echo "Optimizing nix store..."
sudo nix-store --optimise

# Notify user
notify-send "Garbagio" "Garbage collection and optimization complete."
