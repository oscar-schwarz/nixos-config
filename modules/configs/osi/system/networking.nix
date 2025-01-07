{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    # Script to install the cert for eduroam uni leipzig
    eduroam.install-eduroam-leipzig

    openconnect
  ];
  networking = {
    networkmanager = {
      enable = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        9003
        3000
        5173
      ];
      allowedUDPPorts = [
        51820
      ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };

    openconnect.interfaces = {
      uni-leipzig-vpn = {
        # Start with `sudo systemctl start openconnect-uni-leipzig-vpn`
        autoStart = false;
        gateway = "vpn.uni-leipzig.de";
        protocol = "anyconnect";
        user = "zu66owol@uni-leipzig.de";
        passwordFile = config.osi.getSecretFile "uniLeipzigVPNAuth";
      };
    };

    wireguard.interfaces = {
      sculk = {
        ips = [ "101.201.4.201/24" ]; # IP address and subnet of tunnel interface
        listenPort = 51820; # matching allowedUDPPorts above, if not specified it would be random

        privateKeyFile = config.osi.getSecretFile "wireguardPrivateKey";

        peers = [{
          publicKey = "Gvopl/jY8K+xHpUTntg9R4CG++RXyJ2hV1QsNcyVUBE=";
          presharedKey = "kHMEmT/Pr1suWRAZaA2zKGKp+dKeDJnLql2W/V3wGpk=";
          allowedIPs = [ "101.201.4.0/24" "0.0.0.0/0" ]; # route all traffic through vpn
          endpoint = "h8wkgwwxnvy0ut4t.myfritz.net:56491";
          persistentKeepalive = 25;
        }];
      };
    };
  };
}
