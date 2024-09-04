{ ... }:

{
  services.openvpn.servers.deivpn = {
    config = '' config /home/pleiades/vpn/deivpn.ovpn '';
    autoStart = false;
    authUserPass.username = "*****"; # to change
    authUserPass.password = "*****"; # to change
    updateResolvConf = true;
  };
}