{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  address =
    if config.networking.hostName == "laptop"
    then "10.100.100.8/24"
    else if config.networking.hostName == "nixos"
    then "10.100.100.2/24"
    else throw "unknown host for wireguard ip assignment: ${config.networking.hostName}";
in {
  networking.firewall.allowedUDPPorts = [51820];

  networking.networkmanager.unmanaged = ["interface-name:wg0"];

  networking.wg-quick.interfaces.wg0 = {
    listenPort = 51820;
    address = [address];
    privateKeyFile = "/home/berkerz/.wg/client-private.key";

    peers = [
      {
        publicKey = "eS2tRnm1QAc/dtWw5JWLBwXLRV1VJ1i34YQkDfRuoDs=";
        endpoint = "132.145.49.251:51820";
        allowedIPs = ["0.0.0.0/0"];
        persistentKeepalive = 25;
      }
    ];

    table = "auto";
  };

  boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = true;
  networking.firewall.checkReversePath = false;

  systemd.services."wg-quick-wg0".wantedBy = lib.mkForce [];
}
