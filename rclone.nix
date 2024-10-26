{config, pkgs, osConfig, ...}:


{

# RClone Google Drive service
systemd.services.rclone-gdrive-mount = {
  # Ensure the service starts after the network is up
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  requires = [ "network-online.target" ];

  # Service configuration
  serviceConfig = {
    Type = "simple";
    ExecStartPre = "/run/current-system/sw/bin/mkdir -p  /home/berkerz/gDrive"; # Creates folder if didn't exist
    ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode full drive: /home/berkerz/gDrive"; # Mounts
    ExecStop = "/run/current-system/sw/bin/fusermount -u /home/berkerz/gDrive"; # Dismounts
    Restart = "on-failure";
    RestartSec = "10s";
    User = "berkerz";
    Group = "users";
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};
    }