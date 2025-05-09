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

  # Allow unfree packages

  # NVIDIA drivers are unfree.
  boot.loader.grub = {
    yorhaTheme = {
      enable = true;
      resolution = "1080p";
    };
    #version = 2;
  };
  services.xserver.videoDrivers = ["nvidia"]; # If you are using a hybrid laptop add its iGPU manufacturer
  hardware.graphics = {
    enable = true;
    #  driSupport = true;
    #  driSupport32Bit = true;
  };

  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
  };

  #20bdb3cd-f7e8-4811-8200-ca2d7c232ad1

  systemd.services."nvidia-powerd".enable = false;

  networking.hostName = "laptop";
  hardware.nvidia = {
    # Enable modesetting for Wayland compositors (hyprland)
    modesetting.enable = true;
    # Use the open source version of the kernel module (for driver 515.43.04+)
    open = false;
    powerManagement.enable = false;
    #powerManagement.finegrained = true;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    # Select the appropriate driver version for your specific GPU
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Enable Hyprland
  programs.hyprland.enable = true;
}
