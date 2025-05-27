{
  config,
  username,
  ...
}: {
  sops.secrets = {
    "ssh-keys/rsa_github_osipog/private" = {owner = username;};
    "ssh-keys/rsa_github_os/private" = {owner = username;};
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

    # Allow overwriting the values above
    Include ${config.home-manager.users.${username}.home.homeDirectory}/.ssh/config
  '';
}