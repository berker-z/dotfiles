# `wired` installation handoff

Last updated: 2026-08-13

This is the operational source of truth for provisioning the Lenovo ThinkCentre M710q as `wired`. Read this file before continuing after context compaction or in a fresh Codex session.

## Current state

- Repository: `/home/berkerz/dotfiles`
- Current machine: `nixos`
- Current branch: `main`
- Published baseline: `3b3a6df refactor host profiles and packages`
- `main` and `origin/main` were synchronized at that commit.
- Existing `nixos` and `laptop` configurations passed `nix flake check --no-build` and retained their exact baseline derivations through the structural refactor.
- New server hostname chosen by the user: `wired`.
- Hardware: Lenovo ThinkCentre M710q.
- Permanent connectivity: Ethernet on the same ordinary home LAN as the Wi-Fi desktop.
- Desktop LAN address observed: `192.168.1.108/24`; gateway `192.168.1.1`.
- The corrected offline bootstrap is installed and running on the M710q.
- `wired` currently has DHCP address `192.168.1.126` on Intel I219-V Ethernet (`enp0s31f6`, MAC `6c:4b:90:80:f5:b4`).
- Key-only SSH as both bootstrap root and `berkerz` was verified; the final configuration disables root SSH.
- SSH and Avahi are active and enabled, although the desktop is not currently resolving `wired.local`.
- Hardware inventory: i5-6600, Intel HD 530, 111.8 GiB Longline SATA SSD, UEFI, TPM 2.0, no Wi-Fi device.
- A dedicated key was created at `~/.ssh/id_ed25519_wired`; its public-key fingerprint is
  `SHA256:BJ6kUSy7zm8fEsC9tafN5dve4eIoTWnAbwwgrthBL4M`.
- `installer/wired-installer.nix` and the flake package output
  `packages.x86_64-linux.wired-installer` have been added locally and evaluate successfully.
- The revised design carries a prebuilt offline `wired` bootstrap closure, guarded installer helper,
  sanitized dotfiles snapshot, and companion `wired-install-guide.html`. It is designed for monitor + keyboard
  installation without Ethernet, followed by unattended Ethernet boot and key-only SSH.
- The corrected ISO is 1,513,308,160 bytes with SHA-256
  `ff800a1db5f56c030fb4875c05867b59408871c6e54d3f42097de62eedc044a7`.
- It was written to the Toshiba USB and exactly 1,513,308,160 bytes were read back; the corrected read-back SHA-256 matched.
- `nix flake check --no-build` passed for both existing hosts, the bootstrap closure, the installer ISO, and the dev shell.
- First physical installation exposed stale filesystem-type detection at the mount stage after formatting. No NixOS
  system was installed. The replacement image clears signatures on both new partitions and mounts root/EFI with
  explicit `ext4`/`vfat` types. Both live and installed consoles now default to Turkish Q (`trq`). The replacement
  USB was written and verified byte-for-byte.
- `hosts/wired/{default,hardware-configuration,home}.nix` and `nixosConfigurations.wired` now exist locally.
- The real host evaluates with Tailscale enabled, key-only SSH limited to `berkerz`, both dedicated desktop and
  Moshi public keys, and TCP 22 retained on the home LAN as a recovery path.
- The real `wired` generation was built and switched successfully over LAN SSH:
  `/nix/store/w1zr3l7v6z5p6m2dqcx3kryw9wivmi4n-nixos-system-wired-26.11.20260807.f13ff45`.
- On the live host, OpenSSH, Tailscale, Avahi, and NetworkManager are active; bootstrap root SSH has been removed;
  Codex, Claude, Hermes, Herdr, and tmux all resolve from `berkerz`'s environment.
- Switching to the real generation removed the bootstrap-only `/etc/wired/dotfiles` recovery snapshot as intended;
  clone the published repository into `~/dotfiles` after these changes are pushed.
- Tailscale is enrolled as a fresh node with `berkerz` as its local operator. Its IPv4 address is
  `100.121.165.32`, its DNS name is `wired.tail3ce83b.ts.net`, and `ssh berkerz@wired` has been verified through
  MagicDNS. Its current key expiry is 2027-02-09; disable expiry in the Tailscale admin console if this is to remain
  unattended. Reboot survival is the remaining remote-access check.
- Commit `54df514 add wired host and offline installer` is published on `origin/main`. The server checkout at
  `/home/berkerz/dotfiles` tracks `origin/main` and contains that implementation.

## USB facts and completed verification

The USB was positively identified before its previous write as:

```text
device: /dev/sda                 # only when connected to this desktop; re-resolve every time
model: TOSHIBA TransMemory
capacity: 14.4 GiB
serial: CC52AF4C8244CDB0897C0CA7
transport: USB
removable: yes
```

The downloaded source image was:

```text
/home/berkerz/Downloads/nixos-minimal-26.05.7526.9f78f44a8794-x86_64-linux.iso
size: 1706262528 bytes
SHA-256: 2b0014255256ead328135a852ca2f390b19ea53ae3f12829427897212beecf4e
```

That hash matched the official NixOS channel checksum. The generic ISO was written with `run0 dd`, then exactly 1,706,262,528 bytes were read back from the USB; the read-back SHA-256 matched exactly.

## Why a custom installer is next

The box can use a monitor or Ethernet conveniently, but not both at once. Build a custom installer ISO that boots beside Ethernet and exposes SSH without requiring a local login or password setup.

The custom installer must:

- use hostname `wired-installer`;
- obtain Ethernet configuration through DHCP;
- start OpenSSH automatically;
- allow key-only root login using a dedicated desktop-to-`wired` public key;
- disable SSH password and keyboard-interactive authentication;
- advertise `wired-installer.local` through mDNS/Avahi when supported;
- include normal inspection, disk, filesystem, Git, and NixOS installation tools;
- perform **no automatic partitioning, formatting, mounting, or installation**;
- contain no private key, token, Tailscale state, WireGuard key, or agent credential.

## Dedicated SSH key gate

Do not reuse the current desktop key merely because it exists. The only public key presently visible on the desktop is:

```text
/home/berkerz/.ssh/id_ed25519.pub
fingerprint: SHA256:OQYDGQhA/ijeIPZox0nyLJDwj7UKQ9xW1+8r6uO6oo8
comment: oracle-vpn
```

Before building the custom ISO, generate a dedicated key after confirming the target path does not already exist:

```bash
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_wired -C "nixos-to-wired"
```

Never add `id_ed25519_wired` to Git or the ISO. Only embed the contents of `id_ed25519_wired.pub`.

## Repository implementation plan

Prefer retaining a useful recovery installer definition rather than creating an undocumented one-off command. Add a small installer module such as:

```text
installer/wired-installer.nix
```

Expose a flake package/output that builds an ISO using the pinned `nixpkgs` installer module. Keep it separate from `nixosConfigurations.wired`; the installer is a recovery/live environment, not the installed host.

Required configuration intent:

```nix
imports = [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
networking.hostName = "wired-installer";
networking.useDHCP = true;
services.openssh.enable = true;
services.openssh.settings = {
  PermitRootLogin = "prohibit-password";
  PasswordAuthentication = false;
  KbdInteractiveAuthentication = false;
};
users.users.root.openssh.authorizedKeys.keys = [ dedicatedPublicKey ];
networking.firewall.allowedTCPPorts = [ 22 ];
services.avahi.enable = true;
services.avahi.publish.enable = true;
services.avahi.publish.addresses = true;
```

Verify exact option names against the pinned nixpkgs before editing. Do not add impurity, `extra-allowed-paths`, sandbox exceptions, or references to private-key paths.

## Build and rewrite sequence

1. User powers off the M710q cleanly and reconnects the USB to this desktop.
2. Re-inventory all disks with `lsblk`; do not assume the USB remains `/dev/sda`.
3. Generate the dedicated SSH key and embed only its public half.
4. Add the custom installer module/output with `apply_patch`.
5. Format changed Nix files.
6. Run a focused ISO evaluation, then build the ISO. Locate the produced `.iso` deterministically.
7. Hash the built ISO and record its exact byte length.
8. Re-identify the USB by transport, removable flag, capacity, model, and full serial.
9. Show the exact destructive target and request user approval before writing.
10. Unmount only partitions belonging to that USB.
11. Revalidate identity, source hash, and unmounted state in the same write command.
12. Use the `secure-local-elevation` skill. Prefer `run0` with a TTY so authentication stays on-device.
13. Write the ISO, sync, read back exactly the ISO byte length, and compare SHA-256.
14. Tell the user to unplug/replug it so the kernel refreshes partition metadata.

## Privilege workflow learned today

The personal skill is installed at:

```text
/home/berkerz/.codex/skills/secure-local-elevation/SKILL.md
```

It passed the skill validator. On this NixOS desktop:

- sandbox escalation alone does not provide OS root;
- `sudo -n` reports that a password is required;
- the Nix store `pkexec` is not setuid and cannot elevate;
- `/run/wrappers/bin/pkexec` was absent;
- `run0` successfully presented a local password prompt when the command used a TTY;
- a blank successful `run0` result was followed by independent state/hash verification.

Never ask the user to send a password through chat or pipe it into a command.

## Headless boot and discovery

After the custom USB is verified:

1. Connect the M710q to permanent Ethernet, insert the USB, and power it on.
2. It previously booted this USB successfully, but USB boot order is not guaranteed. If it does not appear, one local boot-menu interaction may still be necessary.
3. Try:

   ```bash
   getent hosts wired-installer.local
   ping -c 2 wired-installer.local
   ssh -i ~/.ssh/id_ed25519_wired root@wired-installer.local
   ```

4. If mDNS fails, inspect the router's DHCP leases or discover the new `192.168.1.x` neighbor read-only, then SSH by IP with a temporary installer known-hosts file.
5. Confirm the SSH host reports `wired-installer` and that it is the live ISO before any disk action.

## Remote hardware inventory gate

Run read-only inventory first:

```bash
test -d /sys/firmware/efi && echo UEFI || echo LEGACY-BIOS
lsblk -e7 -o NAME,PATH,SIZE,TYPE,TRAN,RO,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL,SERIAL
lspci -nnk
ip -brief link
ip -4 -brief address
findmnt
systemd-cryptenroll --tpm2-device=list
```

Resolve the internal installation disk by model, serial, transport, and capacity. Never infer it only from `/dev/sdX` or `/dev/nvmeXnY`.

Before destructive storage work, present:

- exact target device;
- model and serial;
- capacity;
- existing partitions/filesystems;
- whether data will be recoverable;
- proposed partition table and filesystems.

Obtain explicit approval. Do not run `wipefs`, `parted`, `sgdisk`, `mkfs`, `cryptsetup`, or equivalent before that approval.

## Initial installed system goal

Install a boring headless first generation:

```text
profiles/system/base.nix
profiles/system/agent-host.nix
packages/server.nix
host-specific hardware under hosts/wired/
Home Manager common + agents as appropriate
```

Add:

```text
hosts/wired/default.nix
hosts/wired/hardware-configuration.nix
hosts/wired/home.nix
nixosConfigurations.wired
```

Use `primaryUser = "berkerz"` initially unless the user explicitly chooses otherwise. Do not import:

- `profiles/system/workstation.nix`;
- graphical package list;
- Oracle WireGuard module;
- media-center GUI profile (not designed yet).

The first installed generation needs:

- UEFI boot matching generated hardware/filesystems;
- Ethernet DHCP;
- key-only OpenSSH;
- dedicated desktop public key plus the existing intended Moshi public key;
- Tailscale installed/enabled but enrolled separately after boot;
- Home Manager environment available after SSH login;
- local recovery password set before first reboot.

Generate hardware configuration from mounted target storage with:

```bash
nixos-generate-config --root /mnt
```

Copy only the generated hardware facts into the repo's `hosts/wired/hardware-configuration.nix`; compose policy through the existing profiles.

Evaluate and build `wired` before installation. Use the flake-pinned configuration for `nixos-install --flake ...#wired`.

## Storage decision still open

Do not silently decide between plain ext4 and LUKS.

- Plain ext4 is the quickest route and boots unattended after power loss.
- LUKS protects agent credentials and projects at rest but needs a deliberate unattended-unlock strategy; TPM2 enrollment should be evaluated, not improvised.

Ask before partitioning because this changes the disk layout and boot/recovery behavior.

## Post-install order

1. Set the primary user's local recovery password while still in the installer/chroot.
2. Reboot from the installed disk and remove the USB.
3. Verify LAN SSH by IP first.
4. Run `tailscale up` once and authenticate a fresh node; never copy another host's Tailscale state.
5. Verify Tailscale/MagicDNS SSH and reboot survival.
6. Verify Home Manager-provided Codex, Claude, Hermes, Herdr, tmux, and related commands after SSH login.
7. Observe actual Herdr/tmux persistence before designing reboot-restored agent units.
8. Add file sharing only after choosing explicit exported directories.
9. Revisit GUI/media-center lifecycle later.

## Parked decisions

- GUI lifecycle is parked. Do not implement `multi-user.target`/`graphical.target` switching yet.
- Media-center compositor, login manager, autologin, and applications are undecided.
- Reboot-restored interactive agent sessions are undecided. Home Manager installs/configures tools; that alone does not make interactive sessions daemons.
- Start with disconnect survival through tmux/Herdr. Design explicit systemd user services only from observed requirements.
- File sharing protocol is undecided. SFTP is available through SSH; Samba/NFS should wait for an actual client/use case.
- Oracle host `otto` remains available. Tailscale is the preferred private transport. Oracle-specific WireGuard is not part of `wired`.

## Repository dirt and ownership

At handoff creation, the worktree contained:

```text
M  refactor-architecture.html
M  thinkcentre-plan.md
?? wired-install-handoff.md
?? hosts/laptop/hyp2.lua
?? modules/hypr/hyprland.lua
?? modules/quickshell/hyprland.lua
```

The three Lua files are user-owned experiments and must remain untouched until the separate Hyprland Lua task resumes. The two documentation modifications describe the installation, remote-access, and parked lifecycle plans. Do not accidentally stage the Lua files with installer work.

## Master documentation

- `refactor-architecture.html` is the master architecture document and must remain current.
- `thinkcentre-plan.md` is the detailed `wired` plan.
- This file is the operational installation handoff.

Update all relevant documents after the custom ISO, `wired` host definition, installation, or validation status changes.
