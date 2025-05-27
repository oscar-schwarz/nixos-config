{
  lib,
  config,
  ...
}: let
  inherit (builtins) concatStringsSep listToAttrs elem filter attrNames attrValues;
  inherit (lib) pipe attrsToList concatLines mapAttrs;

  hostDefinitions = import ../hosts.nix;
in {
  # the private ssh key of the host and all public ssh keys of other hosts
  sops.secrets =
    {
      "ssh-keys/host-${config.hosts.this.name}/private" = {};
    }
    // (pipe hostDefinitions [
      attrNames

      (map (hostName: {
        name = "ssh-keys/host-${hostName}/public";
        value = {mode = "0444";};
      }))

      listToAttrs
    ]);

  # Set up ssh keys, you should be able to ssh into another host using its hostname at all times
  programs.ssh.extraConfig = pipe hostDefinitions [
    (mapAttrs (hostName: host: ''
      Host ${hostName}
        HostName ${host.ip-address}
        IdentityFile /etc/ssh/id_ed25519
        IdentitiesOnly Yes
    ''))

    attrValues

    concatLines
  ];
}
