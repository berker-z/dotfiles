#!/usr/bin/env bash
set -euo pipefail

# Garbage collection for system (requires sudo)
echo "Collecting system garbage..."
system_gc_output=$(sudo nix-collect-garbage -d 2>&1)
echo "$system_gc_output"

# Garbage collection for user
echo "Collecting user garbage..."
user_gc_output=$(nix-collect-garbage -d 2>&1)
echo "$user_gc_output"

# Optimize nix store (deduplicate)
echo "Optimizing nix store..."
opt_output=$(sudo nix-store --optimise 2>&1)
echo "$opt_output"

# Extract the "XYZ MiB/GiB freed" snippets for a quick tally
system_freed=$(echo "$system_gc_output" | grep -Eo '[0-9.]+ (GiB|MiB) freed' | tail -n1)
user_freed=$(echo "$user_gc_output" | grep -Eo '[0-9.]+ (GiB|MiB) freed' | tail -n1)
opt_freed=$(echo "$opt_output" | grep -Eo '[0-9.]+ (GiB|MiB) freed' | tail -n1)

echo "Tally: system=${system_freed:-unknown}; user=${user_freed:-unknown}; optimise=${opt_freed:-unknown}"
