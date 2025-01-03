{ pkgs, ... }:
{
  home.username = "albireo";
  home.homeDirectory = "/home/albireo";

  # enable numlock by default
  xsession.numlock.enable = true;

  # enable configuration of fonts
  fonts.fontconfig.enable = true;

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
      git
      gcc
      gnumake
      cmake
      wget
      usbutils
      which
      bat
      atuin
      htop
      btop
      lshw
      ffmpeg
      zellij
      konsave
      lm_sensors

      (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  programs = {
      git = {
        enable = true;
        userName = "noegodinho";
        userEmail = "noe.godinho@protonmail.com";
      };
      
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = false;

        zplug = {
          enable = true;
          plugins = [
            { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
            { name = "marlonrichert/zsh-autocomplete"; tags = [ "depth:1" ]; }
            { name = "chisui/zsh-nix-shell"; }
          ];
        };

        shellAliases = {
          flake_update="sudo nix flake update --flake ~/nixconfigs/configfiles/albireo";
          rebuild="sudo nixos-rebuild switch --upgrade-all --flake ~/nixconfigs/configfiles/albireo/#milkyway -v";
          update_all="flake_update && rebuild && nix-collect-garbage -d";
        };

        initExtra=''
          source ~/.p10k.zsh
        '';
      };

      atuin = {
        enable = true;
        enableZshIntegration = true;
      };

      zellij = {
        enable = true;
        enableZshIntegration = true;
      };

      firefox.enable = true;
      java.enable = true;
      home-manager.enable = true;
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };

  #Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
