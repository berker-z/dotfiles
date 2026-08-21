{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}: let
  homeDirectory = "/home/${primaryUser}";
  runtimeDirectory = "/run/user/${toString config.users.users.${primaryUser}.uid}";
  hermesPackage = pkgs.hermes-agent-full;
in {
  systemd.services.hermes-gateway = {
    description = "Hermes messaging gateway";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    path = config.environment.systemPackages;

    environment = {
      HOME = homeDirectory;
      HERMES_HOME = "${homeDirectory}/.hermes";
      XDG_RUNTIME_DIR = runtimeDirectory;
      DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDirectory}/bus";
    };

    serviceConfig = {
      User = primaryUser;
      WorkingDirectory = homeDirectory;
      ExecStart = "${lib.getExe hermesPackage} gateway run";
      Restart = "on-failure";
      RestartSec = "10s";
      ReadOnlyPaths = ["${homeDirectory}/dotfiles"];
      # Allow Hermes's default 180s drain timeout plus systemd overhead.
      TimeoutStopSec = "240s";
      UMask = "0077";
    };
  };
}
