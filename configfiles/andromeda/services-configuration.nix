{ pkgs, nixpkgs-unstable, ... }:
{
  services = {
    # Enable touchpad support (enabled default in most desktopManager)
    # ibinput.enable = true;
    libinput.touchpad.naturalScrolling = true;

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
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      cups-pdf.enable = true;
      logLevel = "debug2";

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
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-vfs0090;
      };
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

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}