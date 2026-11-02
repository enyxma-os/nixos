{
  description = "Enyxma OS Core";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "git+https://codeberg.org/enyxma/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shell = {
      url = "git+https://codeberg.org/enyxma/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thornhill = {
      url = "git+https://codeberg.org/enyxma/thornhill";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    hyprland,
    shell,
    thornhill,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    formatter = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      pkgs.writeShellScriptBin "alejandra" ''
        if [ "$#" -eq 0 ]; then
          exec ${pkgs.alejandra}/bin/alejandra .
        else
          exec ${pkgs.alejandra}/bin/alejandra "$@"
        fi
      '');

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        name = "enyxma-core-dev";
        nativeBuildInputs = with pkgs; [
          git
          just
          deadnix
          statix
          alejandra
          shfmt
          gitleaks
        ];

        shellHook = ''
          mkdir -p .git/hooks
          cat << 'HOOK' > .git/hooks/pre-commit
          #!/usr/bin/env bash
          set -e

          # Guvenlik Taramasi - Gitleaks Sentinel
          if command -v gitleaks > /dev/null 2>&1; then
            gitleaks protect --staged --no-banner
          fi

          # Nix Statik Kod Analizi
          if command -v deadnix > /dev/null 2>&1; then
            deadnix --fail modules hosts
          fi

          if command -v statix > /dev/null 2>&1; then
            statix check
          fi

          if command -v alejandra > /dev/null 2>&1; then
            alejandra --check .
          fi
          HOOK
          chmod +x .git/hooks/pre-commit
        '';
      };
    });

    nixosModules = {
      default = ./modules;
      audio = ./modules/audio.nix;
      core = ./modules/core.nix;
      desktop = ./modules/desktop.nix;
      hardware = ./modules/hardware.nix;
      network = ./modules/network.nix;
      persistence = ./modules/persistence.nix;
      security = ./modules/security.nix;
      terminal = ./modules/terminal.nix;
    };

    nixosConfigurations = {
      test-enyxma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self hyprland shell thornhill;
        };
        modules = [
          self.nixosModules.default
          hyprland.nixosModules.default
          shell.nixosModules.default
          thornhill.nixosModules.default
          ./hosts/test-enyxma
        ];
      };
    };
  };
}
