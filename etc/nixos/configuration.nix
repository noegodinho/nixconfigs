# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./general.nix
      #./pleiades.nix
      ./albireo.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  boot.initrd.luks.devices."luks-7d558d87-f2cb-464f-9cbd-6241bcaf7ccb".device = "/dev/disk/by-uuid/7d558d87-f2cb-464f-9cbd-6241bcaf7ccb";
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk=true;

  boot.initrd.luks.devices."luks-6f07271f-3ae4-4343-84f6-68fa027b4a13".keyFile = "/crypto_keyfile.bin";
  boot.initrd.luks.devices."luks-7d558d87-f2cb-464f-9cbd-6241bcaf7ccb".keyFile = "/crypto_keyfile.bin";
}
