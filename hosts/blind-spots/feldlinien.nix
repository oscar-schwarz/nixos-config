{ config, lib, pkgs, ... }:

{
  services.static-web-server = {
    enable = true;
    root = pkgs.fetchFromGitHub {
      owner = "OsiPog";
      repo = "feldlinien";
      rev = "ddb979678a8d7577d3d456325afbacf691bc13fc";
      hash = "sha256-zI3mPJh4dwIpneiVPpgVreWCXrzHq35rNNsPC1DqdUM=";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8787 ];
}