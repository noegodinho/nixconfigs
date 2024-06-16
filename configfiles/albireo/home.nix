{ config, pkgs, ... }:

{
  home.username = "albireo";
  home.homeDirectory = "/home/albireo";

  # enable numlock by default
  xsession.numlock.enable = true;

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

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
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
      p7zip
      xz
      rar
      file
      which
      tree
      gnused
      gawk
      zstd
      gnupg
      direnv
      gnutar
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

  # basic configuration of git, please change to your own
  # programs.git = {
  #   enable = true;
  #   userName = "Ryan Yin";
  #   userEmail = "xiaoyin_c@qq.com";
  # };

  programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = false;
        # oh-my-zsh = {
        #     enable = true;
        #     plugins = [
        #         "git" 
        #     ];
        # };

        zplug = {
          enable = true;
          plugins = [
            { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
            { name = "marlonrichert/zsh-autocomplete"; tags = [ depth:1 ]; }
            { name = "chisui/zsh-nix-shell"; }
          ];
        };

        shellAliases = {
          update="sudo nix-channel --update";
          rebuild="sudo nixos-rebuild switch";
          upgrade_all="sudo nixos-rebuild switch --upgrade-all";
          # update_rebuild="cd ~/zsh-autocomplete && git pull && cd - && cd ~/powerlevel10k && git pull && cd - && cd ~/zsh-nix-shell && git pull && cd - && sudo nixos-rebuild switch --upgrade-all";
        };

        # initExtra=''
        #   eval "$(atuin init zsh)"
        # '';
          # source ~/powerlevel10k/powerlevel10k.zsh-theme
          # source ~/.p10k.zsh
          # source ~/zsh-autocomplete/zsh-autocomplete.plugin.zsh
          # source ~/zsh-nix-shell/nix-shell.plugin.zsh
        # '';
      };

      atuin = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          auto_sync = true;
          sync_frequency = "15m";
        };
      };

      zellij = {
        enable = true;
        enableZshIntegration = true;
      };

      firefox.enable = true;
      java.enable = true;
      home-manager.enable = true;
  };

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