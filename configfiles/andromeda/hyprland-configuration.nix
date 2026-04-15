{ pkgs, inputs, ... }: let
  power-toggle = pkgs.writeShellScriptBin "power-toggle" ''
    # Get the current profile from power-profiles-daemon
    CURRENT_PROFILE=$(powerprofilesctl get)

    if [ "$CURRENT_PROFILE" = "power-saver" ]; then
        # === SWITCH TO BALANCED ===
        powerprofilesctl set balanced
        hyprctl keyword animations:enabled true
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:drop_shadow true
        brightnessctl set 50%
        brightnessctl --device='*kbd_backlight*' set 2
        # Restore 120Hz (Update 'eDP-1' to your monitor name)
        # hyprctl keyword monitor "eDP-1, 3072x1920@120, 0x0, 1.6"
        
        notify-send "Power Mode" "Balanced (Effects Enabled)" -t 2000 -i battery-full
    elif [ "$CURRENT_PROFILE" = "performance" ]; then
        # === SWITCH TO POWER SAVE ===
        powerprofilesctl set power-saver
        hyprctl keyword animations:enabled false
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword decoration:drop_shadow false
        brightnessctl set 35%
        brightnessctl --device='*kbd_backlight*' set 0
        # Drop to 60Hz to save Intel Arc power
        # hyprctl keyword monitor "eDP-1, 3072x1920@60, 0x0, 1.6"
        
        notify-send "Power Mode" "Power Saver (Minimalist)" -t 2000 -i battery-low
    else
        # === SWITCH TO PERFORMANCE ===
        powerprofilesctl set performance
        hyprctl keyword animations:enabled true
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:drop_shadow true
        brightnessctl set 50%
        brightnessctl --device='*kbd_backlight*' set 2
        # Restore 120Hz (Update 'eDP-1' to your monitor name)
        # hyprctl keyword monitor "eDP-1, 3072x1920@120, 0x0, 1.6"
        
        notify-send "Power Mode" "Performance" -t 2000 -i battery-full
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

  # This script detects if we are mirroring and flips the state
  display-toggle = pkgs.writeShellScriptBin "display-toggle" ''
    # Get the names of your monitors
    INTERNAL="eDP-1"
    EXTERNAL=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

    if [ -z "$EXTERNAL" ]; then
      notify-send "Display" "No external monitor detected."
      exit 0
    fi

    # Check if mirroring is currently active
    IS_MIRRORED=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .mirrorOf' | grep -v "null")

    if [ "$IS_MIRRORED" == "none" ]; then
      # SWITCH TO MIRROR
      notify-send "Display" "Mirroring Screens"
      hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1, mirror, $INTERNAL"
    else
      # SWITCH TO EXTEND
      notify-send "Display" "Extending Desktop"
      hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1"
    fi
  '';
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };

  gtk = {
    enable = true;

    theme = {
      name = "Colloid-Green-Dark";
      package = pkgs.colloid-gtk-theme.override {
        themeVariants = [ "green" ];
        colorVariants = [ "dark" ];
      };
    };

    iconTheme = {
      name = "Papirus-Dark"; 
      package = (pkgs.papirus-icon-theme.override { color = "teal"; });
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    style.name = "kvantum";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;

    # Use the package from the flake input
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    package = null;
    portalPackage = null;

    # Whether to enable XWayland
    xwayland = {
      enable = true;
    };
  
    # Whether to enable hyprland-session.target on hyprland startup
    systemd = {
      enable = true;
      variables = ["--all"];
    };

    settings = {
      monitor = [
        "eDP-1, 3072x1920@120, 0x0, 1.6"
      ];

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,20"
        "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        "HYPRCURSOR_SIZE,20"

        # --- GTK Variables ---
        "GTK_THEME,Colloid-Green-Dark"
        
        # --- Qt / KDE Variables ---
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_STYLE_OVERRIDE,kvantum"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      # Set the Super key as the main modifier
      "$mod" = "SUPER";

      # Autostart applications
      "exec-once" = [
        "hyprctl setcursor Bibata-Modern-Classic 20"
        "waybar"                # Launch the bar
        "swaynotificationcenter"                  # Launch the notification daemon
        "hyprpaper"             # Launch the wallpaper daemon
        "gnome-keyring-daemon --start --components=secrets"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user restart xdg-desktop-portal-hyprland"
        "com.surfshark.Surfshark"
        "hyprsunset -t 4000"
        "nm-applet --indicator"
        "brave"
        "keepassxc"
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

      misc = {
        # Wakes up the monitor if you move the mouse
        mouse_move_enables_dpms = true;
        
        # Wakes up the monitor if you press any key on the keyboard
        key_press_enables_dpms = true;
      };
      
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(31363bff)";
        layout = "dwindle";
      };

      # windowrule = [
      #   "float, class:^(dolphin|systemsettings|pavucontrol|spectacle)$"
      # ];

      # Decoration (shadows, rounding)
      decoration = {
        rounding = 10;
        
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          vibrancy = 0.2;            # Makes the colors underneath "glow"
          brightness = 0.8;          # Dims the background slightly so text is readable
        };
      };

      # misc.vfr = true;

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

      plugins = [
        # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprscrolling
        # "/absolute/path/to/plugin.so"
      ];

      # Keybindings
      bind = [
        # Core Apps
        "CTRL ALT, T, exec, ghostty"        # Terminal
        "$mod, E, exec, thunar"             # File Manager
        "$mod, SPACE, exec, rofi -show drun" # KRunner style launcher
        
        "$mod, B, exec, brave"

        # Window Management
        "ALT, F4, killactive,"                 # Traditional close
        "$mod, F, fullscreen,"               # Fullscreen
        "$mod, V, togglefloating,"           # Toggle Float
        
        # Session
        "$mod SHIFT, E, exit,"               # Log out

        # Screenshots
        ", Print, exec, grimblast copy area"
        "$mod, N, exec, swaync-client -t -sw"

        # Toggle Power Mode with F8
        ", F8, exec, power-toggle"

        # Focus Movement (Vim keys)
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Lock screen (SUPER + L)
        # We use loginctl so it properly registers with the system and hypridle
        "$mod, L, exec, loginctl lock-session"
        
        # Turn off screen (SUPER + Ç)
        # The 'sleep 1' is crucial. Without it, releasing the keys will immediately wake the screen back up.
        "$mod SHIFT, L, exec, sleep 1 && hyprctl dispatch dpms off"
        
        # Open power menu (SUPER + Escape)
        "$mod, Escape, exec, wlogout"

        ", XF86Display, exec, display-toggle"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

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
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  home.sessionVariables = {
    # Ensures GTK uses Wayland natively
    GDK_BACKEND = "wayland,x11";
  };

  home.packages = with pkgs; [
    swaynotificationcenter         # The notification daemon
    grimblast
    wl-clipboard # Clipboard utilities
    hyprsunset
    libnotify
    playerctl
    pavucontrol
    networkmanagerapplet
    brightnessctl
    jq
    power-toggle
    mic-toggle
    display-toggle

    # The lightweight standalone Qt engines
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
  ];

  programs = {
    wlogout.enable = true;

    rofi = {
      enable = true;
      theme = "fullscreen-preview";
      font = "sans-serif";
      package = pkgs.rofi;
      modes = [
        "drun"
        "run"
        "window"
        "ssh"  
      ];
      extraConfig = {
        show-icons = true;
      };
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };
        background = [
          {
            path = "~/.cache/daily-lockscreen.jpg"; # Takes a screenshot of your desktop to blur
            # blur_passes = 3;
            # blur_size = 8;
          }
        ];
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "eDP-1";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 24, 37)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
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
        modules-right = [ "mpris" "tray" "idle_inhibitor" "pulseaudio#slider" "bluetooth" "network" "battery" "clock" "custom/power" ];
        
        "custom/launcher" = {
          format = "   "; 
          on-click = "rofi -show drun"; 
        };

        "wlr/taskbar" = {
          format = " {icon} ";
          on-click = "activate";
          on-click-middle = "close";
        };

        "tray" =  {
          format = "  {icon}  ";
          on-click = "activate";
          on-click-middle = "close";
        };
        
        "clock" = {
          # Set interval to 1 so the seconds actually tick
          interval = 1;
          
          # The exact format: 14:30:05 | Saturday, 11 April 2026 | Timezone
          format = "{:%H:%M:%S | %A, %d %B %Y | %Z}";
          
          # Gives you a KDE-style full calendar when you hover over the clock
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            format = {
              # Injecting your green accent color into the calendar for today's date
              today = "<span color='#2ecc71'><b><u>{}</u></b></span>";
            };
          };
        };
        
        "battery" = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };
        
        "pulseaudio#slider" = {
          format = "{icon}  {volume}%";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
          drawer = {
            transition-duration = 500;
            children-class = "not-memory";
            transition-left-to-right = false;
          };
        };
        
        "mpris" = {
          format = " {player_icon} {title} - {artist} ";
          format-paused = "  {title} - {artist} ";
          player-icons = {
            default = "  ";
            brave = "  ";
            elisa = "  ";
          };
          status-icons = {
            paused = "  ";
          };
          max-length = 40;
        };

        "custom/power" = {
          format = "  ⏻  ";
          on-click = "wlogout";
          tooltip = false;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          tooltip = true;
          format-icons = {
            # You can change these icons to whatever you prefer (e.g., a coffee cup ☕)
            activated = ""; # Eye open (stay awake)
            deactivated = ""; # Eye closed (allow sleep)
          };
        };

        "bluetooth" = {
          # Default format when Bluetooth is on but not connected to anything
          format = " {status}";
          
          # Format when Bluetooth is turned off completely
          format-disabled = "󰂲 Disabled";
          
          # Format when connected to one or more devices
          format-connected = "󰂱 {num_connections}";
          
          # Tooltips show exactly what is connected when you hover over the icon
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          
          # Opens a graphical Bluetooth manager when you click the icon
          on-click = "blueman-manager"; 
        };
      };
    };

    # eww = {
    #   enable = true;
    #   package = pkgs.eww;
    #   enableZshIntegration = true;
    #   configDir = /. + builtins.getEnv("HOME");
    # };
  };

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          # The command to run when the session is locked
          lock_cmd = "pidof hyprlock || hyprlock";
          # Lock before the system suspends
          before_sleep_cmd = "loginctl lock-session";
          # Turn screens back on after waking up
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            # 1. Lock the screen after 5 minutes (300 seconds)
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            # 2. Turn off screens after 2 minutes (120 seconds)
            timeout = 120;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            # 3. Suspend the system after 15 minutes (900 seconds)
            timeout = 900;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "~/Pictures/Wallpapers/kde_space.jpg"
          "~/Pictures/Wallpapers/forest.png"
          "~/Pictures/Wallpapers/bad_math_bird.jpeg"
        ];
        wallpaper = [
          "eDP-1,~/Pictures/Wallpapers/kde_space.jpg"
          "HDMI-A-1,~/Pictures/Wallpapers/bad_math_bird.jpeg"
          ",~/Pictures/Wallpapers/forest.png"
        ];
      };
    };
  };

  systemd.user = {
    services.fetch-daily-lockscreen = {
      Unit = {
        Description = "Fetch daily image for Hyprlock";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash %h/.config/hypr/scripts/fetch-apod.sh";
      };
    };

    timers.fetch-daily-lockscreen = {
      Unit = {
        Description = "Run daily lockscreen fetcher";
      };
      Timer = {
        # Run once a day at midnight
        OnCalendar = "daily";
        # If the computer is off at midnight, run it immediately upon the next boot
        Persistent = true; 
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  xdg.configFile = {
    "hypr/scripts/fetch-apod.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Define paths
        CACHE_DIR="$HOME/.cache"
        IMG_PATH="$CACHE_DIR/daily-lockscreen.jpg"
        
        mkdir -p "$CACHE_DIR"

        # Fetch the daily data from NASA API using their public DEMO_KEY
        JSON_DATA=$(${pkgs.curl}/bin/curl -s "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")

        # Use jq to extract the media type and the high-res URL
        MEDIA_TYPE=$(echo "$JSON_DATA" | ${pkgs.jq}/bin/jq -r '.media_type')
        IMG_URL=$(echo "$JSON_DATA" | ${pkgs.jq}/bin/jq -r '.hdurl // .url')

        # NASA sometimes posts videos. Only download if it is an image.
        if [ "$MEDIA_TYPE" = "image" ] && [ "$IMG_URL" != "null" ]; then
            ${pkgs.curl}/bin/curl -s -L "$IMG_URL" -o "$IMG_PATH"
            echo "NASA APOD downloaded successfully."
        else
            echo "Today's APOD is a video or unavailable. Keeping yesterday's image."
        fi
      '';
    };

    "Kvantum/catppuccin-mocha-green".source = "${pkgs.catppuccin-kvantum.override {
      accent = "green";
      variant = "mocha";
    }}/share/Kvantum/catppuccin-mocha-green";

    # 2. Tell Kvantum to use the exact lowercase name
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-mocha-green
    '';

    "gtk-4.0/assets".source = "${pkgs.colloid-gtk-theme}/share/themes/Colloid-Green-Dark/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${pkgs.colloid-gtk-theme}/share/themes/Colloid-Green-Dark/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${pkgs.colloid-gtk-theme}/share/themes/Colloid-Green-Dark/gtk-4.0/gtk-dark.css";
  };
}