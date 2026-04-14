{ pkgs, unstable, stdenv, inputs, ... }: let
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "9d01befbc519cd218f557b9cd500c56b1ec2f995";
    })).extensions.${stdenv.hostPlatform.system};
in {
  imports = [
      inputs.weathr.homeModules.weathr
      ./hyprland-configuration.nix
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
      testdisk
      dig
      ffmpeg
      unstable.micromamba
      nix-output-monitor
      nil
      nurl
      glow
      
      libreoffice-fresh
      hunspell
      hunspellDicts.pt_PT
      hunspellDicts.en_GB-ise

      kdePackages.ktorrent

      file-roller
      papers
      lollypop
      gthumb
      keepassxc
      thunderbird
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
      qalculate-gtk
      imagemagick
      projecteur
      khronos
      stellarium
      xournalpp
      unstable.gurobi

      nerd-fonts.meslo-lg
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      font-awesome
      
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

    # thunderbird = {
    #   enable = true;
    #   package = pkgs.thunderbird;
    #   profiles = [ ... ];
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

  xdg = {
    enable = true;

    configFile."mimeapps.list".force = true;
    dataFile."applications/mimeapps.list".force = true;

    configFile."Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>custom-terminal-action</unique-id>
          <command>ghostty --working-directory=%f</command>
          <description>Open a terminal in the current folder</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
      </actions>
    '';
    
    mimeApps = {
      enable = true;
      
      defaultApplications = {
        "inode/directory" = "thunar.desktop";

        # Web / Browser links
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";

        # Images
        "image/jpeg" = "org.gnome.gThumb.desktop";
        "image/png" = "org.gnome.gThumb.desktop";
        "image/gif" = "org.gnome.gThumb.desktop";
        "image/webp" = "org.gnome.gThumb.desktop";

        # Audio
        "audio/mp3" = "org.gnome.Lollypop.desktop";
        "audio/flac" = "org.gnome.Lollypop.desktop";
        "audio/wma" = "org.gnome.Lollypop.desktop";
        "audio/wav" = "org.gnome.Lollypop.desktop";

        # Videos
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";

        # Documents
        "application/pdf" = "org.gnome.Papers.desktop";
        "text/plain" = "codium.desktop";
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