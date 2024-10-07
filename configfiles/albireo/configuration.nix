# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';
    
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

  networking.hostName = "milkyway"; # Define your hostname.

  services.libinput.touchpad.naturalScrolling = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_PT.UTF-8";

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
  services.displayManager.defaultSession = "plasmax11";
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = false; # enables support for Bluetooth
  
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  system.autoUpgrade.allowReboot = false;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "albireo";

  # Enable CUPS to print documents.
  services.printing.enable = false; 

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.albireo = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Albireo";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  programs.zsh.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    khelpcenter
    print-manager
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
