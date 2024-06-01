{ config, lib, pkgs, ... }:

{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;  

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "pt";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };

  services.flatpak.packages = [
    # { appId = "com.brave.Browser"; origin = "flathub";  }
  ];

  programs.zsh = {
       enable = true;
       autosuggestions.enable = true;
       syntaxHighlighting.enable = true;
       enableCompletion = false;
       ohMyZsh = {
           enable = true;
           plugins = [
                "git" 
           ];
       };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.albireo = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Albireo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
      gcc
      gdb
      gnumake
      valgrind
      wget
      usbutils
      fh
      unzip
      zip
      gzip
      rar
      unrar
      gnutar
      jre8
      bat
      atuin
      fzf
      htop
      btop
      undervolt
      lm_sensors
      fusuma
      lshw
      ffmpeg
      neovim
      zellij
      kate
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "albireo";

  # Install firefox.
  programs.firefox.enable = true;
  programs.hyprland.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
  ];

  programs.java.enable = true; 

  # why not work?
  # programs.steam.package = pkgs.steam.override {
  #    withPrimus = true;
  #    withJava = true;
  #    extraPkgs = pkgs: [ "bumblebee" "glxinfo" ];
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
