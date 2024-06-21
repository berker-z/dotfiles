{config, pkgs, ...}:

{
home.username = "berkerz";
home.homeDirectory = "/home/berkerz";

home.packages = with pkgs; [
firefox
neofetch
waybar
kitty
];



programs.waybar = {
  enable = true;
};

wayland.windowManager.hyprland = {

  enable = true;
    extraConfig = ''
      ${builtins.readFile ./hyprland.conf}
    '';
   };



  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Nordzy";
      package = pkgs.nordzy-icon-theme;
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 32;
    };
#    gtk2 = {
 #     configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
  #  };
  };

programs.kitty = {
  enable = true;
  settings = {
      font_size = "14.0";
      background = "#122440";
  };

};


home.stateVersion = "24.05";

programs.home-manager.enable = true;






}
