{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  environment.systemPackages = [
    # Script to install the cert for eduroam uni leipzig
    inputs.eduroam.packages.${pkgs.system}.install-eduroam-leipzig
    pkgs.openconnect # for the vpn
  ];

  # --- VPN

  # add the secret for the vpn
  sops.secrets."other/uni-leipzig-vpn-auth" = {};

  networking.openconnect.interfaces = {
    uni-leipzig-vpn = {
      # Start with `sudo systemctl start openconnect-uni-leipzig-vpn`
      autoStart = false;
      gateway = "vpn.uni-leipzig.de";
      protocol = "anyconnect";
      user = "zu66owol@uni-leipzig.de";
      passwordFile = config.getSopsFile "other/uni-leipzig-vpn-auth";
    };
  };

  # --- BROWSER BOOKMARKS
  home-manager.sharedModules = [({ config, lib, ... }: {
    programs.firefox.policies.Bookmarks = lib.mkIf config.programs.firefox.enable [
        {
          Title = "Moodle Uni Leipzig";
          URL = "https://moodle2.uni-leipzig.de/my/courses.php";
        }
        {
          Title = "GitLab Uni Leipzig";
          URL = "https://git.informatik.uni-leipzig.de/";
        }
        {
          Title = "Almaweb";
          URL = "https://almaweb.uni-leipzig.de/";
        }
        {
          Title = "Tool Uni Leipzig";
          URL = "https://tool.uni-leipzig.de/";
        }
      ];
  })];
}