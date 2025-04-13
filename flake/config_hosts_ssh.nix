{ 
  lib,
  config, 
  ... 
}: let
  hostDefinitions = import ../hosts.nix;

  inherit (lib.attrsets) mapAttrs;
  inherit (lib) attrsToList attrNames;
  inherit (builtins) concatStringsSep listToAttrs elem filter;

in {
  # the private ssh key of the host and all public ssh keys of other hosts
  sops.secrets = {
    "ssh-keys/host-${config.hosts.this.name}/private" = {};
  } // (
    hostDefinitions
      |> attrNames
      |> map (hostName: {
        name = "ssh-keys/host-${hostName}/public";
        value = {mode = "0444";};
      })
      # transforms back to an attribute set
      |> listToAttrs
  );

  # Set up ssh keys, you should be able to ssh into another host using its hostname at all times
  programs.ssh.extraConfig = hostDefinitions
    |> mapAttrs (hostName: host: ''
      Host ${hostName}
        HostName ${host.ip-address}
        IdentityFile ${config.getSopsFile "ssh-keys/host-${config.hosts.this.name}/private"}
    '')
    |> attrsToList |> map (e: e.value) # getting a list of values
    |> concatStringsSep "\n";

  # Based on the allowed-connections-from option add certain public keys
  users.users.root.openssh.authorizedKeys.keyFiles = hostDefinitions
    |> attrNames
    |> filter (hostName: config.hosts.this.allowed-connections-from |> elem hostName)
    |> map (hostName: config.getSopsFile "ssh-keys/host-${hostName}/public");
}