{...}:

let
  ipWithSubnet = "99.0.0.1/10";
  udpPort = 50000; 
in {
  networking.nat = {
    enable = true;
    externalInterface = "enp7s0";
    internalInterface = [ "redstone-dust" ];
  };

  networking.firewall.allowedUDPPorts = [ udpPort ];

  networking.wireguard.interfaces = {
    redstone-dust = {
      ips = [ ipWithSubnet ];
      listenPort = udpPort;
    };
  };
}