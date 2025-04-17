{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      # url = "github:Svenum/Solaar-Flake/1.1.13"; # uncomment line for version 1.1.13
      # url = "github:Svenum/Solaar-Flake/main; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-vscode-extensions = {
    #   url = "github:nix-community/nix-vscode-extensions";
    # };

    # nix-matlab = {
    #   url = "gitlab:doronbehar/nix-matlab";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, home-manager, solaar, ...} @ inputs: let #, nix-matlab, nix-vscode-extensions, ...} @ inputs: let
    system = "x86_64-linux";
    
    unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
    };

    # flake-overlays = [
    #   nix-matlab.overlay
    # ];
    
    user = "andromeda";
    inherit (self) outputs;
    
  in {
    devShells.${system}.default = nixpkgs.mkShell {
      buildInputs = with nixpkgs; [
        # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
        gst_all_1.gstreamer
        # Common plugins like "filesrc" to combine within e.g. gst-launch
        gst_all_1.gst-plugins-base
        # Specialized plugins separated by quality
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        # Plugins to reuse ffmpeg to play almost every video format
        gst_all_1.gst-libav
        # Support the Video Audio (Hardware) Acceleration API
        gst_all_1.gst-vaapi
        #...
      ];
    };

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
            inherit unstable user system inputs outputs;
          };
          home-manager.users.${user} = import ./home.nix;
        }
        solaar.nixosModules.default
        ./configuration.nix
        # (import ./configuration.nix flake-overlays)
      ];
    };
  };
}
