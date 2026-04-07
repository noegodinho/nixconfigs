{ pkgs, unstable, stdenv, inputs, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "828735c01584dd780b32dde9c2b8c7a968bffb51";
    })).extensions.${stdenv.hostPlatform.system};

  power-toggle = pkgs.writeShellScriptBin "power-toggle" ''
    # Get the current profile from power-profiles-daemon
    CURRENT_PROFILE=$(powerprofilesctl get)

    if [ "$CURRENT_PROFILE" = "power-saver" ]; then
        # === SWITCH TO BALANCED ===
        powerprofilesctl set balanced
        hyprctl keyword animations:enabled true
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:drop_shadow true
        # Restore 120Hz (Update 'eDP-1' to your monitor name)
        # hyprctl keyword monitor "eDP-1, 3072x1920@120, 0x0, 1.6"
        
        notify-send "Power Mode" "Balanced (Effects Enabled)" -t 2000 -i battery-full
    elif [ "$CURRENT_PROFILE" = "performance" ]; then
        # === SWITCH TO POWER SAVE ===
        powerprofilesctl set power-saver
        hyprctl keyword animations:enabled false
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword decoration:drop_shadow false
        # Drop to 60Hz to save Intel Arc power
        # hyprctl keyword monitor "eDP-1, 3072x1920@60, 0x0, 1.6"
        
        notify-send "Power Mode" "Power Saver (Minimalist)" -t 2000 -i battery-low
    else
        # === SWITCH TO PERFORMANCE ===
        powerprofilesctl set performance
        hyprctl keyword animations:enabled true
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:drop_shadow true
        # Restore 120Hz (Update 'eDP-1' to your monitor name)
        # hyprctl keyword monitor "eDP-1, 3072x1920@120, 0x0, 1.6"
        
        notify-send "Power Mode" "Performance" -t 2000 -i battery-low
    fi    
  '';

  mic-toggle = pkgs.writeShellScriptBin "mic-toggle" ''
    # Toggle the default microphone
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # Check the new status to send the correct notification
    STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    
    if [[ "$STATUS" == *"[MUTED]"* ]]; then
        notify-send "Microphone" "Muted" -t 2000 -i microphone-sensitivity-muted-symbolic -h string:x-canonical-private-synchronous:mic-notif
    else
        notify-send "Microphone" "On" -t 2000 -i microphone-sensitivity-high-symbolic -h string:x-canonical-private-synchronous:mic-notif
    fi
  '';
in {
  imports = [
      inputs.weathr.homeModules.weathr
  ];
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
    systemd = {
      enable = true;
      variables = ["--all"];
    };

    settings = {
      monitor = [
        "eDP-1, 3072x1920@120, 0x0, 1.6"
      ];

      # xwayland = {
      #   force_zero_scaling = true;
      # };

      # Set the Super key as the main modifier
      "$mod" = "SUPER";

      # Autostart applications
      "exec-once" = [
        "waybar"                # Launch the bar
        "mako"                  # Launch the notification daemon
        "hyprpaper"             # Launch the wallpaper daemon
        "/usr/lib/polkit-kde-authentication-agent-1" # Polkit agent
        # Crucial for KWallet/Brave communication
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=KDE"
        # Start the wallet daemon if it's not already running
        "kwalletd6"
        "surfshark"
        "hyprsunset -t 4000"
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

        sensitivity = 0.5; # -1.0 - 1.0, 0 means no modification.
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
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
      };

      misc.vfr = true;

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

      plugin = {
          hyprscrolling = {
              column_width = 0.7;
              fullscreen_on_one_column = false;
          };
      };

      # Keybindings
      bind = [
        # Core Apps
        "CTRL ALT, T, exec, ghostty"        # Terminal
        "$mod, E, exec, dolphin"             # File Manager
        "$mod, SPACE, exec, rofi -show drun" # KRunner style launcher
        
        # Window Management
        "$mod, Q, killactive,"               # Close Window (KDE allows Alt+F4 too, but this is standard)
        "ALT, F4, killactive,"                 # Traditional close
        "$mod, F, fullscreen,"               # Fullscreen
        "$mod, V, togglefloating,"           # Toggle Float
        
        # Session
        "$mod SHIFT, E, exit,"               # Log out

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Toggle Power Mode with F8
        ", F8, exec, power-toggle"

        # Focus Movement (Vim keys)
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Workspaces (1-9)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"

        # Move to Workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
      ];

      # -- Mouse Binds (KDE Style Window Dragging) --
      bindm = [
        "$mod, mouse:272, movewindow"   # Super + Left Click = Move
        "$mod, mouse:273, resizewindow" # Super + Right Click = Resize
      ];

      bindl = [
        # Standard Microphone Mute key
        ", XF86AudioMicMute, exec, mic-toggle"
      ];

      # Volume / Brightness Media Keys
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  home = {
    username = "andromeda";
    homeDirectory = "/home/andromeda";

    sessionVariables = {
      PASSWORD_STORE = "kwallet6";
      GTK_THEME = "Breeze-Dark";
      # Ensures Qt apps don't accidentally fall back to light mode
      QT_QPA_PLATFORMTHEME = "kde";
    };

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
      teams-for-linux
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
      heroic
      (unstable.lutris.override {
        extraPkgs = pkgs: [
          mangohud
        ];

        extraLibraries = pkgs: [
          # List library dependencies here
        ];
      })

      # Hyprland related packages
      rofi         # The application launcher
      mako         # The notification daemon
      grim         # For screenshots
      slurp        # For selecting screen regions
      wl-clipboard # Clipboard utilities
      hyprsunset
      libnotify
      power-toggle
      mic-toggle
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
      enableCompletion = true;

      zplug = {
        enable = true;
        
        plugins = [
          { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
          # { name = "marlonrichert/zsh-autocomplete"; }
          { name = "chisui/zsh-nix-shell"; }
        ];
      };

      shellAliases = {
        flake_update="sudo nix flake update --flake ~/nixconfigs/configfiles/andromeda";
        rebuild="sudo nixos-rebuild switch --upgrade-all --log-format bar-with-logs --flake ~/nixconfigs/configfiles/andromeda/#laniakea -v";
        mmamba="micromamba";
        mmamba_update="mmamba activate general && mmamba update --all -y -c conda-forge && mmamba activate space && mmamba update --all -y -c conda-forge && mmamba activate gurobi_solver && mmamba update --all -y -c conda-forge && mmamba activate yafs && mmamba update --all -y -c conda-forge";
        update_all="flake_update && rebuild && mmamba_update && nix-collect-garbage -d && flatpak update -y && zplug update";
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
      systemd.enable = true;
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
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        # inline_height = 0;
        enter_accept = true;
        records = true;
      };
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
          oderwat.indent-rainbow
          pinage404.nix-extension-pack
          repreng.csv
          ryu1kn.partial-diff
          tecosaur.latex-utilities
          usernamehw.errorlens
          valentjn.vscode-ltex
          vstirbu.vscode-mermaid-preview
          wayou.vscode-todo-highlight
          yzhang.markdown-all-in-one
        ]; # ]  ++ (with import <unstable> {}; (with unstable.vscode-extensions; [
          # github.copilot-chat
        # ]));
          
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

    weathr = {
      enable = true;
      
      settings = {
        hide_hud = false;
        silent = false;
        temperature = "celsius";
        wind_speed = "kmh";
        precipitation = "mm";
        
        auto = false;
        hide = false;
        location = {
          latitude = 39.5458;
          longitude = 8.3741;
        };
      };
    };

    waybar = {
      enable = true;
      # systemd.enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        modules-left = [ "custom/launcher" "wlr/taskbar" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "tray" "pulseaudio" "network" "battery" "clock" ];
        
        "custom/launcher" = { format = "  "; on-click = "rofi -show drun"; };
        "wlr/taskbar" = { format = "{icon}"; on-click = "activate"; on-click-middle = "close"; };
        "clock" = { format = "{:%I:%M %p  %a, %b %d}"; };
        "battery" = { format = "{capacity}% {icon}"; format-icons = ["" "" "" "" ""]; };
        "pulseaudio" = { format = "{volume}% "; on-click = "pavucontrol"; };
      };
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
