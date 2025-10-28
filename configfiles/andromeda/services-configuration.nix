{ pkgs, nixpkgs-unstable, ... }:
let
  papercutClient = pkgs.callPackage ./papercut.nix { };
  deiPPDPackage = pkgs.callPackage ./ppd_dei.nix { };
in
{
  services = {
    # Enable touchpad support (enabled default in most desktopManager)
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.tapping = false;
    };

    xserver = {
      # Enable the X11 windowing system
      # You can disable this if you're only using the Wayland session
      enable = true;
      
      # Configure keymap in X11
      xkb = {
        layout = "pt";
        variant = "";
      };
      
      # Packages to exclude from xserver
      excludePackages = with pkgs; [
        xterm
      ];
    };

    # Enable the KDE Plasma Desktop Environment.
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      
      # Enable automatic login for the user.
      autoLogin = {
        enable = true;
        user = "andromeda";
      };

      # Set the default session for autologin
      defaultSession = "plasma";
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      webInterface = true;
      logLevel = "debug2";
      drivers = [ deiPPDPackage ];

      browsed.enable = false;
      listenAddresses = [ "127.0.0.1:631" ];

      # ----------------------------------------------------
      # ADD THIS BLOCK TO FIX THE AUTHENTICATION LOOP
      # ----------------------------------------------------
      extraConf = ''
        # Grant admin rights to the lpadmin group
        SystemGroup lpadmin wheel
      '';
      
      cups-pdf = {
        enable = true;
        
        instances = {
          pdf = {
            enable = true;
            settings = {
              # Output directory for generated PDFs
              Out = "\${HOME}/cups-pdf";
            };
          };
        };
      };

      # drivers = [
      #   (pkgs.writeTextDir "share/cups/model/KMbeu750iux.ppd" (builtins.readFile /home/andromeda/printer_drivers/KMbeu750iux.ppd))
      # ];

      # extraConf = ''
      #   Browsing Yes
      #   DefaultShared Yes
      #   DefaultAuthType Basic
      #   WebInterface Yes
      # '';
      # extraFilesConf = ''
      #   RemoteRoot noe
      # '';
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem

    # Sound service
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Fingerprint drivers
    fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
    };

    # "Driver" for MX Master 3S
    solaar = {
      enable = true;
      package = nixpkgs-unstable.legacyPackages."${pkgs.system}".solaar;
      # Show the window on startup (show, *hide*, only [window only])
      window = "hide";
      # Which battery icons to use (*regular*, symbolic, solaar)
      batteryIcons = "regular";
      # Extra arguments to pass to solaar on startup
      extraArgs = "";
    };

    # Enable flatpak for sandboxed applications
    flatpak.enable = true;

    # Smart card reader driver
    pcscd.enable = true;

    # Firmware and BIOS updates
    fwupd = {
      enable = true;
      package = pkgs.fwupd;
    };

    # Detailed fan control
    # thinkfan = {
    #   enable = true;
    #   levels = [
    #     [0    0      4]
    #     [1    35     4]
    #     [2    38     4]
    #     [3    42     5]
    #     [4    45     5]
    #     [5    48     6]
    #     [6    51     6]
    #     [7    54     6]
    #     [8    56     7]
    #     [9    58    99]
    #   ];
    # };

    # Enable the OpenSSH daemon.
    # openssh.enable = true;
  };

  # 6. Auto-start the PaperCut Client
  # This creates a systemd service to run the client for your user.
  # The client MUST be running to print

  systemd.services = {
    "papercut-client" = {
      description = "PaperCut User Client";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        # Run as your user
        User = "noe";

        # Required for the client's GUI to appear
        Environment = "DISPLAY=:0";
        
        # Path to the executable from the package we made
        ExecStart = "${papercutClient}/bin/papercut-client"; 
        
        # Restart if it crashes
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
