#!/usr/bin/env bash
set -euo pipefail

nix-collect-garbage -d
sudo nix-collect-garbage -d
sudo nix-store --optimise
