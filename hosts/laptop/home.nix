{config, pkgs, osConfig, ...}:


{

home.packages = with pkgs; [
  brave
  egl-wayland
];



#nvidia stuff for my laptop
wayland.windowManager.hyprland = {

    extraConfig = ''

      ${builtins.readFile ./hosts/${osConfig.networking.hostName}/hyp2.conf}
    '';
   };






}
