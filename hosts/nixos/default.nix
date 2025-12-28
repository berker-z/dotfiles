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
      resolution = "1080p";
    };
    #version = 2;
  };

  ######################DEEPCOOL THINGY##############################
  # 1. kernel module

  #boot.kernelModules = ["zenpower"];
  #boot.extraModulePackages = [config.boot.kernelPackages.zenpower];

  services.hardware.deepcool-digital-linux = {
    enable = true;
    extraArgs = [
      "--mode"
      "cpu_temp"
    ];
  };
  # ######################DEEPCOOL THINGY##############################

  networking.hostName = "nixos";
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];
}
