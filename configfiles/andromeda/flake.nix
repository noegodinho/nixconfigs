{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      # url = "github:Svenum/Solaar-Flake/1.1.13"; # uncomment line for version 1.1.13
      # url = "github:Svenum/Solaar-Flake/main; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };

    weathr.url = "github:Veirt/weathr";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    thyx.url = "github:rccyx/thyx";

    # nix-vscode-extensions = {
    #   url = "github:nix-community/nix-vscode-extensions";
    # };
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, solaar, weathr, hyprland, thyx, ...} @ inputs: let #, nix-matlab, nix-vscode-extensions, ...} @ inputs: let
    stdenv.hostPlatform.system = "x86_64-linux";
    
    unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
    };
    
    user = "andromeda";
    inherit (self) outputs;
    
  in {
    nixosConfigurations.laniakea = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs user outputs nixpkgs-unstable;
      };

      modules = [
        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit unstable user stdenv inputs outputs;
          };
          home-manager.users.${user} = import ./home.nix;
        }
        solaar.nixosModules.default
        thyx.nixosModules.default
        {
          services.displayManager.sddm.thyx.enable = true;
          services.displayManager.sddm.wayland.enable = true;
        }
        ./configuration.nix
      ];
    };
  };
}
