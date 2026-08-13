{
  lib,
  modulesPath,
  pkgs,
  repoSnapshot,
  wiredBootstrap,
  wiredPublicKey,
  ...
}: let
  installScript = pkgs.writeShellApplication {
    name = "wired-install";
    runtimeInputs = with pkgs; [
      coreutils
      dosfstools
      e2fsprogs
      gawk
      gptfdisk
      nixos-install-tools
      parted
      systemd
      util-linux
    ];
    text =
      builtins.replaceStrings
      ["@bootstrapSystem@"]
      ["${wiredBootstrap.config.system.build.toplevel}"]
      (builtins.readFile ./wired-install.sh);
  };
in {
  console.keyMap = "trq";

  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  networking = {
    hostName = "wired-installer";
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

  users.users.root.openssh.authorizedKeys.keys = [
    wiredPublicKey
  ];

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  environment = {
    etc = {
      "wired/dotfiles".source = repoSnapshot;
      "wired/README.txt".text = ''
        WIRED OFFLINE INSTALLER

        1. Confirm that this USB was booted in UEFI mode:
             test -d /sys/firmware/efi && echo UEFI
        2. Start the guarded installer:
             sudo wired-install
        3. Read every target-disk line before typing the ERASE confirmation.

        The source snapshot is available read-only at /etc/wired/dotfiles.
        No installation or disk modification happens automatically.
      '';
    };
    systemPackages = with pkgs; [
      cryptsetup
      efibootmgr
      ethtool
      hdparm
      installScript
      lsof
      lvm2
      mdadm
      pciutils
      smartmontools
      tmux
      usbutils
    ];
  };

  isoImage.storeContents = [
    wiredBootstrap.config.system.build.toplevel
  ];

  systemd.services."serial-getty@ttyS0".enable = lib.mkForce false;
}
