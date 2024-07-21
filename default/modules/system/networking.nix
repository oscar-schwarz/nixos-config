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
      ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };
  };
}
