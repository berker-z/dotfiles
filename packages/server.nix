{
  pkgs,
  inputs,
  ...
}: {
  # Deliberately independent from graphical.nix. This is the conservative
  # starting set for a remotely administered agent/media host; it does not
  # inherit workstation applications, desktop tooling, or game packages.
  environment.systemPackages = with pkgs; [
    curl
    wget
    ripgrep
    fzf
    tmux
    mosh
    btop
    ncdu
    unzip
    zip

    wireguard-tools
    sops
    age

    claude-code
    hermes-agent-full
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
