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
    ./hardware-configuration.nix
    ../../profiles/system/base.nix
    ../../profiles/system/workstation.nix
    ../../profiles/system/agent-host.nix
    ../../modules/system/hermes-gateway.nix
    ../../modules/system/wireguard.nix
    ../../modules/system/android.nix
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

  # A 32 GiB desktop also runs browsers, editors and agents during rebuilds.
  # Limit both concurrent derivations and parallel compiler work within each.
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
  # Compiler/linker subprocesses can exceed their advertised job count. Keep
  # their aggregate resource use bounded even then; fail the build on OOM
  # rather than allowing it to exhaust the desktop's memory.
  systemd.services.nix-daemon.serviceConfig = {
    MemoryMax = "12G";
    CPUQuota = "400%";
    CPUWeight = 25;
    IOWeight = 25;
  };

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  ];
}
