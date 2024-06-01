{ config, lib, pkgs, ... }:

{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "albireo";

  # Enable CUPS to print documents.
  services.printing.enable = false;

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

  # Install firefox.
  programs.firefox.enable = true;
  programs.java.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
  ];

  services.flatpak.packages = [
    # { appId = "com.brave.Browser"; origin = "flathub";  }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
