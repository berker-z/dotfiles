{config, pkgs, osConfig, ...}:


{

imports = [

    ./rclone.nix

  ];
systemd.services.rclone-gdrive-sync = {
  # Ensure the service starts after the network is up
  wantedBy = [ "multi-user.target" ];
  after = [ "network-online.target" ];
  requires = [ "network-online.target" ];

  # Service configuration
  serviceConfig = {
    Type = "oneshot";
    ExecStartPre = "/run/current-system/sw/bin/mkdir -p /home/berkerz/gDrive"; # Creates folder if it doesn't exist
    ExecStart = "${pkgs.rclone}/bin/rclone bisync --resync --resilient drive: /home/berkerz/gDrive"; # Syncs
    User = "berkerz";
    Group = "users";
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};

systemd.paths."rclone-gdrive-sync.path" = {
  wantedBy = [ "multi-user.target" ];
  pathConfig = {
    PathModified = "/home/berkerz/gDrive";  # Trigger sync when files change
    Unit = "rclone-notif.service";   # This points to the sync service
  };

};

systemd.services.rclone-notif = {

  serviceConfig = {
    Type = "oneshot";  # Run once when triggered
    #ExecStart = "/run/current-system/sw/bin/echo 'Change detected in gDrive: You made a change in /home/berkerz/gDrive!' | systemd-cat";  # Log message to systemd journal
    ExecStart = "/run/current-system/sw/bin/rclone bisync --recover drive: /home/berkerz/gDrive";
    User = "berkerz";  # Run as your user
    Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};

# Add a timer to run the sync service periodically
systemd.timers.rclone-gdrive-sync = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnBootSec = "1m";
    OnUnitActiveSec = "1m";
    Unit = "rclone-notif.service";
  };
};

}