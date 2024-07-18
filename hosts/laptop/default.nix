

{ lib, config, pkgs, ... }:

{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# Allow unfree packages

# NVIDIA drivers are unfree.  
services.xserver.videoDrivers = [ "nvidia" ]; # If you are using a hybrid laptop add its iGPU manufacturer
hardware.graphics = {  
  enable = true;  
#  driSupport = true;  
#  driSupport32Bit = true;  
};

#20bdb3cd-f7e8-4811-8200-ca2d7c232ad1
boot.loader = {
  efi.efiSysMountPoint = "/boot";
  efi.canTouchEfiVariables = true;

};
  boot.loader.grub = {
  enable = true;
  devices = [ "nodev" ];
  useOSProber = false;
  efiSupport = true;
  extraEntries = ''
  menuentry "Windows" {
  insmod part_gpt
  insmod fat
  insmod search_fs_uuid
  insmod chain
  search --fs-uuid --set=root 20bdb3cd-f7e8-4811-8200-ca2d7c232ad1
  chainloader /EFI/EFI/Microsoft/Boot/bootmgr.efi
  }
  '';

  #version = 2;


  };


networking.hostName = "laptop";
hardware.nvidia = {
  # Enable modesetting for Wayland compositors (hyprland)
  modesetting.enable = true;
  # Use the open source version of the kernel module (for driver 515.43.04+)
  open = false;
  # Enable the Nvidia settings menu
  nvidiaSettings = true;
  # Select the appropriate driver version for your specific GPU
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};

  # Enable Hyprland
  programs.hyprland.enable = true;
  
}
