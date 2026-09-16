{
  pkgs,
  primaryUser,
  ...
}: {
  boot.loader.efi = {
    efiSysMountPoint = "/boot";
    canTouchEfiVariables = true;
  };
  boot.loader.timeout = 2;
  boot.loader.grub = {
    enable = true;
    devices = ["nodev"];
    useOSProber = true;
    efiSupport = true;
  };

  documentation.man.cache.enable = false;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [libcap];
  };

  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  time = {
    timeZone = "Europe/Istanbul";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };
  console.keyMap = "trq";

  users.users.${primaryUser} = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = primaryUser;
    extraGroups = [
      "networkmanager"
      "sound"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch
    '';
    shellAliases = {
      otto = "mosh otto -- tmux new -A -s hermes";
      otto-ssh = "ssh otto -t 'tmux new -A -s hermes'";
    };
  };

  systemd.user.settings.Manager.DefaultEnvironment = ''"PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"'';

  services.dbus.enable = true;
  networking.firewall.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config.credential.helper = "libsecret";
  };

  system.stateVersion = "24.05";

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
      extra-substituters = ["https://marcel-rs.cachix.org"];
      extra-trusted-public-keys = [
        "marcel-rs.cachix.org-1:ae3s4u7pctzohvoTn8DWdMnRCrLEg1u32OIjfQ7p0VY="
      ];
      http-connections = 8;
      keep-derivations = false;
      keep-outputs = false;
      max-substitution-jobs = 4;
      stalled-download-timeout = 600;

      # Every host here is also in use while it rebuilds, and several inputs
      # (hyprhands, herdr, hermes) follow this flake's nixpkgs, so a nixpkgs
      # bump compiles them from source with no cache to fall back on. Nix's
      # defaults run one derivation per core, each using every core, which on
      # a swapless 32 GiB desktop is a freeze. One derivation at a time, with
      # a few compiler jobs, keeps a rebuild slow rather than fatal. Cargo
      # honours `cores` through NIX_BUILD_CORES.
      max-jobs = 1;
      cores = 4;
    };
  };

  # Belt and braces for the above: compiler and linker processes can exceed
  # their advertised job count. Cap the daemon's cgroup so an overshoot fails
  # the build rather than the desktop. The percentage scales with each host's
  # RAM. Low weights leave the foreground session responsive during a build.
  systemd.services.nix-daemon.serviceConfig = {
    MemoryMax = "50%";
    CPUWeight = 25;
    IOWeight = 25;
  };
}
