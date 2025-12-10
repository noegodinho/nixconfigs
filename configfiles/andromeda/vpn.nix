{ user, ... }:

{
  services.openvpn.servers.deivpn = {
    config = '' config /home/${user}/vpn/DEI.ovpn '';
    autoStart = false;
    # authUserPass.username = "*****";
    # authUserPass.password = "*****";
    updateResolvConf = true;
  };
}