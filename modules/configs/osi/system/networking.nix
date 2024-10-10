{ ... }:

{
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
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # For KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
        { from = 1714; to = 1764; } # For KDE Connect
      ];
    };
  };
}
