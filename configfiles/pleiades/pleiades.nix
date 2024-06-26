{ config, lib, pkgs, ... }:

{
  networking.hostName = "milkyway"; # Define your hostname.

  boot.supportedFilesystems = [ "ntfs" ];

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

  # Power management and CPU frequency scaling.
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        RUNTIME_PM_ON_AC = auto;
        RUNTIME_PM_ON_BAT = auto;

        # Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
};

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

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  # hardware.bumblebee.enable = true; # check if needed in pc when installing 

  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:3:0:0";

    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };

  # Is it necessary?
  # specialisation = {
  #   on-the-go.configuration = {
  #     system.nixos.tags = [ "on-the-go" ];
  #     hardware.nvidia = {
  #       prime.offload.enable = lib.mkForce true;
  #       prime.offload.enableOffloadCmd = lib.mkForce true;
  #       prime.sync.enable = lib.mkForce false;
  #     };
  #   };
  # };

  # fingerprint
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
      # driver = pkgs.libfprint-2-tod1-goodix; # (On my device it only worked with this driver)
    };
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "pleiades";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  documentation = {
    enable = true;
    man = {
      enable = true;
      man-db.enable = false;
      mandoc.enable = true;
      generateCaches = true;
    };
  };

  users.users.pleiades = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Pleiades";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  # programs.steam.package = pkgs.steam.override {
  #    withPrimus = true;  # invalid?
  #    withJava = true;    # invalid?
  #    extraPkgs = pkgs: [ bumblebee glxinfo ];
  # };

  # allows dynamically linked executables to be run on nixos
  # only possible to use x86_64 executables
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # avoid using conda-shell and having direct access to conda -> useful for vscodium
    python312Packages.conda
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
     vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        james-yu.latex-workshop
        mechatroner.rainbow-csv
        ms-python.isort
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.makefile-tools
        twxs.cmake
        #visualstudioexptteam.vscodeintellicode
        yzhang.markdown-all-in-one
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
           {
                name = "better-cpp-syntax";
                publisher = "jeff-hykin";
                version = "1.17.2";
                sha256 = "p3SKu9FbtuP6in2dSsr5a0aB5W+YNQ0kMgMJoDYrhcU=";
           }
           {
                name = "languague-renpy";
                publisher = "luquedaniel";
                version = "2.3.6";
                sha256 = "ubMtLCIs3C8UBrXr1vr3Kqm2K3B8wNlm/THftVyIDug=";
           }
           {
                name = "doxdocgen";
                publisher = "cschlosser";
                version = "1.4.0";
                sha256 = "InEfF1X7AgtsV47h8WWq5DZh6k/wxYhl2r/pLZz9JbU=";
           } 
           {
                name = "latex-utilities";
                publisher = "tecosaur";
                version = "0.4.14";
                sha256 = "GsbHzFcN56UbcaqFN9s+6u/KjUBn8tmks2ihK0pg3Ds=";
           }       
      ];
    })
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    ark
    khelpcenter
  ];
  
  # security.pam.services.kde.enableKwallet = false;
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };

  services.flatpak.packages = [
    { appId = "com.brave.Browser"; origin = "flathub"; }
    { appId = "org.telegram.desktop"; origin = "flathub"; }
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
  system.stateVersion = "24.05"; # Did you read the comment?
}
