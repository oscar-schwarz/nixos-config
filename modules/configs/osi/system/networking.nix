{ pkgs, ... }:

{
  environment.systemPackages = [
    # Script to install the cert for eduroam uni leipzig
    pkgs.eduroam.install-eduroam-leipzig
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
  };
}
