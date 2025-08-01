{ pkgs, nixpkgs-unstable, ... }:
{
  # Man docs
  documentation = {
    doc.enable = true;
    dev.enable = true;
    nixos.enable = true;
    enable = true;
    man = {
      enable = true;
      man-db.enable = false;
      mandoc = {
        enable = true;
        package = nixpkgs-unstable.legacyPackages."${pkgs.system}".mandoc;
      };
      generateCaches = true;
    };
  };

  programs = {
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
    bcc.enable = true;

    # Some programs need SUID wrappers, can be configured further or are started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # For VMs
      qemu
      # For easy VM management
      quickemu
      # matlab
      # mesa
      # distrobox

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
    ];

    # Exclude KDE & system packages
    plasma6.excludePackages = with pkgs; [
      kdePackages.khelpcenter
      kdePackages.kate
    ];
  };

  virtualisation = {
    # In case I need docker
    # docker.enable = true;
    # Redirect USB devices to VM
    spiceUSBRedirection.enable = true;

    # podman = {
    #   enable = true;
    #   dockerCompat = true;
    # };
  };
}