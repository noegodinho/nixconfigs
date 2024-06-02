{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
    };
  };

  outputs = {nixpkgs, nix-flatpak, ...}: {
    nixosConfigurations.milkyway = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
      ];
    };
  };
}
