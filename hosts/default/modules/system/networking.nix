{ config, pkgs, ...}:

{
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        
      };
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