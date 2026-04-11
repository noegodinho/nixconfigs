{ inputs, pkgs, nixpkgs-unstable, ... }:
let
  papercutClient = pkgs.callPackage ./papercut.nix { };
in
{
  # Man docs
  documentation = {
    enable = true;
    doc.enable = true;
    dev.enable = true;
    nixos.enable = true;
    
    man = {
      enable = true;
      man-db.enable = false;
      
      mandoc = {
        enable = true;
        package = nixpkgs-unstable.legacyPackages."${pkgs.stdenv.hostPlatform.system}".mandoc;
      };
      
      generateCaches = true;
    };
  };

  # Enable the XDG Desktop Portal for Hyprland
  # This is needed for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;

    # Add the GTK portal as a fallback for apps that don't support Hyprland's native one
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # to remove in the future when no KDE exists
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        # Ignore KDE's portal completely when in Hyprland
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };

  # To remove in the future when there is no KDE
  environment.sessionVariables = {
    # Tells the portal system strictly what environment we are in
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  programs = {
    # Enable Hyprland window manager
    hyprland = {
      enable = true;
      
      # Use the package from the flake input
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # Enable zsh
    zsh.enable = true;

    # Allows dynamically linked executables to be run on nixos
    # Only possible to use x86_64 executables
    nix-ld.enable = true;
    # nix-ld.libraries = with pkgs; [
      # Avoid using conda-shell and having direct access to conda -> useful for vscodium
      # python312Packages.conda
    # ];

    # Steam settings (installed in lutris)
    steam = {
      enable = true;
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = false;
      # Open ports in the firewall for Source Dedicated Server
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extest.enable = true;
      protontricks.enable = true;
      
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    # BPF-based Linux IO analysis, networking, monitoring, and more
    # bcc.enable = true;

    # Some programs need SUID wrappers, can be configured further or are started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  nixpkgs.overlays = [
    (final: prev: {
      # Alias the removed 'glxinfo' package to 'mesa-demos'
      glxinfo = prev.mesa-demos;
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    systemPackages = with pkgs; [
      # For VMs
      qemu
      # For easy VM management
      quickemu

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

      nixpkgs-unstable.legacyPackages."${pkgs.stdenv.hostPlatform.system}".libinput

      papercutClient
    ];

    # Exclude KDE & system packages
    plasma6.excludePackages = with pkgs; [
      kdePackages.khelpcenter
      kdePackages.kate
    ];
  };

  virtualisation = {
    # In case I need docker
    docker.enable = true;
    # Redirect USB devices to VM
    spiceUSBRedirection.enable = true;

    oci-containers = {
      backend = "docker";
      
      containers.vert = {
        image = "ghcr.io/vert-sh/vert:latest";
        
        ports = [
          "3000:80" # Maps port 80 in the container to 3000 on your host
        ];
        
        environment = {
          # You can adjust these environment variables based on your needs
          PUB_HOSTNAME = "localhost:3000"; # Change to your actual domain if reverse proxying
          PUB_ENV = "production";
          PUB_DISABLE_ALL_EXTERNAL_REQUESTS = "false";
          
          # Optional: If you also self-host 'vertd' for video conversions
          PUB_VERTD_URL = "http://localhost:24153"; 
        };
        
        # Optional: wait for network to be up before starting
        dependsOn = [ "vertd" ]; 
      };

      containers.vertd = {
        image = "ghcr.io/vert-sh/vertd:latest";
        ports = [ 
          "3001:3000" 
        ];        
      };
    };
  };
}