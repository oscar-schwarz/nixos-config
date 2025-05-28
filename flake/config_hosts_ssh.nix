{
  lib,
  config,
  ...
}: let
  inherit (builtins) fromJSON readFile attrValues getAttr;
  inherit (lib) pipe attrsToList concatLines mapAttrs filterAttrs;

  hostDefinitions = import ../hosts.nix;

  # authorizedHosts = pipe (config.sops.defaultSopsFile) [
  #   # convert json file to attrset
  #   readFile
  #   fromJSON

  #   # only the `authorized_hosts` key is interesting
  #   (set: set.authorized_hosts or {})
  # ];
in {
  # the private ssh key of the host and all public ssh keys of other hosts
  # sops.secrets =
  #   {
  #     "ssh-keys/host-${config.hosts.this.name}/private" = {};
  #   }
  #   // (pipe hostDefinitions [
  #     attrNames

  #     (map (hostName: {
  #       name = "ssh-keys/host-${hostName}/public";
  #       value = {mode = "0444";};
  #     }))

  #     listToAttrs
  #   ]);

  # Set up ssh keys, you should be able to ssh into another host using its hostname at all times
  programs.ssh.extraConfig = pipe hostDefinitions [
    (mapAttrs (hostname: host: ''
      Host ${hostname}
        HostName ${hostname}
        IdentityFile /etc/ssh/id_ed25519
        IdentitiesOnly Yes
    ''))

    attrValues

    concatLines
  ];

  # system.activationScripts = {
  #   setupAuthorizedKeys = {
  #     # Run after we have the sops secrets
  #     # puts each public key from the `authorizedHosts` set in /etc/ssh/authorized_keys
  #     deps = ["setupSecrets"];
  #     text = ''
  #       cat > /etc/ssh/authorized_keys << EOF
  #     '' + (pipe authorizedHosts [
  #       attrValues
  #       concatLines
  #     ]) + ''
  #         EOF
  #     '';
  #   };
  # };
}
