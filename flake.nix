{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	home-manager = {
url = "github:nix-community/home-manager/master";
inputs.nixpkgs.follows = "nixpkgs";
};
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
	nixosConfigurations = {
	nixos = nixpkgs.lib.nixosSystem {
system = "x86_64-linux";
modules = [
./configuration.nix

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
