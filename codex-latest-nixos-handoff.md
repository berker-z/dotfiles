# Make Codex track newer releases on this NixOS flake

This repo is already structured well enough to solve the problem cleanly.

You do **not** need to rewrite the setup or package Codex by hand right now.
The simplest fix is:

1. add a dedicated `codex-cli-nix` flake input
2. expose its overlay in your existing `overlays` list
3. tell Home Manager to use `pkgs.codex` explicitly
4. rebuild

This works because your `flake.nix` already injects `nixpkgs.overlays = overlays;` globally into the system.

---

## Why this is needed

`nixos-unstable` is **not** the same thing as “latest upstream version of every package”.
It is just the latest nixpkgs state that has made it through that pipeline.

For fast-moving tools like Codex, nixpkgs can lag. So the practical Nix pattern is:

- keep NixOS itself on normal `nixos-unstable`
- override only the hot tool with a faster-moving flake or overlay

That is what we are doing here.

---

## Files in this repo that matter

From the current uploaded config:

- `flake.nix` already defines a global `overlays` list
- `flake.nix` already enables Home Manager through `home-manager.users.berkerz = import ./home.nix;`
- `codex.nix` already enables `programs.codex`, but does **not** pin the package explicitly yet
- `configuration.nix` does **not** import `codex.nix`, which is fine **if** `home.nix` imports it

So the only likely missing piece is whether `home.nix` imports `./codex.nix`.

---

## 1. Edit `flake.nix`

### Add a new input

Inside `inputs = { ... };`, add this:

```nix
codex-cli-nix = {
  url = "github:sadjow/codex-cli-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

A natural place is near your other flake inputs.

### Add it to the outputs argument list

In this section:

```nix
outputs = inputs @ {
  self,
  nixpkgs,
  nixpkgs-stable,
  home-manager,
  nixos-hardware,
  zen-browser,
  nixvim,
  rust-overlay,
  yorha,
  ...
}:
```

change it to:

```nix
outputs = inputs @ {
  self,
  nixpkgs,
  nixpkgs-stable,
  home-manager,
  nixos-hardware,
  zen-browser,
  nixvim,
  rust-overlay,
  yorha,
  codex-cli-nix,
  ...
}:
```

### Add the overlay to your existing overlay list

Right now your overlay list looks like this:

```nix
overlays = [
  rust-overlay.overlays.default
  (final: _prev: {
    libreoffice = stablePkgs.libreoffice-still;
  })
];
```

Change it to this:

```nix
overlays = [
  rust-overlay.overlays.default
  codex-cli-nix.overlays.default
  (final: _prev: {
    libreoffice = stablePkgs.libreoffice-still;
  })
];
```

That is the key step.

Once this overlay is active, `pkgs.codex` should resolve to the faster-updated package from that flake instead of the lagging nixpkgs one.

---

## 2. Edit `codex.nix`

Your current `codex.nix` already enables Codex and sets the right settings.
Just make the package explicit.

Replace it with this:

```nix
{pkgs, ...}: {
  home.packages = [
    pkgs.mcp-proxy
  ];

  programs.codex = {
    enable = true;
    package = pkgs.codex;

    settings = {
      sandbox_mode = "workspace-write";
      approval_policy = "on-request";

      sandbox_workspace_write = {
        network_access = true;
      };

      features = {
        web_search_request = true;
      };
    };
  };
}
```

This makes it unambiguous which Codex package Home Manager should install.

---

## 3. Make sure `home.nix` imports `codex.nix`

This is the one thing I could not verify from the uploaded files because `home.nix` was not included.

Your `flake.nix` points Home Manager at:

```nix
home-manager.users.berkerz = import ./home.nix;
```

So `codex.nix` only takes effect if `home.nix` imports it.

Check `home.nix` and make sure it contains something like:

```nix
{
  imports = [
    ./codex.nix
  ];

  # rest of your home-manager config
}
```

If `home.nix` already imports `./codex.nix`, you do not need to change anything there.

---

## 4. Rebuild

From your dotfiles repo, update only the new flake input:

```bash
nix flake lock --update-input codex-cli-nix
```

Then rebuild in the usual declarative way.

For example:

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#laptop
```

or if this machine is your desktop host:

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

Use whichever host name matches your actual machine.

---

## 5. Verify

After rebuild:

```bash
which codex
codex --version
```

If the overlay is being picked up correctly, the version should jump forward from the stale nixpkgs one.

You can also inspect the installed package path with:

```bash
readlink -f "$(which codex)"
```

That helps confirm you are getting the package from the new source.

---

## 6. Updating later

Whenever you want a newer Codex release, update just that input again:

```bash
nix flake lock --update-input codex-cli-nix
sudo nixos-rebuild switch --flake ~/dotfiles#laptop
```

That keeps the blast radius small.

---

## 7. What you do **not** need to touch

You do **not** need to edit:

- `packages.nix`
- `configuration.nix`
- your system package list
- `programs.nix-ld` for this specific change

Those can stay as they are.

---

## 8. If this still does not work

The most likely causes are:

### `home.nix` is not importing `codex.nix`

Then your Codex Home Manager config is never being applied.

### another package source is shadowing `codex`

Less likely here, but possible if there is another overlay or custom package definition elsewhere.

### the external flake changed its package name or overlay shape

If that happens, inspect it directly with:

```bash
nix flake show github:sadjow/codex-cli-nix
```

and adjust the overlay/package reference accordingly.

---

## Minimal summary

If you want the shortest version possible:

- add `codex-cli-nix` as a flake input
- add `codex-cli-nix.overlays.default` to your overlay list
- set `programs.codex.package = pkgs.codex;`
- make sure `home.nix` imports `./codex.nix`
- rebuild

That is the whole move.
