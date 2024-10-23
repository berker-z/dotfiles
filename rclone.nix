{config, pkgs, osConfig, ...}:


{
systemd.services.rclone-gdrive-mount = {
  description = "rclone GDRIVE mount";
  # Ensure the service starts after the network is up
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  requires = [ "network-online.target" ];

  # Service configuration
  serviceConfig = {
    Type = "simple";
    ExecStartPre = "/run/current-system/sw/bin/mkdir -p /home/berkerz/gDrive"; # Creates folder if didn't exist
    ExecStart = "${pkgs.rclone}/bin/rclone mount drive: /home/berkerz/gDrive --vfs-cache-mode writes --dir-cache-time 72h --poll-interval 10s --vfs-cache-max-age 72h"; # Mounts with improved caching
    ExecStop = "/run/current-system/sw/bin/fusermount -u /home/berkerz/gDrive"; # Dismounts
    Restart = "on-failure";
    RestartSec = "10s";
    User = "berkerz";
    Group = "users";
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};
}