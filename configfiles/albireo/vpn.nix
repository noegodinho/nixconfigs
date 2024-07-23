{ config, lib, pkgs, ... }:

{
  services.openvpn.servers.deivpn = {
    config = '' config /home/albireo/vpn/deivpn.ovpn '';
    autoStart = false;
    authUserPass.username = "*****"; # to change
    authUserPass.password = "*****"; # to change
    updateResolvConf = true;
  };
}