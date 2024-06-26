

{ lib, config, pkgs, ... }:

{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# Allow unfree packages

# NVIDIA drivers are unfree.  
services.xserver.videoDrivers = [ "nvidia" ]; # If you are using a hybrid laptop add its iGPU manufacturer
hardware.opengl = {  
  enable = true;  
  driSupport = true;  
  driSupport32Bit = true;  
};

hardware.nvidia = {
  # Enable modesetting for Wayland compositors (hyprland)
  modesetting.enable = true;
  # Use the open source version of the kernel module (for driver 515.43.04+)
  open = true;
  # Enable the Nvidia settings menu
  nvidiaSettings = true;
  # Select the appropriate driver version for your specific GPU
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};

  # Enable Hyprland
  programs.hyprland.enable = true;
  
}
