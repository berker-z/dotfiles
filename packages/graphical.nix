{
  config,
  lib,
  pkgs,
  inputs,
  primaryUser,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # --- Core System & Utils ---
    openrgb-with-all-plugins
    git
    gh # Restored
    curl
    wget
    fzf
    ripgrep
    tldr # tlrc
    nix-prefetch
    nix-prefetch-git
    lm_sensors

    unzip
    zip
    ntfs3g # Kept per user request
    libnotify
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk # Kept per user request
    kdePackages.xdg-desktop-portal-kde
    ncdu
    asusctl

    # --- Networking & DNS ---
    networkmanagerapplet
    dig
    whois
    dnsutils
    wireguard-tools
    tailscale
    mosh
    bluetuith # Restored

    # --- Audio & Video ---
    pavucontrol
    alsa-utils
    wiremix
    ffmpeg
    ffmpeg-full
    gst_all_1.gst-libav
    # Temporarily disabled: current nixpkgs pulls in deno -> rusty-v8 here,
    # and the V8 build is failing under clang on this revision.
    # yt-dlp

    # --- Development ---
    # Languages & Compilers
    nodejs
    bun
    gcc
    clang
    cmake
    pkg-config
    openssl
    jdk
    # Rust
    (rust-bin.stable.latest.default.override {extensions = ["rust-src"];})
    rust-analyzer
    rustfmt
    sqlite

    # Language Servers & Formatters
    typescript
    typescript-language-server
    eslint
    bash-language-server
    prettier
    lua-language-server
    nixfmt
    alejandra
    nixd
    nixpkgs-fmt
    stylua
    # API / Proto tooling
    protobuf
    grpcurl
    supabase-cli

    # Editors & Tools
    micro

    nix-ld

    zed-editor
    claude-code
    hermes-agent-full
    hermes-agent-desktop

    # --- GUI Applications ---
    # Browsers
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Communication

    # Productivity
    obsidian
    zenity
    mousepad # Restored
    marcel
    nautilus

    # Graphics & Media
    gimp
    idescriptor
    imv
    qrencode

    # --- Hyprland & Wayland Ecosystem ---
    hyprpolkitagent
    egl-wayland
    grim
    slurp
    wtype
    wlrctl
    wl-clipboard
    cliphist # Replaces clipman
    satty

    # --- Theming (Qt/GTK) ---
    (whitesur-gtk-theme.override {
      colorVariants = ["dark"];
      opacityVariants = ["normal"];
      themeVariants = ["default"];
      schemeVariants = ["nord"];
    })
    qt5.qtwayland
    qt5.qtgraphicaleffects # Potentially redundant if not using SDDM effects
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style
    inputs.hyprland-qtutils.packages.${pkgs.stdenv.hostPlatform.system}.default
    utterly-nord-plasma

    # --- Misc / Other ---
    godot_4
    dex
    btop
    gcalcli
    sops
    age
  ];

  home-manager.users.${primaryUser}.home.packages = with pkgs;
    [
      # --- Core UI ---
      kitty
      wlogout

      # --- Hypr Ecosystem ---
      hyprlock
      hypridle
      hyprpaper
      hyprshot
      hyprpicker

      hyprland-qt-support

      # --- Everyday Tools ---
      slack
      playerctl
      spotify
      bluez
      blueman
      foliate
      vivaldi
      vivaldi-ffmpeg-codecs
      brave
      vlc
      deluge
      steam
      appflowy
      telegram-desktop
      loupe
      kdePackages.dolphin
      kdePackages.kde-cli-tools
      kdePackages.kded
      kdePackages.kio
      kdePackages.kio-extras
      kdePackages.kservice
      kdePackages.ffmpegthumbs
      libreoffice
      gnome-clocks
      kdePackages.kolourpaint
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    ++ lib.optionals (config.networking.hostName == "laptop") [
      pkgs.waybar
    ];
}
