# Compatibility aggregate for graphical agent hosts.
# Host home modules should compose the profiles they need explicitly.
{...}: {
  imports = [
    ./profiles/home/common.nix
    ./profiles/home/workstation.nix
    ./profiles/home/agents.nix
  ];
}
