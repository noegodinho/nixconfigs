# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs-unstable, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vpn.nix
    ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.luks.devices."luks-4330ca1e-a192-4c36-be45-3a5dc91b02a4".device = "/dev/disk/by-uuid/4330ca1e-a192-4c36-be45-3a5dc91b02a4";
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "laniakea"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
    };
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "pt";
      variant = "";
    };
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Enable the KDE Plasma Desktop Environment.
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    ];
  };

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    # allow proprietary packages
    allowUnfree = true;

    packageOverrides = pkgs: {
      intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    };

    # packageOverrides = super: let self = super.pkgs; in {
    #   subtitleeditor = super.subtitleeditor.overrideAttrs (attrs: {
    #     buildInputs = attrs.buildInputs ++ [
    #       self.gst_all_1.gst-plugins-bad
    #       self.gst_all_1.gst-plugins-ugly
    #       self.gst_all_1.gst-libav
    #     ];
    #   });
    # };
  };

  # Nix garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Autoupgrade system
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = false; # decide later
  };

  # Enable CUPS to print documents.
  services.printing = {
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # hardware.printers = {
  #   ensurePrinters = [
  #     {
  #       name = "printer-hall-2";
  #       location = "DEI Main Hall";
  #       deviceUri = "http://ipp.dei.uc.pt/printers/printer-hall-2";
  #       model = "drv:///home/andromeda/printer_drivers/KMbeu750iux.ppd";
  #       ppdOptions = {
  #         PageSize = "A4";
  #       };
  #     }
  #   ];
  #   ensureDefaultPrinter = "printer-hall-2";
  # };

  # enables support for Bluetooth & powers up the default Bluetooth controller on boot
  hardware.bluetooth = {
    enable = true;
    package = nixpkgs-unstable.legacyPackages."${pkgs.system}".bluez;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        JustWorksRepairing = "always";
      };
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "-";
      item = "rtprio";
      value = "99";
    }
  ];

  # Man docs
  documentation = {
    enable = true;
    man = {
      enable = true;
      man-db.enable = false;
      mandoc.enable = true;
      generateCaches = true;
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "andromeda";

  users.users.andromeda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Andromeda";
    extraGroups = [ "input" "networkmanager" "wheel" ];
    # packages = with pkgs; [
        # kdePackages.kate
    # ];
  };

  # Enable zsh
  programs.zsh.enable = true;

  # Allows dynamically linked executables to be run on nixos
  # Only possible to use x86_64 executables
  programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
    # Avoid using conda-shell and having direct access to conda -> useful for vscodium
    # python312Packages.conda
  # ];

  # Steam settings (installed in lutris)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # BPF-based Linux IO analysis, networking, monitoring, and more
  programs.bcc.enable = true;

  # fingerprint drivers
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pcsclite
    qemu # for VMs
    quickemu # for easy VM management
  ];

  # In case I need docker
  # virtualisation.docker.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Exclude KDE & system packages
  environment.plasma6.excludePackages = with pkgs; [
    khelpcenter
    kdePackages.kate
  ];

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  # "Driver" for MX Master 3S
  hardware.logitech.wireless.enable = true;
  services.solaar = {
    enable = true; # Enable the service
    package = pkgs.solaar; # The package to use
    window = "hide"; # Show the window on startup (show, *hide*, only [window only])
    batteryIcons = "regular"; # Which battery icons to use (*regular*, symbolic, solaar)
    extraArgs = ""; # Extra arguments to pass to solaar on startup
  };

  # Enable flatpak for sandboxed applications
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Smart card reader driver
  services.pcscd.enable = true;

  # Firmware and BIOS updates
  services.fwupd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
