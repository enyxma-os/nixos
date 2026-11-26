{
  description = "Enyxma OS starter configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    enyxma = {
      url = "git+https://codeberg.org/enyxma/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    enyxma-hyprland = {
      url = "git+https://codeberg.org/enyxma/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    enyxma-shell = {
      url = "git+https://codeberg.org/enyxma/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    enyxma,
    enyxma-hyprland,
    enyxma-shell,
    ...
  }: {
    nixosConfigurations.enyxma-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        enyxma.nixosModules.default
        enyxma-hyprland.nixosModules.default
        enyxma-shell.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}

