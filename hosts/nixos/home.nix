{config, pkgs, osConfig, ...}:





{

  imports = [

#    ./modules
 #   ./hosts/${osConfig.networking.hostName}/home.nix

  ];

home.packages = with pkgs; [
brave
evolution
];


programs.kitty = {

settings = {
font_size = 16;
};
};







}
