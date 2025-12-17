{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    home-manager,
    nixos-hardware,
    zen-browser,
    nixvim,
    rust-overlay,
    yorha,
    stylix,
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
            stylix.nixosModules.stylix
            yorha.nixosModules.yorha-grub-theme
            ./configuration.nix
            ./hosts/${hostName}/default.nix
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
              ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.overwriteBackup = true; #THANK GOD FOR THIS
              home-manager.users.berkerz = import ./home.nix;
              home-manager.sharedModules = [
                nixvim.homeModules.nixvim
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

    devShells = nixpkgs.lib.genAttrs ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
        ];
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
    });
  };
}
