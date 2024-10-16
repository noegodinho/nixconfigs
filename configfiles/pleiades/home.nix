{ pkgs, unstable, system, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "c43d9089df96cf8aca157762ed0e2ddca9fcd71e";
    })).extensions.${system};
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
    coreutils-full
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
    lsof

    htop
    btop
    nvtopPackages.full
    undervolt
    lm_sensors
    psensor
    stress
    lshw
    aha
    fwupd
    wayland-utils
    hwinfo
    clinfo
    glxinfo
    linuxKernel.packages.linux_zen.cpupower
    linuxKernel.packages.linux_zen.turbostat
    powertop
    smartmontools
    neofetch
    gparted
    testdisk-qt

    ffmpeg
    bat
    fzf
    micromamba
    konsave

    nix-output-monitor
    nil
    nurl
    glow
    
    libreoffice-qt
    hunspell
    hunspellDicts.pt_PT
    hunspellDicts.en_GB-ise

    keepass
    thunderbird
    kdePackages.ktorrent
    unstable.brave
    unstable.telegram-desktop
    skypeforlinux
    unstable.zotero
    slack
    discord
    pympress
    unstable.maestral
    veracrypt
    duplicati # http://localhost:8200/
    zoom-us
    mpv
    texliveFull
    todo-txt-cli
    yt-dlp
    qalculate-qt
    kdePackages.kweather
    imagemagick
    projecteur
    unstable.kdePackages.okular
    joplin-desktop

    (nerdfonts.override { fonts = [ "Meslo" ]; })
    
    ardour
    musescore
    yabridge
    yabridgectl

    renpy
    pcsxr
    rare
    wineWowPackages.waylandFull # wineWowPackages.full
    winetricks
    vulkan-tools
    (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
        ];

        extraLibraries =  pkgs: [
          # List library dependencies here
        ];
     })

     khronos
     ns-3
     sumo
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
          flake_update="sudo nix flake update ~/nixconfigs/configfiles/pleiades";
          rebuild="sudo nixos-rebuild switch --upgrade-all --flake ~/nixconfigs/configfiles/pleiades/#milkyway -v";
          mmamba="micromamba";
          mmamba_update="micromamba activate general && micromamba update --all -y -c conda-forge && micromamba activate solver && micromamba update --all -y -c conda-forge && micromamba activate space && micromamba update --all -y -c conda-forge && micromamba activate tudat-space && micromamba update --all -y -c conda-forge && micromamba activate yafs && micromamba update --all -y -c conda-forge";
          update_all="flake_update && rebuild && mmamba_update && nix-collect-garbage -d";
          projecteur="QT_QPA_PLATFORM=xcb projecteur -D abc8:ca08";
        };

        initExtra=''
          source ~/.p10k.zsh

          eval "$(micromamba shell hook --shell zsh)"
          # >>> mamba initialize >>>
          # !! Contents within this block are managed by 'mamba init' !!
          export MAMBA_EXE='/etc/profiles/per-user/pleiades/bin/micromamba';
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

      foot = {
        enable = true;
        package = unstable.foot;

        settings = {
          colors = {
            background = "000000";
          };

          main = {
            # dpi-aware = "yes";
            font = "MesloLGS Nerd Font:size=10";
            term = "foot";
          };

          mouse = {
            hide-when-typing = "yes";
          };
        };
      };

      atuin = {
        enable = true;
        package = unstable.atuin;
        enableZshIntegration = true;
      };

      zellij = {
        enable = true;
        package = pkgs.zellij;
        enableZshIntegration = true;
      };

      vscode = {
        enable = true;
        package = unstable.vscodium;

        # mutableExtensionsDir = false;
        # enableUpdateCheck = false;
        # enableExtensionUpdateCheck = false;

        extensions = with extensions.open-vsx; [
          # detachhead.basedpyright
        ] ++ (with extensions.vscode-marketplace; [
          # arrterian.nix-env-selector
          bbenoist.nix
          cschlosser.doxdocgen
          james-yu.latex-workshop
          jeff-hykin.better-cpp-syntax
          jnoortheen.nix-ide
          luquedaniel.languague-renpy
          mechatroner.rainbow-csv
          ms-python.python
          # ms-python.vscode-pylance
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.cpptools-themes
          ms-vscode.makefile-tools
          pinage404.nix-extension-pack
          tecosaur.latex-utilities
          twxs.cmake
          valentjn.vscode-ltex
          # visualstudioexptteam.vscodeintellicode
          yzhang.markdown-all-in-one
         ]) ++ (with unstable.vscode-extensions; [
          github.copilot
         ]);
         
         userSettings = {
            "files.autoSave" = "afterDelay";
            "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
            "editor.wordWrap" = "on";
            "C_Cpp.default.compilerPath" = "/etc/profiles/per-user/pleiades/bin/gcc";
            "C_Cpp.default.intelliSenseMode" = "linux-gcc-x64";
            "C_Cpp.autocompleteAddParentheses" = true;
            "C_Cpp.default.systemIncludePath" = ["/nix/store/skkw2fidr9h2ikq8gzgfm6rysj1mal0r-gcc-13.2.0/lib/gcc/x86_64-unknown-linux-gnu/13.2.0/include"];
            "latex-workshop.latex.autoBuild.run" = "never";
            "ltex.additionalRules.motherTongue" = "pt-PT";
            "ltex.language" = "en-GB";
            "ltex.enabled" = ["bibtex" "context" "context.tex" "html" "latex" "markdown" "org" "restructuredtext" "rsweave"];
            "python.defaultInterpreterPath" = "/home/pleiades/micromamba/envs/general/bin/python";
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
         };
      };

      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
        ];
      };

      firefox.enable = false;
      java.enable = true;
      # hyprland.enable = false; # change later to true if decide to try it
      home-manager.enable = true;
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "daily";
    };

    fusuma = {
      enable = true;
      package = pkgs.fusuma;
      extraPackages = with pkgs; [
        xdotool
        coreutils-full
        xorg.xprop
        playerctl
      ];

      settings = {
        threshold = {
          swipe = 0.1;
          pinch = 0.1;
        };
        interval = {
          swipe = 0.7;
          pinch = 0.5;
        };
        pinch = {
          "2" = {
            "in" = {
              # command = "xdotool keydown ctrl click 4 keyup ctrl";
              sendkey = "LEFTMETA+EQUAL";
            };
            "out" = {
              # command = "xdotool keydown ctrl click 5 keyup ctrl";
              sendkey = "LEFTMETA+MINUS";
            };
          };
        };
        swipe = {
          "3" = {
            left = {
              sendkey = "LEFTALT+LEFT";
            };
            right = {
              sendkey = "LEFTALT+RIGHT";
            };
            up = {
              sendkey = "NEXTSONG";
            };
            down = {
              sendkey = "PREVIOUSSONG";
            };
          };
          "4" = {
            left = {
              sendkey = "LEFTCTRL+F1";
            };
            right = {
              sendkey = "LEFTCTRL+F2";
            };
          };
        };
        hold = {
          "4" = {
            command = "playerctl play-pause";
          };
        };
        plugin = {
          input = {
            libinput_command_input = {
              enable-tap = {
                command = true;
              };
              enable-dwt = {
                command = true;
              };
              show-keycodes = {
                command = true;
              };
            };
          };
        };
      };
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
