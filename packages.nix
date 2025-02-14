{
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
    xdg-desktop-portal-gtk # Uncomment this
    xdg-utils #required
    fzf
    tlrc
    obsidian
    neovim
    gimp
    networkmanagerapplet
    nix-prefetch
    nix-prefetch-git
    libsForQt5.qt5.qtgraphicaleffects # sddm doesn't work without this
    ntfs3g
    rclone

    godot_4
    libnotify
    libsForQt5.qt5.qtwayland
    egl-wayland
    gfn-electron
    jdk
    #
    nodejs
    yarn
    code-cursor
    #
    solana-cli
    anchor
    alsa-utils
    libsForQt5.kontact
    (nordic.overrideAttrs {
      dontCheckForBrokenSymlinks = true;
    })

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

    dig
    whois
    dnsutils
  ];
}
