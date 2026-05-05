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

  # Hyprland 0.54 uses Aquamarine's AQ_DRM_DEVICES for GPU selection. The
  # stable by-path names contain colons, so expose a colon-free symlink for
  # the AMD iGPU and make the compositor pin to that from hyp2.conf.
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:04:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
  '';

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

  # nixos-hardware's generic laptop module enables TLP by default. Keep ASUS
  # platform profiles owned by asusd/the Waybar script instead of another
  # daemon rewriting profiles on AC/Battery transitions.
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = false;

  # Ensure EC/platform fan table starts quiet on boot.
  systemd.services.asus-profile-quiet = {
    description = "Set ASUS platform profile to Quiet at boot";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target" "asusd.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash /home/berkerz/dotfiles/scripts/asus-power-profile.sh set Quiet";
    };
  };

  # Re-apply ASUS Aura keyboard power state after boot. Without this, asusd can
  # report a non-off brightness while the physical keyboard LEDs stay dark.
  systemd.services.asus-kbd-backlight-restore = {
    description = "Restore ASUS keyboard backlight at boot";
    wantedBy = ["multi-user.target"];
    wants = ["asusd.service"];
    after = ["multi-user.target" "asusd.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "/run/current-system/sw/bin/sleep 10";
      ExecStart = "/run/current-system/sw/bin/bash /home/berkerz/dotfiles/scripts/asus-kbd-backlight.sh restore";
    };
  };

  systemd.services."cpu-max-freq@" = {
    description = "Set CPU max frequency (kHz) or restore default";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash /home/berkerz/dotfiles/scripts/set-cpu-max-freq.sh %i";
    };
  };

  security.sudo.extraRules = [
    {
      users = ["berkerz"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start cpu-max-freq@*.service";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
  };
  systemd.services.nvidia-powerd.enable = false;
  # Enable Hyprland
  programs.hyprland.enable = true;
}
