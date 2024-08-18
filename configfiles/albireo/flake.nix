{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
    };
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, ...} @ inputs: let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config = {allowUnfree = true;};
    };
    
    user = "albireo";
    inherit (self) outputs;
    
    in {
      nixosConfigurations.milkyway = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs user outputs;};
      modules = [
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit unstable user system inputs outputs;};
            home-manager.users.albireo = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
      ];
    };
  };
}
