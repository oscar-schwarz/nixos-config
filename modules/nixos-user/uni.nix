username: {
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
  
  sops.secrets = {
    "other/uni-vpn-auth" = {};
    "ssh-keys/uni-gitlab/private" = {};
  };

  # --- VPN

  networking.openconnect.interfaces = {
    uni-leipzig-vpn = {
      # Start with `sudo systemctl start openconnect-uni-leipzig-vpn`
      autoStart = false;
      gateway = "vpn.uni-leipzig.de";
      protocol = "anyconnect";
      user = "zu66owol@uni-leipzig.de";
      passwordFile = config.getSopsFile "other/uni-vpn-auth";
    };
  };

  # --- ADD SSH CONFIG FOR GITLAB
  programs.ssh.extraConfig = ''
    Host git.informatik.uni-leipzig.de
      HostName git.informatik.uni-leipzig.de
      User git
      IdentityFile ${config.getSopsFile "ssh-keys/uni-gitlab/private"}
      IdentitiesOnly yes
  '';

  # --- BROWSER BOOKMARKS
  home-manager.users.${username}.programs.firefox.policies.Bookmarks = 
    lib.mkIf config.home-manager.users.${username}.programs.firefox.enable [
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
      {
        Title = "Vorlesungsverzeichnis Uni Leipzig Informatik";
        URL = "https://www.informatik.uni-leipzig.de/ifijung/10/service/stundenplaene/ss2025/inf-bachelor.html";
      }
      {
        Title = "Speiseplan MaP";
        URL = "https://www.studentenwerk-leipzig.de/mensen-cafeterien/speiseplan/?location=106";
      }
    ];
}
