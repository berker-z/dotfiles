# Wired homelab plan

The ThinkCentre's chosen hostname is `wired`. Keep “ThinkCentre” only as the hardware description;
the flake configuration, host directory, network hostname, MagicDNS name, and SSH alias should all use
`wired`.

## Goal

Add `wired`, the ThinkCentre, as a third NixOS host without turning the shared flake into a pile of hostname conditionals.

The machine should be able to:

- stay online as an always-on Tailscale node;
- host persistent Herdr, Codex, Claude, and Hermes sessions;
- accept key-only SSH and Mosh connections from the laptop and phone;
- provide a lightweight Wayland session under the TV;
- handle basic local media playback and file browsing;
- reuse the existing configuration without changing desktop or laptop behaviour.

## Ground rules

- Preserve the current `nixos` and `laptop` configurations while extracting reusable profiles.
- Keep packages in `packages.nix` unless the refactor establishes a clearer, agreed package-profile interface.
- Put machine-specific hardware and overrides under `hosts/<host>/`.
- Do not copy private SSH keys, Tailscale state, or plaintext service tokens between machines.
- Avoid flake impurity, sandbox exceptions, and hidden hostname checks.
- Make the refactor in small commits so every stage is easy to revert.
- Do not delete the old configuration until all three hosts evaluate and the existing machines have been smoke-tested.

## Proposed shape

Confirm this layout before moving settings, since `profiles/` would be a new project convention:

```text
profiles/
  system/
    base.nix
    workstation.nix
    agent-host.nix
    media-center.nix
  home/
    common.nix
    workstation.nix
    agents.nix
    media-center.nix

hosts/
  nixos/
  laptop/
  wired/
    default.nix
    hardware-configuration.nix
    home.nix
```

Intended composition:

| Host | Base | Workstation | Agent host | Media center |
| --- | --- | --- | --- | --- |
| `nixos` | yes | yes | yes | no |
| `laptop` | yes | yes | yes | no |
| `wired` | yes | no | yes | yes |

The profile names describe capabilities, not machines. Host modules should only compose profiles and contain genuine hardware or machine-specific overrides.

## Phase 1: inventory and baseline

- [x] Choose the hostname: `wired`.
- [x] Record `git status` and keep all unrelated existing changes intact.
- [x] Inventory the shared configuration and each host directory.
- [x] Classify shared settings as base, workstation, agent-host, media-center, or host-specific.
- [x] Record focused `nix eval` results for `nixos` and `laptop` so the refactor can be compared without building.
- [x] Inspect the ThinkCentre hardware and generate its `hardware-configuration.nix` on that machine.

## Phase 2: extract profiles without changing behaviour

- [x] Extract a small system base: Nix settings, users, locale/time, core networking, and genuinely universal services.
- [x] Extract workstation system settings: display manager, Hyprland, graphics, audio, Bluetooth, printing, gaming, and desktop-only services.
- [x] Extract the Home Manager common layer: shell, Git, terminal tools, and other non-graphical defaults.
- [x] Extract workstation Home Manager settings: Hyprland, Quickshell, themes, launchers, notifications, MIME defaults, and desktop applications.
- [x] Extract agent tooling: Herdr, Codex, Claude, Hermes, their hooks, and the environment they require.
- [x] Recompose `nixos` and `laptop` from the profiles and confirm their evaluated options remain equivalent.

## Phase 3: add the ThinkCentre host

- [x] Add the third `nixosConfigurations` entry through the existing `mkSystem` helper.
- [x] Import the ThinkCentre hardware configuration and only its real hardware overrides.
- [x] Compose base + agent-host now; keep media-center explicitly deferred.
- [x] Put agent tooling on all three current machines; revisit only from observed usage.
- [x] Give `wired` a fresh Tailscale identity; do not copy `/var/lib/tailscale/tailscaled.state`.

## Phase 4: remote access

- [x] Enable Tailscale and confirm MagicDNS works through `systemd-resolved`.
- [x] Sign the ThinkCentre into the tailnet once and disable key expiry for unattended access.
- [x] Reuse key-only OpenSSH policy and add only the intended public keys.
- [x] Enable Mosh and confirm an end-to-end session reaches `wired` through trusted `tailscale0`.
- [ ] Review whether trusting all traffic on `tailscale0` is still desirable or whether Tailscale ACLs/grants should narrow access.
- [ ] Verify the boot-managed `herdr-server.service`: remote detach/reattach, agent visibility, and state restoration across a reboot.
- [x] Activate and verify the minimal `hermes-gateway.service`; keep Hermes configuration, authentication, sessions, and memory writable under `~/.hermes`.
- [ ] Activate and observe one successful 06:00 `flake-reconcile.timer` run from Git fast-forward through NixOS switch.
- [x] Keep `wired`'s checkout user-owned but operationally consume-only: drift-free `main`, fast-forward-only pulls, no local flake updates, a root rebuild from the validated `path:` snapshot, and read-only access from the Hermes service. Give Hermes separate credentials only for explicitly authorized project repositories.
- [ ] Test from both the laptop and Moshi on the phone.
- [ ] Decide whether the existing WireGuard setup has any role on this host; do not mix it into the Tailscale path by default.

## Phase 5: lightweight TV session

- [ ] Start with a minimal Wayland compositor; compare Labwc with reusing the existing Hyprland knowledge and configuration.
- [ ] Choose session startup: display manager, `greetd`, or deliberate local autologin.
- [ ] Add only the media applications actually needed initially, likely a browser plus MPV or VLC.
- [ ] Consider Kodi later if the TV-first library interface is worth the extra stack.
- [ ] Configure display scaling, idle behaviour, audio output, and controller/remote input on the actual TV.
- [ ] Keep remote agent services independent of whether a graphical session is logged in.

## Marcel versus Nautilus

Tentative choice: install Marcel first and leave Nautilus out of the initial media-center profile.

Why Marcel fits:

- it is already integrated into this flake and is a fast, preview-oriented native application;
- it should be perfectly suitable for basic browsing of local, already-mounted files;
- neither file manager consumes meaningful idle memory while closed, but avoiding Nautilus also avoids pulling more of the GNOME/GVfs desktop stack into a minimal host.

Why Marcel is not yet a complete Nautilus replacement:

- Marcel is still alpha software and performs real filesystem operations;
- removable-volume navigation and mount management are not implemented yet;
- remote locations are not implemented yet;
- Nautilus remains the safer choice if the TV machine needs a mature UI for USB disks, SMB/SFTP locations, mounts, and recovery from awkward file-operation cases.

Practical fallback:

- use `udisks2`/`udiskie` to mount removable media and let Marcel browse the mounted paths;
- add Nautilus later if that workflow is annoying or network-share browsing is important;
- do not remove Marcel merely to add Nautilus: they can coexist while the workflow is evaluated.

## Phase 6: data, projects, and secrets

- [ ] Decide which repositories should live primarily on the ThinkCentre and which should merely be cloned there.
- [ ] Move projects through Git or an explicit data transfer, not by copying entire home-directory state.
- [ ] Choose storage and backup locations before moving irreplaceable data.
- [ ] Introduce age/sops or another agreed secret mechanism before adding service tokens to the host configuration.
- [ ] Authenticate Codex, Claude, Hermes, and GitHub separately on the ThinkCentre where required.
- [ ] Document which Herdr state is machine-local and what must be backed up to recover sessions.
- [x] Keep Hermes-owned state imperative under `~/.hermes`; Nix declares only the package and gateway lifecycle.
- [ ] Choose a reviewed upstream flake-update workflow; do not mutate `flake.lock` only on the production server.

## Validation and rollout

- [x] Format changed Nix files.
- [x] Run focused `nix eval` checks for all three host configurations.
- [x] Run `nix flake check` once module wiring is stable.
- [ ] Build with `nix build --no-link .#nixosConfigurations.<host>.config.system.build.toplevel` only when ready; the user will perform rebuilds/switches.
- [ ] Switch and reboot one existing machine first to prove the refactor did not alter its desktop session.
- [x] Install or switch the ThinkCentre locally for its first deployment.
- [x] Reboot the ThinkCentre and verify Tailscale, SSH, the headless target, Herdr, and agent commands without a local graphical login.
- [ ] Smoke-test the Wayland session, TV audio, suspend/idle behaviour, VLC/MPV, and file browsing.

## Decisions to make tomorrow

- [ ] ThinkCentre hostname.
- [ ] Whether to introduce the proposed `profiles/` convention or keep capability modules under an existing directory.
- [ ] Labwc versus Hyprland for the TV session.
- [ ] Login manager and whether local autologin is acceptable.
- [ ] Marcel-only initially, or Marcel plus Nautilus from day one.
- [ ] MPV/VLC only versus Kodi immediately.
- [ ] Storage layout and backup destination.
- [ ] Secret-management approach.
- [ ] Tailnet-wide trusted interface versus narrower firewall and ACL rules.
- [ ] Which machines should host agent sessions versus merely connect to them.

## First session tomorrow

1. Boot or connect to the ThinkCentre and collect its hostname, CPU/GPU, disks, network devices, and generated hardware configuration.
2. Confirm the profile directory convention and the compositor choice.
3. Inventory and classify the existing shared configuration.
4. Extract base and workstation profiles while keeping `nixos` and `laptop` equivalent.
5. Add the ThinkCentre host and evaluate all three configurations.
6. Only then add the remote-agent and media-center pieces.

## Installation-day fast path

The repo now defines a reusable `packages.x86_64-linux.wired-installer` ISO. It boots as
`wired-installer`, requests Ethernet configuration through DHCP, advertises
`wired-installer.local`, starts SSH automatically, and accepts only the dedicated
`~/.ssh/id_ed25519_wired` key for root. It never modifies a disk automatically.

1. Build and write the custom ISO to the positively identified Toshiba USB, with a source and read-back checksum.
2. Boot the USB in UEFI mode with Ethernet attached.
3. Connect from the desktop with `ssh -i ~/.ssh/id_ed25519_wired root@wired-installer.local`; use the router DHCP leases or LAN neighbor discovery if mDNS is unavailable.
4. Continue over SSH from the desktop; inventory the hardware and exact target disk before making destructive changes.
5. Decide plain ext4 versus LUKS before partitioning. For LUKS, decide how an unattended server will unlock after a power loss.
6. Mount the target under `/mnt` and generate its hardware configuration there.
7. Copy only that generated hardware module into `hosts/wired/`, then add and validate the `wired` flake configuration in the main repo.
8. Add the dedicated desktop SSH public key plus intended phone/laptop keys to the installed host configuration.
9. Install the validated flake, set a local recovery password, reboot, and enroll the node into Tailscale locally.
10. Prove SSH, MagicDNS, Mosh, and reboot recovery before adding media or graphical capabilities.

## Service and GUI lifecycle

- Boot `wired` into `multi-user.target`, not directly into a graphical session.
- Keep Ethernet, Tailscale, OpenSSH, file sharing, and selected agent supervisors attached to the headless boot lifecycle.
- Enable lingering for the personal user only when concrete systemd user services need to survive logout; installing Codex, Claude, tmux, or Herdr alone does not make their sessions reboot-persistent.
- Put portals, panels, notifications, and compositor helpers under `graphical-session.target`.
- Add a dedicated `profiles/system/media-center.nix`; do not import the full workstation profile.
- Start the TV login path with `sudo systemctl isolate graphical.target` and return to headless mode, after logging out, with `sudo systemctl isolate multi-user.target`.
- Prove manual target switching before adding aliases, remote-control actions, or autologin.
