{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # --- Core System & Utils ---
    git
    gh # Restored
    wget
    fzf
    ripgrep
    tldr # tlrc
    nix-prefetch
    nix-prefetch-git
    unzip
    zip
    ntfs3g # Kept per user request
    libnotify
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk # Kept per user request

    # --- Networking & DNS ---
    networkmanagerapplet
    dig
    whois
    dnsutils
    wireguard-tools
    bluetuith # Restored

    # --- Audio & Video ---
    pavucontrol
    alsa-utils
    ffmpeg
    ffmpeg-full
    gst_all_1.gst-libav
    yt-dlp

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
    (rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
    })

    # Language Servers & Formatters
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.bash-language-server
    nodePackages.prettier
    lua-language-server
    rust-analyzer
    rustfmt
    nixfmt-rfc-style
    alejandra
    nixd
    nixpkgs-fmt
    stylua

    # Editors & Tools
    vscode
    nix-ld
    claude-code
    unityhub
    antigravity-fhs
    gemini-cli
    codex
    zed-editor

    # --- GUI Applications ---
    # Browsers
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Communication

    # Productivity
    obsidian
    zenity
    xfce.mousepad # Restored
    nautilus

    # Graphics & Media
    gimp
    imv
    qrencode

    # --- Hyprland & Wayland Ecosystem ---
    hyprpanel
    hyprpolkitagent
    egl-wayland
    grim
    slurp
    wl-clipboard
    cliphist # Replaces clipman
    satty

    # --- Theming (Qt/GTK) ---
    (nordic.overrideAttrs {
      dontCheckForBrokenSymlinks = true;
    })
    adwaita-qt6
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5.qtgraphicaleffects # Potentially redundant if not using SDDM effects
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.breeze-icons
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    kdePackages.qqc2-desktop-style
    kdePackages.qt6ct
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

  home-manager.users.berkerz.home.packages = with pkgs; [
    # --- Core UI ---
    waybar
    kitty
    wlogout
    swaylock-effects # Kept per user request

    # --- Hypr Ecosystem ---
    hyprlock
    hypridle
    hyprpaper
    hyprshot
    hyprpicker

    hyprland-qt-support

    # --- Everyday Tools ---
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
    feh
    libreoffice
    gnome-clocks
    kdePackages.kolourpaint
  ];
}
