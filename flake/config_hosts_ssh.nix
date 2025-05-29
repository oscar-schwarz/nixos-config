{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (builtins) fromJSON readFile attrValues getAttr attrNames;
  inherit (lib) pipe attrsToList concatLines mapAttrs filterAttrs listToAttrs;
  fromYAML = import ../lib/from-yaml.nix pkgs;

  hostDefinitions = import ../hosts.nix;

  authorizedHosts = pipe config.sops.defaultSopsFile [
    # convert yaml file to attrset
    readFile
    fromYAML

    # only the `authorized_hosts` key is interesting
    (set: set.authorized-hosts or {})

    attrNames
  ];

  # authorized ssh public keys derived from authorized hosts and sops
  authorizedKeyFiles = map (name: config.getSopsFile "authorized-hosts/${name}") authorizedHosts;
in {
  # the private ssh key of the host and all public ssh keys of other hosts
  sops.secrets = pipe authorizedHosts [
      (map (hostname: {
        name = "authorized-hosts/${hostname}";
        value = {mode = "0444";};
      }))

      listToAttrs
    ];

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

  system.activationScripts = {
    setupAuthorizedKeys = {
      # Run after we have the sops secrets
      # puts each public key from the `authorizedHosts` set in /etc/ssh/authorized_keys
      deps = ["setupSecrets"];
      text = ''
        # --- clear file
        : > /etc/ssh/authorized_keys
      '' + (pipe authorizedKeyFiles [
        (map (file: "cat ${file} >> /etc/ssh/authorized_keys"))
        concatLines
      ]);
    };
  };
}
