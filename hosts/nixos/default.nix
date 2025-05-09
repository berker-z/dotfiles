# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  boot.loader.grub = {
    yorhaTheme = {
      enable = true;
      resolution = "1440p";
    };
    #version = 2;
  };

  ######################DEEPCOOL THINGY##############################
  # 1. kernel module

  boot.kernelModules = ["zenpower"];
  boot.extraModulePackages = [config.boot.kernelPackages.zenpower];

  # 2. udev so you don’t have to stay root forever
  services.udev.extraRules = ''
    # deepcool hid device
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="34d3", ATTRS{idProduct}=="1100", MODE="0666"
  '';

  systemd.services.deepcool-digital = {
    description = "feed the ak400 digital lcd";
    after = ["udev-settle.service"]; # wait until hidraw + hwmon exist
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "berkerz";
      Group = "users";
      WorkingDirectory = "/home/berkerz";
      ExecStart = "/home/berkerz/deepcool";
      Restart = "on-failure";
      RestartSec = 2;
      # inherits nix-ld env automatically because you enabled programs.nix-ld
    };
  };
  ######################DEEPCOOL THINGY##############################

  networking.hostName = "nixos";
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];
}
