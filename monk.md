# System Mode Specialisation Spec (Normal / Monk)

## Goal

Support two boot-selectable system modes on a single NixOS host:

**Normal** and **Monk**

Switching modes must require only reboot + bootloader selection. No rebuild per switch.

---

## Constraints

Single flake  
Single host per machine  
One `nixos-rebuild` builds all modes  
Uses NixOS specialisations  
Works with GRUB (dual-boot with Windows)

---

## Architecture

Define a **minimal base system**.

Define two sibling specialisations that both inherit from base:

Base  
↳ Normal  
↳ Monk

No specialisation inherits from another.

No runtime switching. Mode = boot entry.

---

## Base System

Contains only what is allowed in all modes:

- Bootloader (GRUB)
- Hardware config
- Users and groups
- Networking
- Audio (pipewire)
- Nix settings
- Locale, timezone
- Minimal fonts
- Core CLI tools (editor, git, ssh)

Base must not assume:

- Any WM or DE
- Any display manager
- Any browser
- Any desktop portals or notifications

Base is bootable but not intended for daily use.

---

## Normal Mode

Purpose: full daily environment.

Adds:

- Preferred WM/DE (e.g. Hyprland)
- Display manager (if used)
- Browsers
- Chat apps
- Games
- Panels, portals, modern desktop services

No constraints on convenience or distraction.

---

## Monk Mode

Purpose: distraction-hostile, austere environment.

Adds:

- XFCE (stacking WM, no tiling)
- Simple terminal
- Music playback
- Editor
- SSH

Avoids:

- Tiling WMs
- Productivity frameworks
- Notifications
- Modern desktop effects
- Transparency, blur, animations

Visual intent:

- Retro / 32-bit aesthetic
- Thick window borders
- Flat UI
- Non-generic bitmap or bitmap-like font
- Low DPI / chunky rendering

Optional:

- Hostfile-level blocking of social media
- Network or service restrictions

---

## Switching Model

`nixos-rebuild switch` builds base + all specialisations.

GRUB shows:

- NixOS – Specialisation normal
- NixOS – Specialisation monk

Switching modes requires only reboot + entry selection.

---

## Refactoring Considerations

Existing configuration is already highly modular:

- Separate system config and home config
- Shared modules
- Host-specific overrides (desktop vs laptop)

Challenges:

- Modules may mix base concerns with user-facing behavior
- Some modules assume a graphical session exists
- Unclear which modules belong to base vs mode-specific layers

Refactor must:

- Preserve current normal behavior initially
- Introduce monk mode incrementally
- Avoid scattering mode conditionals across modules
- Avoid subtractive logic in monk mode

Preferred approach:

- Move imports, do not rewrite modules
- Split modules that do too much
- Accept temporary duplication if it avoids global conditionals

---

## Non-Goals

- No runtime mode switching
- No per-switch rebuilds
- No separate flakes or hosts
- No imperative tweaks
- No “disabled normal mode” monk setup
