# Repository Guidelines

# Purity & Respect

- Preserve Nix purity and established workflows: do not add `extra-allowed-paths`, flake-level hacks, or sandbox breaks; do not force impurity to “make it work.”
- Follow existing patterns and files (e.g., `vars.nix` for env vars, host modules for overrides). Ask before introducing new patterns or relocating settings.
- Keep changes minimal and scoped; avoid hardcoding user paths unless already present. Do not touch key material locations unless explicitly requested.
- When unsure, stop and research the correct approach instead of guessing or experimenting in-place. Respect that this config is long-lived and curated.

## Project Structure & Module Organization

- `flake.nix`, `configuration.nix`, and `home.nix` define the base NixOS + Home Manager configuration; host-specific overlays live in `hosts/<host>/`.
- `modules/` holds reusable modules (Hyprland, waybar, swaylock, themes). Add new services as separate files and list them in `modules/default.nix` to keep imports tidy.
- `packages.nix` centralizes system and home package selections; prefer edits here over scattering package adds.
- `scripts/` contains small helpers (e.g., `updateio.sh` for rebuilds); keep new scripts idempotent and echo status.
- `assets/` stores wallpapers and theme assets. Avoid committing large binaries; reference paths from modules instead.
- `secrets.nix` is currently plain text—scrub tokens before pushing and prefer environment/age-based secrets for anything sensitive.

## Build, Test, and Development Commands

- Validate flake and module integrity: `nix flake check`.
- Build or switch a host: `sudo nixos-rebuild switch --flake .#nixos` (or `.#laptop`). Use `--build-host`/`--target-host` when deploying remotely.
- Quick build without switching: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Enter the Rust-friendly dev shell: `nix develop .#rusticed`.
- Update + rebuild helper: `./scripts/updateio.sh` (assumes `.#` default system); keep it in sync with flake changes.

## Coding Style & Naming Conventions

- Nix files use two-space indentation and compact attribute sets. Group related options, keep list entries vertically aligned, and favor descriptive attribute names (e.g., `services.hyprpaper.settings`).
- Prefer `alejandra` or `nixfmt-rfc-style` for Nix formatting; run before committing. For shell snippets, keep `#!/usr/bin/env bash` and `set -euo pipefail` on new scripts.
- File naming: lowercase with hyphens; place host-specific overrides under `hosts/<host>/` and shared themes under `modules/themes/`.

## Testing Guidelines

- Minimum gate: `nix flake check` plus a build for each affected host (`nix build .#nixosConfigurations.<host>...`).
- For risky changes, run `sudo nixos-rebuild test --flake .#<host>` to boot-validate without persisting.
- UI tweaks (Hyprland/waybar/swaylock) should be smoke-tested in a VM or non-critical session when possible; capture screenshots for review.

## Commit & Pull Request Guidelines

- Use short, present-tense commit messages (`fix hyprpaper preload path`, `refine laptop power settings`); avoid generic “update” where a specific scope fits.
- In PRs describe scope, touched hosts/modules, and commands run (flake check/build/test). Link issues if they exist and attach visuals for UI changes.
- Keep diffs focused: separate formatting-only commits from behavioral changes, and note any follow-up debt in the PR description.
