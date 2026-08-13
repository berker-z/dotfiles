{
  config,
  inputs,
  lib,
  pkgs,
  primaryUser,
  ...
}: let
  homeDirectory = "/home/${primaryUser}";
  herdrPackage = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  systemd.services.herdr-server = {
    description = "Persistent Herdr agent workspace server";
    wantedBy = ["multi-user.target"];
    path = config.environment.systemPackages;

    environment = {
      HOME = homeDirectory;
    };

    serviceConfig = {
      User = primaryUser;
      WorkingDirectory = homeDirectory;
      ExecStart = "${lib.getExe herdrPackage} server";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "30s";
      UMask = "0077";
    };
  };
}
