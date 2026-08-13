{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    marcel = {
      url = "github:berker-z/marcel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yorha.url = "github:berker-z/yorha-flake";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nixos-hardware,
    zen-browser,
    helium-browser,
    rust-overlay,
    yorha,
    codex-cli-nix,
    marcel,
    ...
  }: let
    stablePkgs = import nixpkgs-stable {
      system = "x86_64-linux";
    };

    overlays = [
      rust-overlay.overlays.default
      codex-cli-nix.overlays.default
      marcel.overlays.default
      (_final: _prev: {
        libreoffice = stablePkgs.libreoffice-still;
      })
    ];

    mkSystem = {
      hostName,
      primaryUser,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs primaryUser;};
        modules =
          [
            yorha.nixosModules.yorha-grub-theme
            ./hosts/${hostName}/default.nix
            {nixpkgs.overlays = overlays;}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.overwriteBackup = true; #THANK GOD FOR THIS
              home-manager.extraSpecialArgs = {inherit primaryUser;};
              home-manager.users.${primaryUser} = import ./hosts/${hostName}/home.nix;
              home-manager.sharedModules = [
                helium-browser.homeModules.default
              ];
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      nixos = mkSystem {
        hostName = "nixos";
        primaryUser = "berkerz";
        extraModules = [];
      };

      laptop = mkSystem {
        hostName = "laptop";
        primaryUser = "berkerz";
        extraModules = [
          nixos-hardware.nixosModules.asus-zephyrus-ga401
        ];
      };
    };

    devShells = nixpkgs.lib.genAttrs ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system overlays;
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
        libx11
        libxcursor
        libxi
        libxrandr
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
