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
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixpkgs-stable,
    home-manager,
    nixos-hardware,
    zen-browser,
    helium-browser,
    nixvim,
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
      (final: _prev: {
        libreoffice = stablePkgs.libreoffice-still;
      })
      # FIXME: drop once nixos-unstable picks up nixpkgs PR #549253.
      # nixpkgs bumped glaze 7.9.1 -> 8.0.0, but Hyprland 0.56.1 asks CMake for
      # `glaze 7...<8`; the version check fails, CMake falls back to cloning
      # glaze v7.2.0 with FetchContent, and there is no git/network in the
      # sandbox. Same patch that upstream merged to master.
      (_final: prev: {
        hyprland = prev.hyprland.overrideAttrs (old: {
          postPatch =
            ''
              substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
                --replace-fail "glaze 7...<8" "glaze"
            ''
            + old.postPatch;
        });
      })
    ];

    overlayedPkgs = import nixpkgs {
      system = "x86_64-linux";
      inherit overlays;
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
            ./configuration.nix
            ./hosts/${hostName}/default.nix
            {nixpkgs.overlays = overlays;}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.overwriteBackup = true; #THANK GOD FOR THIS
              home-manager.users.berkerz = import ./home.nix;
              home-manager.sharedModules = [
                helium-browser.homeModules.default
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
