{ pkgs, unstable, system, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "526331948fbe33571c32407f47a0bb943c348fcc";
    })).extensions.${system};
in {
  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/'«i3/wallpaper.jpg".source = ./wallpaper.jpg;

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

  fonts.fontconfig = {
    enable = true;
    # defaultFonts = {
    #   serif = [ "Noto Serif CJK JP" "Liberation Serif" ];
    #   sansSerif = [ "Noto Sans CJK JP" "Liberation Sans" ];
    #   monospace = [ "Noto Sans Mono CJK JP" "Liberation Mono" ];
    # };
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;

    # Disable Hyprland package, use system-provided one
    package = null;
    portalPackage = null;

    # Whether to enable XWayland
    xwayland = {
      enable = true;
    };
  
    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    systemd.variables = ["--all"];

    settings = {
      # Set the Super key as the main modifier
      "$mod" = "SUPER";

      # Autostart applications
      "exec-once" = [
        "waybar"                # Launch the bar
        "mako"                  # Launch the notification daemon
        "hyprpaper"             # Launch the wallpaper daemon
        "/usr/lib/polkit-kde-authentication-agent-1" # Polkit agent
      ];

      # Input settings
      input = {
        kb_layout = "pt";
        kb_variant = "";
        # kb_model = "";
        # kb_options = "ctrl:nocaps"; # Example: Map Caps Lock to Ctrl
        # kb_rules = "";

        follow_mouse = 1;
        
        touchpad = {
          natural_scroll = true;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };
      
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration (shadows, rounding)
      decoration = {
        rounding = 10;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Keybindings
      bind = [
        # Launch terminal
        "$mod, RETURN, exec, ghostty"
        # Close window
        "$mod, Q, killactive,"
        # Launch app launcher
        "$mod, D, exec, wofi --show drun"
        # Exit Hyprland
        "$mod SHIFT, E, exit,"
        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Move focus
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        # ...and so on for 4-9

        # Move active window to a workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        # ...and so on for 4-9
      ];
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
      rare-regex

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
      unstable.micromamba
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
      unstable.brave
      unstable.telegram-desktop
      unstable.teams-for-linux
      zotero
      slack
      discord
      pympress
      maestral
      rclone
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
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      
      ardour
      musescore
      yabridge
      yabridgectl

      # unstable.renpy
      # duckstation
      # wineWowPackages.full
      wineWowPackages.waylandFull
      winetricks
      vulkan-tools
      (unstable.lutris.override {
        extraPkgs = pkgs: [
          mangohud
        ];

        extraLibraries = pkgs: [
          # List library dependencies here
        ];
      })

      # Hyprland related packages
      waybar       # The status bar
      rofi         # The application launcher
      mako         # The notification daemon
      grim         # For screenshots
      slurp        # For selecting screen regions
      wl-clipboard # Clipboard utilities
    ];
  };

  programs = {
    brave.nativeMessagingHosts = [ 
      pkgs.keepassxc
    ];

    git = {
      enable = true;
      package = pkgs.git;
      
      settings.user = {
        name = "noegodinho";
        email = "noe.godinho@protonmail.com";
      };
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
        mmamba_update="mmamba activate general && mmamba update --all -y -c conda-forge && mmamba activate solver && mmamba update --all -y -c conda-forge && mmamba activate space && mmamba update --all -y -c conda-forge && mmamba activate gurobi_solver && mmamba update --all -y -c conda-forge && mmamba activate yafs && mmamba update --all -y -c conda-forge";
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
      package = unstable.ghostty.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/ghostty \
            --set GTK_IM_MODULE simple
        '';
      });
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
          # detachhead.basedpyright
          james-yu.latex-workshop
          jeff-hykin.better-c-syntax
          jeff-hykin.better-cpp-syntax
          jnoortheen.nix-ide
          luquedaniel.languague-renpy
          mechatroner.rainbow-csv
          ms-python.python
          nogic.nogic
          oderwat.indent-rainbow
          pinage404.nix-extension-pack
          ryu1kn.partial-diff
          tecosaur.latex-utilities
          usernamehw.errorlens
          valentjn.vscode-ltex
          vstirbu.vscode-mermaid-preview
          wayou.vscode-todo-highlight
          yzhang.markdown-all-in-one
        ] ++ (with import <unstable> {}; (with unstable.vscode-extensions; [
          github.copilot
        ]));
          
        userSettings = {
          "files.autoSave" = "afterDelay";
          "terminal.integrated.fontFamily" = "MesloLGS Nerd Font";
          "editor.fontFamily" = "MesloLGS Nerd Font";
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
          "editor.bracketPairColorization.enabled" = true;
        };
      };
    };

    joplin-desktop = {
      enable = true;
      package = unstable.joplin-desktop;
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
