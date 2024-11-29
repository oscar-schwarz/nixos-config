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
        80
      ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };

    openconnect.interfaces = {
      uni-leipzig-vpn = {
        autoStart = false;
        gateway = "vpn.uni-leipzig.de";
        protocol = "anyconnect";
        user = "zu66owol@uni-leipzig.de";
        passwordFile = config.osi.getSecretFile "uniLeipzigVPNAuth";
      };
    };
  };
}
