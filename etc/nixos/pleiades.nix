{ config, lib, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

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

  # fprintd-enroll
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
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "pleiades";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;  

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

  # services.xserver.enable = false;
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "pt";
    xkbVariant = "";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.pleiades = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Pleiades";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kate
      neovim
      zellij
      conda
      keepass
      thunderbird
      # kmail # decide which one to use
      ktorrent
      skypeforlinux
      zotero
      slack
      musescore
      pympress
      dropbox
      # maestral # decide which one to use
      veracrypt
      duplicati # http://localhost:8200/
      gphoto2
      vlc
      pcsxr
      itch
      rare
      renpy
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

  programs.firefox.enable = false;
  programs.hyprland.enable = false; # change later to true
  programs.java.enable = true;
  programs.solaar.enable = true;
  programs.adb.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  };

  # programs.steam.package = pkgs.steam.override {
  #    withPrimus = true;  # invalid?
  #    withJava = true;    # invalid?
  #    extraPkgs = pkgs: [ bumblebee glxinfo ];
  # };

  programs.steam.gamescopeSession.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gcc
    gdb
    gnumake
    valgrind
    wget
    usbutils
    fh
    unzip
    zip
    gzip
    rar
    unrar
    gnutar
    jre8
    ffmpeg
    bat
    atuin
    fzf
    htop
    btop
    nvtopPackages.nvidia
    nvtopPackages.intel
    undervolt
    lm_sensors
    smartmontools
    fusuma
    lshw
    glxinfo
    pciutils
    linuxKernel.packages.linux_zen.turbostat
    wineWowPackages.waylandFull # wineWowPackages.full
    winetricks
    yabridge
    protonup-qt
    bubblewrap
    
    libreoffice-qt
    hunspell
    hunspellDicts.pt_PT
    hunspellDicts.en_GB-ise

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

    (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
        ];

        extraLibraries =  pkgs: [
          # List library dependencies here
        ];
     })
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # Default value
  };

  services.flatpak.packages = [
    { appId = "com.brave.Browser"; origin = "flathub";  }
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
}
