{ pkgs, ... }:
{
  # Man docs
  documentation = {
    enable = true;
    man = {
      enable = true;
      man-db.enable = false;
      mandoc.enable = true;
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

    # enable KDE PIM suite
    kde-pim = {
      enable = true;
      merkuro = true;
    };

    # Steam settings (installed in lutris)
    steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
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
      qemu # for VMs
      quickemu # for easy VM management
    ];

    # Exclude KDE & system packages
    plasma6.excludePackages = with pkgs; [
      khelpcenter
      kdePackages.kate
    ];
  };

  # In case I need docker
  # virtualisation.docker.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}