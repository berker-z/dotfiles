{primaryUser, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      AllowUsers = [primaryUser];
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${primaryUser}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3bTL25e2RZu0O/HjoYTv1qJvj/Yx1+Wqwo2oGAYDMJ moshi"
  ];

  # Treat the encrypted tailnet as the private LAN. This also covers SSH and
  # Mosh without exposing either service on a physical or public interface.
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
