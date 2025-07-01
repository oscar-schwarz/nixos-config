username: {
  config,
  ...
}: {
  sops.secrets = {
    "ssh-keys/gh-primary/private" = {owner = username;};
    "ssh-keys/gh-secondary/private" = {owner = username;};
  };

  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile ${config.getSopsFile "ssh-keys/gh-primary/private"}
      IdentitiesOnly yes

    Host secondary.github.com
      HostName github.com
      User git
      IdentityFile ${config.getSopsFile "ssh-keys/gh-secondary/private"}
      IdentitiesOnly yes

    # Allow overwriting the values above
    Include /etc/ssh/config_imperative
  '';
}
