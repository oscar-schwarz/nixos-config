{
  config,
  ...
}: {
  sops.secrets = {
    "ssh-keys/rsa_github_osipog/private" = {};
    "ssh-keys/rsa_github_os/private" = {};
  };

  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile ${config.getSopsFile "ssh-keys/rsa_github_osipog/private"}
      IdentitiesOnly yes

    Host os.github.com
      HostName github.com
      User git
      IdentityFile ${config.getSopsFile "ssh-keys/rsa_github_os/private"}
      IdentitiesOnly yes
  '';
}