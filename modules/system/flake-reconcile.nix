{
  lib,
  pkgs,
  primaryUser,
  ...
}: let
  homeDirectory = "/home/${primaryUser}";
  flakeDirectory = "${homeDirectory}/dotfiles";

  reconcile = pkgs.writeShellApplication {
    name = "flake-reconcile";
    runtimeInputs = with pkgs; [
      coreutils
      git
      nix
      nixos-rebuild
      util-linux
    ];
    text = ''
      flake_dir=${lib.escapeShellArg flakeDirectory}
      deploy_stamp=/var/lib/flake-reconcile/deployed-revision
      host="$(< /proc/sys/kernel/hostname)"

      if [[ ! -d "$flake_dir/.git" ]]; then
        echo "flake checkout is missing: $flake_dir" >&2
        exit 1
      fi

      if ! ${pkgs.util-linux}/bin/runuser --user ${lib.escapeShellArg primaryUser} -- \
        ${pkgs.git}/bin/git -C "$flake_dir" diff --quiet --ignore-submodules --; then
        echo "refusing to overwrite tracked changes in $flake_dir" >&2
        exit 1
      fi
      if ! ${pkgs.util-linux}/bin/runuser --user ${lib.escapeShellArg primaryUser} -- \
        ${pkgs.git}/bin/git -C "$flake_dir" diff --cached --quiet --ignore-submodules --; then
        echo "refusing to overwrite staged changes in $flake_dir" >&2
        exit 1
      fi

      branch="$(${pkgs.util-linux}/bin/runuser --user ${lib.escapeShellArg primaryUser} -- \
        ${pkgs.git}/bin/git -C "$flake_dir" branch --show-current)"
      if [[ "$branch" != main ]]; then
        echo "refusing to deploy checkout branch '$branch'; expected 'main'" >&2
        exit 1
      fi

      echo "==> Fast-forwarding $flake_dir from origin/main"
      ${pkgs.util-linux}/bin/runuser --user ${lib.escapeShellArg primaryUser} -- \
        ${pkgs.git}/bin/git -C "$flake_dir" pull --ff-only origin main

      revision="$(${pkgs.util-linux}/bin/runuser --user ${lib.escapeShellArg primaryUser} -- \
        ${pkgs.git}/bin/git -C "$flake_dir" rev-parse HEAD)"
      deployed_revision=""
      if [[ -r "$deploy_stamp" ]]; then
        deployed_revision="$(<"$deploy_stamp")"
      fi

      if [[ "$revision" == "$deployed_revision" ]]; then
        echo "==> $revision is already deployed; nothing to do"
        exit 0
      fi

      echo "==> Switching $host to Git revision $revision"
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "$flake_dir#$host"
      printf '%s\n' "$revision" > "$deploy_stamp"
      echo "==> Successfully deployed $revision"
    '';
  };
in {
  systemd.services.flake-reconcile = {
    description = "Fast-forward and deploy the host's pinned NixOS flake";
    after = [
      "network-online.target"
      "nix-daemon.service"
    ];
    wants = ["network-online.target"];

    environment = {
      HOME = "/root";
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = flakeDirectory;
      ExecStart = lib.getExe reconcile;
      StateDirectory = "flake-reconcile";
      # Builds on this host can take many minutes; allow ample headroom.
      TimeoutStartSec = "2h";
    };
  };

  systemd.timers.flake-reconcile = {
    description = "Daily reconciliation with the committed NixOS flake";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
      AccuracySec = "1m";
      Unit = "flake-reconcile.service";
    };
  };
}
