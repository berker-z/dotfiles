{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
      sddm-sugar-candy-nix = {
    url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";

  };

	home-manager = {
url = "github:nix-community/home-manager/master";
inputs.nixpkgs.follows = "nixpkgs";

};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sddm-sugar-candy-nix, ... }: {
	nixosConfigurations = {
	nixos = nixpkgs.lib.nixosSystem {
system = "x86_64-linux";
modules = [
sddm-sugar-candy-nix.nixosModules.default
./configuration.nix

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
