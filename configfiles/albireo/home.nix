{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "albireo";
  home.homeDirectory = "/home/albireo";

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
      oh-my-zsh
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

  # programs.zsh = {
  #      enable = true;
  #      autosuggestion.enable = true;
  #      syntaxHighlighting.enable = true;
  #      enableCompletion = false;
  #      oh-my-zsh = {
  #          enable = true;
  #          plugins = [
  #               "git" 
  #          ];
  #      };
  # };

  # programs.zellij.enable = true;
  # programs.atuin.enable = true;
  # programs.firefox.enable = true;
  # programs.java.enable = true;

  # programs.bash = {
  #   enable = true;
  #   enableCompletion = true;
  #   # TODO add your custom bashrc here
  #   bashrcExtra = ''
  #     export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
  #   '';
  # 
  #   # set some aliases, feel free to add more or remove some
  #   shellAliases = {
  #     k = "kubectl";
  #     urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
  #     urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  #   };
  # };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}