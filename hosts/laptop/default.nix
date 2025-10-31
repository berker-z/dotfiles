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

  {
  # ensure wireplumber is the session manager
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
  };

  environment.etc."wireplumber/main.lua.d/90-hdmi-autoswitch.lua".text = ''
    rule = {
      matches = {
        {
          { "device.profile", "matches", "*hdmi*" }
        }
      },
      apply_properties = {
        ["device.autoconnect"] = true,
        ["device.disabled"] = false,
        ["priority.session"] = 2000
      }
    }

    table.insert(alsa_monitor.rules, rule)

    -- also switch default sink automatically
    subscribe = {
      event = "object-added",
      callback = function (object)
        local t = object["media.class"]
        if t == "Audio/Sink" and string.find(object["node.name"], "hdmi") then
          Node.set_default(object)
        end
      end
    }
  '';
}

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
