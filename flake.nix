{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    zen-browser.url = "github:berker-z/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    sddm-sugar-candy-nix.url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    yorha.url = "github:berker-z/yorha-flake";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland-qtutils,
    home-manager,
    nixos-hardware,
    sddm-sugar-candy-nix,
    zen-browser,
    nixvim,
    rust-overlay,
    yorha,
    ...
  }: let
    overlayedPkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        rust-overlay.overlays.default
      ];
    };

    mkSystem = {
      hostName,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            yorha.nixosModules.yorha-grub-theme
            sddm-sugar-candy-nix.nixosModules.default
            ./configuration.nix
            ./hosts/${hostName}/default.nix
            {
              nixpkgs.overlays = [
                sddm-sugar-candy-nix.overlays.default
                rust-overlay.overlays.default
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup123456789";
              home-manager.users.berkerz = import ./home.nix;
              home-manager.sharedModules = [
                nixvim.homeManagerModules.nixvim
              ];
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

    devShells = nixpkgs.lib.genAttrs ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };
        myBuildInputs = with pkgs; [
          (rust-bin.stable.latest.default.override {extensions = ["rust-src"];})
          cargo
          gcc
          clang
          pkg-config
          cmake

          expat
          fontconfig
          freetype
          freetype.dev
          libGL
          vulkan-loader

          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr
          wayland
          libxkbcommon
        ];
      in {
        rusticed = pkgs.mkShell {
          buildInputs = myBuildInputs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myBuildInputs;
        };
      }
    );
  };
}
