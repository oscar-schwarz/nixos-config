username: {
  config,
  ...
}: {
  sops.secrets = {
    "ssh-keys/gh-primary/private" = {owner = username;};
    "ssh-keys/gh-secondary/private" = {owner = username;};
    "ssh-keys/ag-link/private" = {owner = username;};
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

    Host ag-link-hyperjump
      HostName hyperjump.reudnetz.org
      ServerAliveInterval 15
      Port 21016
      User osi
      IdentityFile ${config.getSopsFile "ssh-keys/ag-link/private"}
      IdentitiesOnly yes

    # Allow overwriting the values above
    Include ${config.home-manager.users.${username}.home.homeDirectory}/.ssh/config
  '';
}
