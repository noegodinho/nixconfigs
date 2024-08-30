{ config, pkgs, unstable, system, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "c43d9089df96cf8aca157762ed0e2ddca9fcd71e";
    }))
    .extensions
    .${system};
in {
  home.username = "pleiades";
  home.homeDirectory = "/home/pleiades";

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

  # enable configuration of fonts
  fonts.fontconfig.enable = true;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    linux-manual
    man-pages
    man-pages-posix
    git
    gcc
    gdb
    gnumake
    cmake
    valgrind
    wget
    usbutils
    pciutils
    gparted
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
    ffmpeg
    bat
    atuin
    fzf
    htop
    btop
    nvtopPackages.full
    undervolt
    lm_sensors
    psensor
    stress
    linuxKernel.packages.linux_zen.cpupower
    linuxKernel.packages.linux_zen.turbostat
    smartmontools
    neofetch
    testdisk-qt
    fusuma
    lshw
    glxinfo
    micromamba
    
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.pt_PT
    hunspellDicts.en_GB-ise

    neovim
    zellij
    keepass
    thunderbird
    ktorrent
    unstable.brave
    unstable.telegram-desktop
    skypeforlinux
    unstable.zotero
    slack
    discord 
    # discordo # may try later
    pympress 
    unstable.maestral
    veracrypt
    duplicati # http://localhost:8200/
    gphoto2
    vlc
    pcsxr
    unstable.itch
    rare
    renpy
    texliveFull
    todo-txt-cli
    ardour
    lmms
    musescore
    yt-dlp
    qalculate-qt
    # unstable.kdePackages.kamoso

    (nerdfonts.override { fonts = [ "Meslo" ]; })

    wineWowPackages.waylandFull # wineWowPackages.full
    winetricks
    yabridge
    protonup-qt

    (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
        ];

        extraLibraries =  pkgs: [
          # List library dependencies here
        ];
     })
  ];

  programs = {
      git = {
        enable = true;
        userName = "noegodinho";
        userEmail = "noe.godinho.92@gmail.com";
      };

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
          mmamba="micromamba";
          mmamba_update="micromamba activate general && micromamba update --all -y python=3.12.5 -c conda-forge && micromamba activate solver && micromamba update --all -y -c conda-forge && micromamba activate space && micromamba update --all -y -c conda-forge && micromamba activate tudat-space && micromamba update --all -y -c conda-forge && micromamba activate yafs && micromamba update --all -y -c conda-forge";
        };

        initExtra=''
          source ~/.p10k.zsh

          eval "$(micromamba shell hook --shell zsh)"
          # >>> mamba initialize >>>
          # !! Contents within this block are managed by 'mamba init' !!
          export MAMBA_EXE='/nix/store/r1m1ii09z82wv07ivb00jz2iz2pxmbc9-micromamba-1.5.8/bin/micromamba';
          export MAMBA_ROOT_PREFIX='/home/pleiades/micromamba';
          __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
          if [ $? -eq 0 ]; then
              eval "$__mamba_setup"
          else
              alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
          fi
          unset __mamba_setup
          # <<< mamba initialize <<<

          micromamba activate general
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

        extensions = (with extensions.vscode-marketplace; [
          bbenoist.nix
          cschlosser.doxdocgen
          james-yu.latex-workshop
          jeff-hykin.better-cpp-syntax
          jnoortheen.nix-ide
          luquedaniel.languague-renpy
          mechatroner.rainbow-csv
          ms-python.isort
          ms-python.python
          ms-python.vscode-pylance
          # ms-toolsai.jupyter
          # ms-toolsai.jupyter-keymap
          # ms-toolsai.jupyter-renderers
          # ms-toolsai.vscode-jupyter-cell-tags
          # ms-toolsai.vscode-jupyter-slideshow
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.makefile-tools
          tecosaur.latex-utilities
          twxs.cmake
          valentjn.vscode-ltex
          # visualstudioexptteam.vscodeintellicode
          yzhang.markdown-all-in-one
         ]);
         
         userSettings = {
            "files.autoSave" = "afterDelay";
            "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
            "editor.wordWrap" = "on";
         };
      };

      firefox.enable = false;
      # hyprland.enable = false; # change later to true if decide to try it
      java.enable = true;
      # adb.enable = true; # check if needed in pc after installing
      home-manager.enable = true;
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };
  };

  # Nicely reload system units when changing configs
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
