{
  description = "A very basic flake";

  inputs = 
  {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sddm-sugar-candy-nix = 
       {
       url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
       };
	home-manager = 
       {
       url = "github:nix-community/home-manager/master";
       inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, sddm-sugar-candy-nix, ... }: {
	nixosConfigurations = {
	nixos = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
    sddm-sugar-candy-nix.nixosModules.default
    ./configuration.nix
    ./hosts/nixos/default.nix
      {
        nixpkgs = {
          overlays = [
            sddm-sugar-candy-nix.overlays.default
          ];
        };
      }


home-manager.nixosModules.home-manager {
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;

home-manager.users.berkerz = import ./home.nix;
}
];
};

#I don't know how to make two of these without copying everything, there is probably a much more elegant way of doing it
	laptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
    sddm-sugar-candy-nix.nixosModules.default
    nixos-hardware.nixosModules.asus-zephyrus-ga401
    ./configuration.nix
    ./hosts/laptop/default.nix
      {
        nixpkgs = {
          overlays = [
            sddm-sugar-candy-nix.overlays.default
          ];
        };
      }
home-manager.nixosModules.home-manager {
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;

home-manager.users.berkerz = import ./home.nix;
}
];
};


};
};
}
