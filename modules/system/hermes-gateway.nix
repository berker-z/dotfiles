{
  config,
  inputs,
  lib,
  pkgs,
  primaryUser,
  ...
}: let
  homeDirectory = "/home/${primaryUser}";
  hermesPackage = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
    };

    serviceConfig = {
      User = primaryUser;
      WorkingDirectory = homeDirectory;
      ExecStart = "${lib.getExe hermesPackage} gateway run";
      Restart = "on-failure";
      RestartSec = "10s";
      # This limits only gateway shutdown, not the separate flake rebuild job.
      TimeoutStopSec = "60s";
      UMask = "0077";
    };
  };
}
