{ config, lib, pkgs, ... }:

{
  networking.hostName = "milkyway"; # Define your hostname.

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;

  # hardware.bumblebee.enable = true; # check if needed in pc when installing

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  system.autoUpgrade.allowReboot = false; # decide later
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
