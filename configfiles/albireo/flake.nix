{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, ...} @ inputs: let
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
            home-manager.users.${user} = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
          ./configuration.nix
      ];
    };
  };
}
