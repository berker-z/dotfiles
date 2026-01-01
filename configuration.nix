# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./packages.nix
    ./wireguard.nix
    ./sddm.nix
    ./vars.nix
  ];
  services.hardware.openrgb.enable = true;
  hardware.i2c.enable = true;
  boot.kernelModules = ["i2c-dev"];
  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.systemd-boot.configurationLimit = 5;

  boot.loader.efi = {
    efiSysMountPoint = "/boot";
    canTouchEfiVariables = true;
  };
  boot.loader.grub = {
    enable = true;
    devices = ["nodev"];
    useOSProber = true;
    efiSupport = true;

    #version = 2;
  };

  #FUCKING FISH DUDE
  documentation.man.generateCaches = false;
  programs.nix-ld.enable = true;
  # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  ##### DNS STUFF
  systemd.services."systemd-resolved".enable = false;
  # Enable the DNS stub resolver
  networking.resolvconf.enable = false;
  # Specify DNS servers for your system
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";
  # This is so windows doesn't shit the bed
  time.hardwareClockInLocalTime = true;
  #some sync issues before hyprland launches

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "trq";

  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.dconf.enable = true;
  services.gnome = {
    evolution-data-server.enable = false;
    gnome-keyring.enable = true; # keep keyring for secrets
    gnome-online-accounts.enable = false;
  };

  #sound stuff
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
    extraConfig = {
      "pipewire-pulse" = {
        "pulse.modules" = [
          {name = "module-switch-on-port-available";}
          {name = "module-switch-on-connect";}
        ];
      };
    };
  };

  #hardware.alsa.enablePersistence = true;

  users.users.berkerz = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "berkerz";
    extraGroups = [
      "networkmanager"
      "sound"
      "wheel"
    ];
    initialPassword = "1234";
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Fish
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch

    '';
    shellAliases = {
      mergio = "bash ~/dotfiles/scripts/mergio.sh";
      pushio = "bash ~/dotfiles/scripts/pushio.sh";
      updateio = "bash ~/dotfiles/scripts/updateio.sh";

      cod = "bash ~/dotfiles/scripts/codio.sh";
      rsh = "nix develop ~/dotfiles#rusticed --command fish";
      garbagio = "bash ~/dotfiles/scripts/garbagio.sh";
    };
  };

  #not sure why i need this but i see it around a lot
  programs.waybar = {
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    });
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.setPath.enable = true;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  ##############################################################
  #fix bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true;
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # this is for
  services.gvfs.enable = true;

  # Fonts here

  fonts.packages = with pkgs; [
    etBook
    font-awesome
    #  noto-fonts
    liberation_ttf
    #  noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    nerd-fonts.iosevka
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    subpixel = {
      lcdfilter = "default";
      rgba = "rgb";
    };

    defaultFonts = {
      monospace = [
        "Iosevka Nerd Font"
        "Noto Color Emoji"
        "Font Awesome"
      ];
      sansSerif = [
        "Liberation Sans"
        "Noto Color Emoji"
        "Font Awesome"
      ];
      serif = [
        "Liberation Serif"
        "Noto Color Emoji"
        "Font Awesome"
      ];
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/1 * * * * root ~/Projects/swast/ye.sh"
    ];
  };

  fonts.fontDir = {
    enable = true;
    decompressFonts = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      credential.helper = "libsecret";
    };
  };

  #for STEAM to work
  hardware.graphics.enable32Bit = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix = {
    package = pkgs.nix;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
    };
  };
}
