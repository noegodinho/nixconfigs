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
        "swaynotificationcenter"                  # Launch the notification daemon
        "hyprpaper"             # Launch the wallpaper daemon
        "/usr/lib/polkit-kde-authentication-agent-1" # Polkit agent
        # Crucial for KWallet/Brave communication
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=KDE"
        # Start the wallet daemon if it's not already running
        "kwalletd6"
        "com.surfshark.Surfshark"
        "hyprsunset -t 4000"
        "nm-applet --indicator"
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
        "col.inactive_border" = "rgba(595959aa)";
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
        
        "$mod, B, exec, brave --password-store=kwallet6 --ozone-platform-hint=auto"

        # Window Management
        "ALT, F4, killactive,"                 # Traditional close
        "$mod, F, fullscreen,"               # Fullscreen
        "$mod, V, togglefloating,"           # Toggle Float
        
        # Session
        "$mod SHIFT, E, exit,"               # Log out

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, N, exec, swaync-client -t -sw"

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

        # Lock screen (SUPER + L)
        # We use loginctl so it properly registers with the system and hypridle
        "$mod, L, exec, loginctl lock-session"
        
        # Turn off screen (SUPER + Ç)
        # The 'sleep 1' is crucial. Without it, releasing the keys will immediately wake the screen back up.
        "$mod SHIFT, L, exec, sleep 1 && hyprctl dispatch dpms off"
        
        # Open power menu (SUPER + Escape)
        "$mod, Escape, exec, wlogout"

        ", XF86Display, exec, display-toggle"
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
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  home.packages = with pkgs; [
    rofi         # The application launcher
    swaynotificationcenter         # The notification daemon
    grim         # For screenshots
    slurp        # For selecting screen regions
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
  ];

  programs = {
    wlogout.enable = true;

    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };
        background = [
          {
            path = "screenshot"; # Takes a screenshot of your desktop to blur
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
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
        modules-left = [ "custom/power" "custom/launcher" "wlr/taskbar" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "tray" "mpris" "pulseaudio#slider" "network" "battery" "clock" ];
        
        "custom/launcher" = {
          format = "  "; 
          on-click = "rofi -show drun"; 
        };

        "wlr/taskbar" = {
          format = "{icon}";
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
          format = "{player_icon} {title} - {artist}";
          format-paused = " {title} - {artist}";
          player-icons = {
            default = "";
            brave = "";
            elisa = "";
          };
          status-icons = {
            paused = "";
          };
          max-length = 40;
        };

        "custom/power" = {
          format = "⏻";
          on-click = "wlogout";
          tooltip = false;
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

  services.hypridle = {
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
          # 2. Turn off screens after 5.5 minutes (330 seconds)
          timeout = 330;
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
}