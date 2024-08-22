{ config, pkgs, unstable, ... }:

{
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
    nvtopPackages.nvidia
    nvtopPackages.intel
    undervolt
    lm_sensors
    psensor
    stress
    linuxKernel.packages.linux_zen.cpupower
    linuxKernel.packages.linux_zen.turbostat
    smartmontools
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
    unstable.thunderbird
    ktorrent
    skypeforlinux
    unstable.zotero
    slack
    discord # discordo # may try later
    pympress
    dropbox # maestral # decide which one to use
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
    youtube-dl
    qalculate-qt
    kdePackages.kamoso

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
          mmamba_update="micromamba activate general && micromamba update --all python=3.12.5 -y && micromamba activate solver && micromamba update --all -y && micromamba activate space && micromamba update --all -y && micromamba activate tudat-space && micromamba update --all -y && micromamba activate yafs && micromamba update --all -y";
        };

        initExtra=''
          source ~/.p10k.zsh

          # >>> conda initialize >>>
          # !! Contents within this block are managed by 'conda init' !!
          # __conda_setup="$('/home/pleiades/.conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
          # if [ $? -eq 0 ]; then
          #     eval "$__conda_setup"
          # else
          #     if [ -f "/home/pleiades/.conda/etc/profile.d/conda.sh" ]; then
          #         . "/home/pleiades/.conda/etc/profile.d/conda.sh"
          #     else
          #         export PATH="/home/pleiades/.conda/bin:$PATH"
          #     fi
          # fi
          # unset __conda_setup
          # <<< conda initialize <<<

          eval "$(micromamba shell hook --shell zsh)"
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

        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          james-yu.latex-workshop
          jnoortheen.nix-ide
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
          twxs.cmake
          valentjn.vscode-ltex
          # visualstudioexptteam.vscodeintellicode
          yzhang.markdown-all-in-one
         ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
         ];
         
         userSettings = {
            "files.autoSave" = "afterDelay";
            "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
            "editor.wordWrap" = "on";
         };
      };

      firefox.enable = false;
      hyprland.enable = false; # change later to true if decide to try it
      java.enable = true;
      # solaar.enable = true;
      # adb.enable = true; # check if needed in pc after installing
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