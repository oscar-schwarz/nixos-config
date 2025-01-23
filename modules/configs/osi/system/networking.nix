{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    # Script to install the cert for eduroam uni leipzig
    eduroam.install-eduroam-leipzig

    openconnect
  ];

  networking = let 
    wireguardPort = 51820;
  in {
    networkmanager = {
      enable = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        54112 # Vscode extension services
      ];
      allowedUDPPorts = [
        wireguardPort
      ];
      # allowedUDPPortRanges = [
      #   { from = 4000; to = 4007; }
      #   { from = 8000; to = 8010; }
      # ];
    };

    openconnect.interfaces = {
      uni-leipzig-vpn = {
        # Start with `sudo systemctl start openconnect-uni-leipzig-vpn`
        autoStart = false;
        gateway = "vpn.uni-leipzig.de";
        protocol = "anyconnect";
        user = "zu66owol@uni-leipzig.de";
        passwordFile = config.getSopsFile "other/uni-leipzig-vpn-auth";
      };
    };

    wireguard.interfaces = {
      sculk = {
        ips = [ "10.12.21.201/24" ]; # IP address and subnet of tunnel interface
        listenPort = wireguardPort; # if not specified it would be random

        privateKeyFile = config.getSopsFile "wireguard/biome-fest/private-key";

        peers = [{
          name = "fritzbox";
          publicKey = "9NEq+5caoXWXidnDeizGKaii0/1RZ1Ho0qICRybSIQE=";
          presharedKeyFile = config.getSopsFile "wireguard/biome-fest/psk";
          # Route all traffic in the specific subnet through the tunnel
          # allowedIPs = [ "10.12.21.0/24" ];
          # this here would route ALL traffic through the tunnel
          # Problem: if the tunnel is blocked, no internet access at all is possible
          allowedIPs = [ "10.12.21.0/24" "0.0.0.0/0" ]; 
          endpoint = "h8wkgwwxnvy0ut4t.myfritz.net:54241";
          persistentKeepalive = 25;
        }];
      };
    };
  };
}
