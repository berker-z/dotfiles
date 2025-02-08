{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.url = "github:berker-z/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    sddm-sugar-candy-nix.url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland-qtutils,
    home-manager,
    nixos-hardware,
    sddm-sugar-candy-nix,
    zen-browser,
    ...
  }: let
    mkSystem = {
      hostName,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            sddm-sugar-candy-nix.nixosModules.default
            ./configuration.nix
            ./hosts/${hostName}/default.nix
            {
              nixpkgs.overlays = [
                sddm-sugar-candy-nix.overlays.default
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup123456";
              home-manager.users.berkerz = import ./home.nix;
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      nixos = mkSystem {
        hostName = "nixos";
        extraModules = [];
      };

      laptop = mkSystem {
        hostName = "laptop";
        extraModules = [
          nixos-hardware.nixosModules.asus-zephyrus-ga401
        ];
      };
    };
  };
}
