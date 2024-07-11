# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{


environment = {
  variables = {
XDG_SESSION_TYPE = "wayland";
};
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
      WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor rendering issue on wlr nvidia.
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox"; # Set default browser
    };
};
  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.systemd-boot.configurationLimit = 5;

boot.loader.efi = {
  efiSysMountPoint = "/boot";
  canTouchEfiVariables = true;
};
  boot.loader.grub = {
  enable = true;
  devices = [ "nodev" ];
  useOSProber = true;
  efiSupport = true;

  #version = 2;


  };



   # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";
  # This is so windows doesn't shit the bed
  time.hardwareClockInLocalTime = true;

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

  
  #sound stuff
  security.rtkit.enable = true;
  services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  wireplumber.enable = true;
};

#keyring stuff?
services.gnome.gnome-keyring.enable = true;

  users.users.berkerz = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "berkerz";
    extraGroups = [ "networkmanager" "sound"  "wheel" ];
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
        mergio = "bash ~/.dotfiles/scripts/mergio.sh";
        pushio = "bash ~/.dotfiles/scripts/pushio.sh";

  };

  };



  # Enable Hyprland
  programs.hyprland.enable = true;
  
  #sddm?
  services.displayManager.sddm =
  {
    enable = true;
    wayland.enable = true;
   sugarCandyNix = {
        enable = true; # This set SDDM's theme to "sddm-sugar-candy-nix".
        settings = {
          # Set your configuration options here.
          # Here is a simple example:
          Background = lib.cleanSource ./assets/laininv.jpg;
          ScreenWidth = 2560;
          ScreenHeight = 1440;
          FormPosition = "left";
          HaveFormBackground = true;
          PartialBlur = true;
          # ...
        };
      };

  };

  #not sure why i need this but i see it around a lot
  programs.waybar = { 
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
});
};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  git
  gh
  wget
  vscode
  xdg-desktop-portal-hyprland
  xdg-utils
  fzf
  tlrc
  obsidian
  neovim
  gimp
  networkmanagerapplet
  nix-prefetch
  nix-prefetch-git
  libsForQt5.qt5.qtgraphicaleffects # sddm doesn't work without this
  ];
  
  ##############################################################
  #fix bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; 
  };
  

# this is for trashcan i think
services.gvfs.enable = true;


  # Fonts here

fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    liberation_ttf
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "Iosevka"  ]; })

];


fonts.fontconfig = {
    enable = true;
    antialias = true;
        subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };


    defaultFonts = {
      monospace = [ "Iosevka Nerd Font" "Noto Color Emoji" "Font Awesome" ];
      sansSerif = ["Liberation Sans" "Noto Color Emoji" "Font Awesome"];
      serif = ["Liberation Serif" "Noto Color Emoji" "Font Awesome"];

    };
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
	package = pkgs.nixFlakes;
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
