{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      #url = "github:Svenum/Solaar-Flake/1.1.13"; # uncomment line for version 1.1.13
      #url = "github:Svenum/Solaar-Flake/main; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
    };
  };

  outputs = {nixpkgs, solaar, nix-flatpak, ...}: {
    nixosConfigurations.milkyway = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
          solaar.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
      ];
    };
  };
}
