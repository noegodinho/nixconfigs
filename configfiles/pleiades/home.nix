{ config, pkgs, ... }:

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
    smartmontools
    fusuma
    lshw
    glxinfo
    linuxKernel.packages.linux_zen.turbostat
    wineWowPackages.waylandFull # wineWowPackages.full
    winetricks
    yabridge
    protonup-qt
    
    libreoffice-qt
    hunspell
    hunspellDicts.pt_PT
    hunspellDicts.en_GB-ise

    neovim
    zellij
    keepass
    thunderbird # kmail # decide which one to use
    ktorrent
    skypeforlinux
    zotero
    slack
    musescore
    pympress
    dropbox # maestral # decide which one to use
    veracrypt
    duplicati # http://localhost:8200/
    gphoto2
    vlc
    pcsxr
    itch
    rare
    renpy
    texliveFull
    todo-txt-cli
    ardour
    tor-browser
    youtube-dl
    qalculate-qt
    kdePackages.kamoso

    (nerdfonts.override { fonts = [ "Meslo" ]; })

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
          conda_update="conda activate general && conda update --all -y && conda activate solver && conda update --all -y && conda activate space && conda update --all -y && conda activate yafs && conda update --all -y";
        };

        initExtra=''
          source ~/.p10k.zsh

          # >>> conda initialize >>>
          # !! Contents within this block are managed by 'conda init' !!
          __conda_setup="$('/home/pleiades/.conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
          if [ $? -eq 0 ]; then
              eval "$__conda_setup"
          else
              if [ -f "/home/pleiades/.conda/etc/profile.d/conda.sh" ]; then
                  . "/home/pleiades/.conda/etc/profile.d/conda.sh"
              else
                  export PATH="/home/pleiades/.conda/bin:$PATH"
              fi
          fi
          unset __conda_setup
          # <<< conda initialize <<<

          conda activate general
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

      firefox.enable = false;
      hyprland.enable = false; # change later to true if decide to try it
      java.enable = true;
      solaar.enable = true;
      # adb.enable = true; # check if needed in pc after installing
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