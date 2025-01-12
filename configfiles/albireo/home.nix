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
      htop
      btop
      lshw
      ffmpeg
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

      ghostty = {
        enable = true;
        package = pkgs.ghostty;
        enableZshIntegration = true;
        settings = {
          cursor-style = "block";
          shell-integration-features = "no-cursor";
          font-size = 10;
          theme = "Adventure";
          keybind = [
            "alt+b=new_split:left"
            "alt+n=new_split:right"
            "alt+v=new_split:down"
            "alt+m=new_split:up"  
            "ctrl+up=goto_split:top"
            "ctrl+down=goto_split:bottom"
            "ctrl+left=goto_split:left"
            "ctrl+right=goto_split:right"
            "ctrl+alt+left=resize_split:left,10"
            "ctrl+alt+right=resize_split:right,10"
            "ctrl+alt+up=resize_split:up,10"
            "ctrl+alt+down=resize_split:down,10"
            "ctrl+shift+alt+plus=toggle_split_zoom"
            "ctrl+n=new_window"                      
            "ctrl+t=new_tab"
            "ctrl+w=close_surface"
            "ctrl+page_up=scroll_page_lines:-15"
            "ctrl+page_down=scroll_page_lines:15"
            "ctrl+home=scroll_to_top"
            "ctrl+end=scroll_to_bottom"
          ];
        };
      };

      fzf = {
        enable = true;
        package = pkgs.fzf;
        enableZshIntegration = true;
      };

      atuin = {
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
