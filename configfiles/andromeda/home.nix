{ pkgs, unstable, system, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "3973067bac2718d7cb5f8c68f45f5685c918046a";
    })).extensions.${system};
in {
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

  # Enable configuration of fonts
  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland = {
      enable = true;
    };
  
    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    systemd.variables = ["--all"];

    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, F, exec, ghostty"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )9)
        );
    };
  };

  home = {
    username = "andromeda";
    homeDirectory = "/home/andromeda";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      linux-manual
      man-pages
      man-pages-posix
      gcc
      gdb
      gnumake
      cmake
      valgrind
      ccls

      wget
      usbutils
      pciutils
      coreutils-full
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
      gnutar
      lsof
      kdePackages.filelight

      htop
      btop
      intel-gpu-tools
      lm_sensors
      mission-center
      dmidecode
      stress
      lshw
      wayland-utils
      hwinfo
      clinfo
      glxinfo
      linuxKernel.packages.linux_zen.cpupower
      linuxKernel.packages.linux_zen.turbostat
      powertop
      smartmontools
      fastfetch
      gparted
      testdisk-qt
      dig
      ffmpeg
      micromamba
      nix-output-monitor
      nil
      nurl
      glow
      
      libreoffice-qt6-fresh
      hunspell
      hunspellDicts.pt_PT
      hunspellDicts.en_GB-ise

      keepassxc
      thunderbird
      kdePackages.ktorrent
      brave
      unstable.telegram-desktop
      unstable.teams-for-linux
      zotero
      slack
      discord
      pympress
      unstable.maestral
      veracrypt
      duplicati # http://localhost:8200/
      texliveFull
      todo-txt-cli
      qalculate-qt
      imagemagick
      projecteur
      khronos
      stellarium
      xournalpp
      unstable.gurobi

      nerd-fonts.meslo-lg
      
      ardour
      musescore
      yabridge
      yabridgectl

      renpy
      duckstation
      rare
      # wineWowPackages.full
      wineWowPackages.waylandFull
      winetricks
      vulkan-tools
      (lutris.override {
        extraPkgs = pkgs: [
          mangohud
        ];

        extraLibraries = pkgs: [
          # List library dependencies here
        ];
      })
    ];
  };

  programs = {
    brave.nativeMessagingHosts = [ 
      pkgs.keepassxc
    ];

    git = {
      enable = true;
      package = pkgs.git;
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
          { name = "marlonrichert/zsh-autocomplete"; }
          { name = "chisui/zsh-nix-shell"; }
        ];
      };

      shellAliases = {
        flake_update="sudo nix flake update --flake ~/nixconfigs/configfiles/andromeda";
        rebuild="sudo nixos-rebuild switch --upgrade-all --flake ~/nixconfigs/configfiles/andromeda/#laniakea -v";
        mmamba="micromamba";
        mmamba_update="mmamba activate general && mmamba update --all -y -c conda-forge && mmamba activate solver && mmamba update --all -y -c conda-forge && mmamba activate space && mmamba update --all -y -c conda-forge && mmamba activate tudat-space && mmamba update --all -y -c conda-forge && mmamba activate yafs && mmamba update --all -y -c conda-forge";
        update_all="flake_update && rebuild && mmamba_update && nix-collect-garbage -d && zplug update";
        projecteur="QT_QPA_PLATFORM=xcb projecteur -D abc8:ca08";
      };

      initContent=''
        source ~/.p10k.zsh

        export GRB_LICENSE_FILE=~/gurobi.lic

        eval "$(micromamba shell hook --shell zsh)"
        # >>> mamba initialize >>>
        # !! Contents within this block are managed by 'mamba init' !!
        export MAMBA_EXE='/etc/profiles/per-user/andromeda/bin/micromamba';
        export MAMBA_ROOT_PREFIX='/home/andromeda/micromamba';
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

    ghostty = {
      enable = true;
      package = pkgs.ghostty;
      enableZshIntegration = true;
      installBatSyntax = true;
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

    direnv = {
      enable = true;
      package = pkgs.direnv;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      package = unstable.atuin;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      package = pkgs.bat;
    };

    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
    };

    vscode = {
      enable = true;
      package = unstable.vscodium;

      # mutableExtensionsDir = false;
      # enableUpdateCheck = false;
      # enableExtensionUpdateCheck = false;

      profiles.default = { 
        extensions = with extensions.vscode-marketplace; [
          bbenoist.nix
          ccls-project.ccls
          detachhead.basedpyright
          james-yu.latex-workshop
          jeff-hykin.better-c-syntax
          jeff-hykin.better-cpp-syntax
          jeff-hykin.better-m-syntax
          jnoortheen.nix-ide
          luquedaniel.languague-renpy
          mechatroner.rainbow-csv
          ms-python.python
          pinage404.nix-extension-pack
          tecosaur.latex-utilities
          usernamehw.errorlens
          valentjn.vscode-ltex
          yzhang.markdown-all-in-one
        ] ++ (with import <unstable> {}; (with unstable.vscode-extensions; [
          github.copilot
        ]));
          
        userSettings = {
          "files.autoSave" = "afterDelay";
          "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
          "editor.wordWrap" = "on";
          "latex-workshop.latex.autoBuild.run" = "never";
          "ltex.additionalRules.motherTongue" = "pt-PT";
          "ltex.language" = "en-GB";
          "ltex.enabled" = ["bibtex" "context" "context.tex" "html" "latex" "markdown" "org" "restructuredtext" "rsweave"];
          "python.defaultInterpreterPath" = "/home/andromeda/micromamba/envs/general/bin/python";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "git.openRepositoryInParentFolders" = "always";
          "cmake.pinnedCommands" = ["workbench.action.tasks.configureTaskRunner" "workbench.action.tasks.runTask"];
          "ccls.launch.command" = "/etc/profiles/per-user/andromeda/bin/ccls";
          "ccls.highlight.function.face" = ["enabled"];
          "ccls.highlight.type.face" = ["enabled"];
          "ccls.highlight.variable.face" = ["enabled"];
          "ccls.misc.compilationDatabaseDirectory" = "build";
          "workbench.colorTheme" = "Abyss";
          "git.autofetch" = true;
        };
      };
    };

    joplin-desktop = {
      enable = true;
      package = pkgs.joplin-desktop;
      sync = {
        interval = "5m";
        target = "dropbox";
      };
    };

    mpv = {
      enable = true;
      package = pkgs.mpv;
      config = {
        keep-open = true;
      };
    };

    yt-dlp = {
      enable = true;
      package = pkgs.yt-dlp;
    };

    # thunderbird = {
    #   enable = true;
    #   package = pkgs.thunderbird;
    #   profiles = [ ... ];
    # };

    # eww = {
    #   enable = true;
    #   package = pkgs.eww;
    #   enableZshIntegration = true;
    #   configDir = /. + builtins.getEnv("HOME");
    # };

    firefox.enable = false;
    java.enable = true;
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
  home.stateVersion = "24.11";
}
