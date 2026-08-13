{
  pkgs,
  repoSnapshot,
  wiredPublicKey,
  ...
}: {
  console.keyMap = "trq";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/WIRED_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/WIRED_BOOT";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  networking = {
    hostName = "wired";
    useDHCP = true;
    firewall.allowedTCPPorts = [22];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [wiredPublicKey];
    berkerz = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [wiredPublicKey];
    };
  };

  environment = {
    etc."wired/dotfiles".source = repoSnapshot;
    systemPackages = with pkgs; [
      git
      htop
      pciutils
      smartmontools
      tmux
      usbutils
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.enableRedistributableFirmware = true;
  security.sudo.wheelNeedsPassword = true;
  system.stateVersion = "26.05";
}
