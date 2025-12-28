{config, pkgs, osConfig, ...}:





{

  imports = [

#    ./modules
 #   ./hosts/${osConfig.networking.hostName}/home.nix

  ];

home.packages = with pkgs; [

];

programs.kitty = {

settings = {
font_size = 14;
};
};







}
