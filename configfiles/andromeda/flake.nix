{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      #url = "github:Svenum/Solaar-Flake/1.1.13"; # uncomment line for version 1.1.13
      #url = "github:Svenum/Solaar-Flake/main; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, solaar, ...} @ inputs: let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config = {allowUnfree = true;};
    };
    
    user = "andromeda";
    inherit (self) outputs;
    
    in {
      nixosConfigurations.laniakea = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs user outputs nixpkgs-unstable;};
      modules = [
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit unstable user system inputs outputs;};
            home-manager.users.${user} = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
          solaar.nixosModules.default
          ./configuration.nix
      ];
    };
  };
}