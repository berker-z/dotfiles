{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../profiles/system/base.nix
    ../../profiles/system/agent-host.nix
    ../../packages/server.nix
    ../../modules/system/hermes-gateway.nix
    ../../modules/system/flake-reconcile.nix
  ];

  networking = {
    hostName = "wired";

    # Keep key-only SSH available on the home LAN as a recovery path before
    # Tailscale enrollment and whenever the tailnet is unavailable.
    firewall.allowedTCPPorts = [22];
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  users.users.berkerz.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN38WfMRFyT3mTQDddh+8i88V6/v0LcIplM9mnRbrQF nixos-to-wired"
  ];
}
