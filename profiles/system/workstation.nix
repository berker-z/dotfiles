{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../packages/graphical.nix
    ../../modules/system/display-manager.nix
    ../../modules/system/session-environment.nix
  ];

  services.hardware.openrgb.enable = true;
  hardware.i2c.enable = true;
  boot.kernelModules = ["i2c-dev"];

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.hyprlock = {};
  programs.dconf.enable = true;
  programs.fish.shellAliases = {
    mergio = "bash ~/dotfiles/scripts/mergio.sh";
    pushio = "bash ~/dotfiles/scripts/pushio.sh";
    updateio = "bash ~/dotfiles/scripts/updateio.sh";
    cod = "bash ~/dotfiles/scripts/codio.sh";
    rsh = "nix develop ~/dotfiles#rusticed --command fish";
    garbagio = "bash ~/dotfiles/scripts/garbagio.sh";
  };
  services.gnome = {
    evolution-data-server.enable = false;
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = false;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
    extraConfig."pipewire-pulse"."pulse.modules" = [
      {name = "module-switch-on-port-available";}
      {name = "module-switch-on-connect";}
    ];
  };

  programs.waybar.package =
    lib.mkIf (config.networking.hostName == "laptop")
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }));

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.setPath.enable = false;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true;
      Enable = "Source,Sink,Media,Socket";
    };
  };

  services.gvfs.enable = true;

  fonts.packages = with pkgs; [
    et-book
    font-awesome
    liberation_ttf
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    nerd-fonts.iosevka
  ];

  xdg.portal.enable = true;

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

  hardware.graphics.enable32Bit = true;
  programs.steam.enable = true;
}
