{ user, ... }:

{
  services.openvpn.servers.deivpn = {
    config = '' config /home/${user}/vpn/deivpn.ovpn '';
    autoStart = false;
    authUserPass.username = "*****";
    authUserPass.password = "*****";
    updateResolvConf = true;
  };
}