{config, pkgs, osConfig, ...}:


{

home.packages = with pkgs; [
  brave
  egl-wayland
];



#nvidia stuff for my laptop
wayland.windowManager.hyprland = {

    extraConfig = ''

<<<<<<< HEAD
      ${builtins.readFile ./hyp2.conf}
    '';
   };

programs.kitty = {

settings = {
font_size = 12;
};
#  font.size = 12;

};
=======
      ${builtins.readFile ./hosts/${osConfig.networking.hostName}/hyp2.conf}
    '';
   };


>>>>>>> 6e88ab4d5e90085aa40607d29630730b15a5d16c




}
