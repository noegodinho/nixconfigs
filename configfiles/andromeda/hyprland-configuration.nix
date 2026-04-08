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

    if [ -z "$IS_MIRRORED" ]; then
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
        "surfshark"
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
        "$mod, E, exec, dolphin"             # File Manager
        "$mod, SPACE, exec, rofi -show drun" # KRunner style launcher
        
        "$mod, B, exec, brave --password-store=kwallet6 --ozone-platform-hint=auto"

        # Window Management
        "$mod, Q, killactive,"               # Close Window (KDE allows Alt+F4 too, but this is standard)
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
          format = "{:%I:%M %p  %a, %b %d}";
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
      };
    };
  };

  # eww = {
  #   enable = true;
  #   package = pkgs.eww;
  #   enableZshIntegration = true;
  #   configDir = /. + builtins.getEnv("HOME");
  # };
}