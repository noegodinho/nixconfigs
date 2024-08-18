{ lib, config, pkgs, unstable, user, system, ... }:

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
      gdb
      gnumake
      cmake
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

      (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = false;

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

      vscode = {
        enable = true;
        package = unstable.vscodium;

        # mutableExtensionsDir = false;
        # enableUpdateCheck = false;
        # enableExtensionUpdateCheck = false;

        extensions = (with pkgs.vscode-extensions; [
          bbenoist.nix
          james-yu.latex-workshop
          mechatroner.rainbow-csv
          ms-python.isort
          ms-python.python
          ms-python.vscode-pylance
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.makefile-tools
          twxs.cmake
          valentjn.vscode-ltex
          #visualstudioexptteam.vscodeintellicode
          yzhang.markdown-all-in-one
         ]) ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
                 name = "better-cpp-syntax";
                 publisher = "jeff-hykin";
                 version = "1.17.2";
                 sha256 = "p3SKu9FbtuP6in2dSsr5a0aB5W+YNQ0kMgMJoDYrhcU=";
            }
            {
                 name = "languague-renpy";
                 publisher = "luquedaniel";
                 version = "2.3.6";
                 sha256 = "ubMtLCIs3C8UBrXr1vr3Kqm2K3B8wNlm/THftVyIDug=";
            }
            {
                 name = "doxdocgen";
                 publisher = "cschlosser";
                 version = "1.4.0";
                 sha256 = "InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
            } 
            {
                 name = "latex-utilities";
                 publisher = "tecosaur";
                 version = "0.4.14";
                 sha256 = "GsbHzFcN56UbcaqFN9s+6u/KjUBn8tmks2ihK0pg3Ds=";
            }       
         ]);
         
         userSettings = {
            "files.autoSave" = "afterDelay";
            "terminal.integrated.fontFamily" = "MesloLGS NF";
            "editor.wordWrap" = "on";
         };
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
