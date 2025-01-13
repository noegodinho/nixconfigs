# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, nixpkgs-unstable, ... }:
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services-configuration.nix
    ./vpn.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "thinkpad_acpi" ];
    initrd.luks.devices."luks-4330ca1e-a192-4c36-be45-3a5dc91b02a4".device = "/dev/disk/by-uuid/4330ca1e-a192-4c36-be45-3a5dc91b02a4";
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    # Define your hostname.
    hostName = "laniakea";

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Enable networking
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

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

  # Configure console keymap
  console.keyMap = "pt-latin1";

  hardware = { 
    # Update the Intel microcode on boot.
    cpu.intel.updateMicrocode = true;

    # Graphic drivers
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };

    # enables support for Bluetooth & powers up the default Bluetooth controller on boot
    bluetooth = {
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
    pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem

    # Enable logitech wireless mouse
    logitech.wireless.enable = true;

    # printers = {
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
  };

  nix = {
    # Nix settings
    settings.experimental-features = [ 
      "nix-command" "flakes" 
    ];

    # Nix garbage collector
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config = {
    # allow proprietary packages
    allowUnfree = true;

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

  # Autoupgrade system
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = false; # decide later
  };

  security = {
    # Enable real-time sound
    rtkit.enable = true;

    # Disable OS limits
    pam.loginLimits = [
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
  };

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

  users.users.andromeda = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Andromeda";
    extraGroups = [ "input" "networkmanager" "video" "wheel" ];
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

  # enable KDE PIM suite
  programs.kde-pim = {
    enable = true;
    merkuro = true;
  };

  # Steam settings (installed in lutris)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # BPF-based Linux IO analysis, networking, monitoring, and more
  programs.bcc.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      pcscliteWithPolkit = prev.pcscliteWithPolkit.overrideAttrs(oldAttrs: {
        version = "2.1.0";
        
        src = pkgs.fetchFromGitLab {
          domain = "salsa.debian.org";
          owner = "rousseau";
          repo = "PCSC";
          rev = "refs/tags/${oldAttrs.version}";
          hash = "sha256-hKyxXqZaqg8KGFoBWhRHV1/50uoxqiG0RsYtgw2BuQ4=";
        };
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
