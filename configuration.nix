# Compatibility aggregate for the two existing workstation hosts.
# New hosts should compose capability profiles explicitly from their host module.
{...}: {
  imports = [
    ./profiles/system/base.nix
    ./profiles/system/workstation.nix
    ./profiles/system/agent-host.nix
    ./modules/system/wireguard.nix
  ];
}
