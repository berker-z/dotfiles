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
      inputs.rust-overlay.follows = "rust-overlay";
    };
    hyprhands = {
      url = "github:berker-z/hyprhands";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:herdrdev/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    yorha.url = "github:berker-z/yorha-flake";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    obsidian-extensions = {
      url = "github:karaolidis/nix-obsidian-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inputs.obsidian-extensions.overlays.default
      (final: prev: {
        codex = prev.codex.override {
          stdenv =
            final.stdenv
            // {
              inherit (final.stdenv.hostPlatform) isDarwin isLinux;
            };
        };

        hermes-agent-full =
          inputs.hermes-agent.packages.${final.stdenv.hostPlatform.system}.minimal.override
          {
            stdenv =
              final.stdenv
              // {
                inherit (final.stdenv.hostPlatform) isDarwin isLinux;
              };
            extraDependencyGroups =
              [
                "anthropic"
                "azure-identity"
                "bedrock"
                "daytona"
                "dingtalk"
                "edge-tts"
                "exa"
                "fal"
                "feishu"
                "firecrawl"
                "hindsight"
                "honcho"
                "messaging"
                "modal"
                "parallel-web"
                "tts-premium"
                "vercel"
                "voice"
              ]
              ++ final.lib.optionals final.stdenv.hostPlatform.isLinux ["matrix"];
          };
        hermes-agent-desktop = let
          upstreamNpmLib = final.hermes-agent-full.hermesNpmLib;
          hermesNpmLib =
            upstreamNpmLib
            // {
              buildNpmPackage = attrs:
                upstreamNpmLib.buildNpmPackage (
                  attrs
                  // {
                    # The desktop typecheck imports a root-level test fixture,
                    # which upstream's filtered source currently omits.
                    dirs = attrs.dirs ++ final.lib.optional (builtins.elem "apps/desktop" attrs.dirs) "tests/fixtures";
                  }
                );
            };
        in
          final.callPackage "${inputs.hermes-agent}/nix/desktop.nix" {
            inherit hermesNpmLib;
            hermesAgent = final.hermes-agent-full;
          };
      })
      marcel.overlays.default
      (final: _prev: {
        hyprhands = inputs.hyprhands.packages.${final.stdenv.hostPlatform.system}.default;
      })
      (_final: _prev: {
        libreoffice = stablePkgs.libreoffice-still;
      })
    ];

    wiredPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN38WfMRFyT3mTQDddh+8i88V6/v0LcIplM9mnRbrQF nixos-to-wired";

    repoSnapshot = builtins.path {
      path = self.outPath;
      name = "wired-dotfiles-snapshot";
      filter = path: type: let
        name = builtins.baseNameOf path;
      in
        type
        != "symlink"
        && name != ".git"
        && name != ".direnv"
        && name != "result"
        && name != "secrets.nix"
        && !(nixpkgs.lib.hasSuffix ".key" name)
        && !(nixpkgs.lib.hasSuffix ".pem" name);
    };

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

    wiredBootstrap = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit repoSnapshot wiredPublicKey;};
      modules = [./installer/wired-bootstrap.nix];
    };

    wiredInstaller = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit repoSnapshot wiredBootstrap wiredPublicKey;};
      modules = [./installer/wired-installer.nix];
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

      wired = mkSystem {
        hostName = "wired";
        primaryUser = "berkerz";
        extraModules = [];
      };
    };

    packages.x86_64-linux = {
      wired-bootstrap = wiredBootstrap.config.system.build.toplevel;
      wired-installer = wiredInstaller.config.system.build.isoImage;
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
