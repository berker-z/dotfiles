{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    gh #think i need this for auth but i can't remember
    wget #self-ex
    vscode #
    xdg-desktop-portal #required - i guess not?
    xdg-desktop-portal-hyprland #required
    xdg-desktop-portal-gtk #i just fucking hate these idk i have all of them
    xdg-utils #required
    fzf
    tlrc #tldr
    obsidian #it ok
    gimp
    networkmanagerapplet
    nix-prefetch
    nix-prefetch-git
    libsForQt5.qt5.qtgraphicaleffects # sddm doesn't work without this
    ntfs3g #i think this was for trashcan or usb sticks i can't remember
    rclone #this *was* for gdrive but it's clunky i don't like it
    #sometihng
    godot_4
    libnotify
    libsForQt5.qt5.qtwayland
    egl-wayland
    jdk
    #
    nodejs
    yarn
    #
    #solana-cli
    #anchor
    alsa-utils

    (nordic.overrideAttrs {
      dontCheckForBrokenSymlinks = true;
    })

    #nix formatting stuff i think it's a little redundant but w.e
    alejandra
    nixd
    nixpkgs-fmt

    gnome-calendar
    pavucontrol
    inputs.zen-browser.packages.${pkgs.system}.default
    dex
    zenity
    thunderbird
    nemo-with-extensions
    nautilus
    btop
    inputs.hyprland-qtutils.packages.${pkgs.system}.default
    #i need these like once a year but it sucks when i don't have them
    dig
    whois
    dnsutils
    #
    yt-dlp
    ffmpeg
    wireguard-tools
    qrencode #it's cute and lightweight
    polkit_gnome
    #libresprite #asprite #this has a problem with cmake currently, should be fixd in a cpl weeks
    satty #ss tool, i'm gonna have to see how it works

    grim
    slurp
    wl-clipboard
    clipman
    beeper
    pulseaudio
    xfce.mousepad
    bluetuith
    imv
    #
    #stremio
    ags
    gcalcli

    #vim stuff
    # language servers
    nodePackages.typescript
    nodePackages."typescript-language-server"
    nodePackages.eslint
    nodePackages."bash-language-server"
    lua-language-server
    nodePackages.prettier
    rustfmt
    nixfmt-rfc-style
    stylua
    ripgrep

    # basic dev deps
    pkg-config
    openssl
    cmake
    gcc
    clang
    (rust-bin.stable.latest.default.override {
      extensions = ["rust-src"];
    })
    rust-analyzer
    nix-ld
    guvcview

    google-chrome
  ];
}
