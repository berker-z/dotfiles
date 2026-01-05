{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    yorhaTheme = {
      enable = true;
      resolution = "1080p";
    };
  };

  networking.hostName = "laptop";

  # Hybrid graphics: make AMD the primary display GPU, keep NVIDIA for offload.
  services.xserver.videoDrivers = ["amdgpu" "nvidia"];

  hardware.graphics.enable = true;

  # Ensure amdgpu initializes early so boot isn't a coin flip.
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["amdgpu"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    powerManagement.enable = true;
    # powerManagement.finegrained = true;

    nvidiaSettings = true;

    # Prefer stable on laptops unless you're chasing a specific beta fix.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # From your lspci:
      # NVIDIA 01:00.0 -> PCI:1:0:0
      # AMD    04:00.0 -> PCI:4:0:0
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:4:0:0";
    };
  };

  services.power-profiles-daemon.enable = true;

  # Ensure EC/platform fan table starts quiet on boot.
  systemd.services.asus-profile-quiet = {
    description = "Set ASUS platform profile to Quiet at boot";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target" "asusd.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/asusctl profile -P Quiet";
    };
  };

  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
  };
  systemd.services.nvidia-powerd.enable = false;
  # Enable Hyprland
  programs.hyprland.enable = true;
}
