{ config, lib, pkgs, ... }:

{
  networking.hostName = "milkyway"; # Define your hostname.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "pt";
    xkb.variant = "";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # hardware.pulseaudio = {
  #  enable = true;
  #  package = pkgs.pulseaudioFull;
  #  extraConfig = "load-module module-switch-on-connect";
  #  configFile = pkgs.writeText "default.pa" ''
  #     load-module module-bluetooth-policy
  #     load-module module-bluetooth-discover
       ## module fails to load with 
       ##   module-bluez5-device.c: Failed to get device path from module arguments
       ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
       # load-module module-bluez5-device
       # load-module module-bluez5-discover
  #     '';
  # };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
 
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  nixpkgs.config = {
    # allow proprietary packages
    allowUnfree = true;

    packageOverrides = super: let self = super.pkgs; in {
      subtitleeditor = super.subtitleeditor.overrideAttrs (attrs: {
        buildInputs = attrs.buildInputs ++ [
          self.gst_all_1.gst-plugins-bad
          self.gst_all_1.gst-plugins-ugly
          self.gst_all_1.gst-libav
        ];
      });
    };
  };

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  system.autoUpgrade.allowReboot = false; # decide later

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "albireo";

  # Enable CUPS to print documents.
  services.printing.enable = false;  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.albireo = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Albireo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # git
      # gcc
      # gdb
      # gnumake
      # valgrind
      # wget
      # usbutils
      # fh
      # unzip
      # zip
      # gzip
      # p7zip
      # xz
      # rar
      # file
      # which
      # tree
      # gnused
      # gawk
      # zstd
      # gnupg
      # direnv
      # gnutar
      # bat
      # atuin
      # fzf
      # htop
      # btop
      # undervolt
      # lm_sensors
      # fusuma
      # lshw
      # ffmpeg
      # neovim
      # zellij
      # kate
    ];
  };

  programs.zsh = {
       enable = true;
       autosuggestions.enable = true;
       syntaxHighlighting.enable = true;
       enableCompletion = false;
       ohMyZsh = {
           enable = true;
           plugins = [
                "git" 
           ];
       };
  };
  
  programs.firefox.enable = true;
  programs.java.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
  ];

  services.flatpak.packages = [
    # { appId = "com.brave.Browser"; origin = "flathub"; }
  ];
}
