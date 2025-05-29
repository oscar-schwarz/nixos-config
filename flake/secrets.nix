{
  pkgs,
  config,
  lib,
  inputs,
  self,
  ...
}: let
  inherit (builtins) listToAttrs toFile head;
  inherit (lib) pipe attrsToList mkOption flatten getExe;

  hmSecretName = userName: name: "hm-secrets/${userName}/${name}";
in {
  # Import the nixos module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.getSopsFile = lib.mkOption {
    description = "A helper function to get the path to a sops secret.";
  };
  config = {
    getSopsFile = name: config.sops.secrets.${name}.path /*or (toFile name "")*/;

    environment.systemPackages = with pkgs; [
      sops
    ];

    # Setup the secrets file
    sops.defaultSopsFile = ../. + "/secrets/${config.networking.hostName}.yaml";
    sops.defaultSopsFormat = "yaml";

    # Generate the age key from a provided ssh key
    sops.age = {
      # From which key to generate it
      sshKeyPaths = ["/etc/ssh/id_ed25519"];

      keyFile = "/root/.config/sops/age/keys.txt";
    };
    # We need to generate the key correctly because sops is doing it wrong
    system.activationScripts = {
      generateAgeKeyFromSSH.text = ''
        ${getExe pkgs.ssh-to-age} -private-key -i ${head config.sops.age.sshKeyPaths} -o ${config.sops.age.keyFile}
      '';
      setupSecretsForUsers.deps = [ "generateAgeKeyFromSSH" ];
      setupSecrets.deps = [ "generateAgeKeyFromSSH" ];
    };

    # Sops has weird behavior, we will generate the age key correctly

    # Simulate the a home manager module for sops nix. Actually the secrets are imported through the system
    # but we need to create an api from inside Home Manager
    home-manager.sharedModules = [
      ({
        nixosConfig,
        config,
        ...
      }: {
        options = {
          sops.secrets = mkOption {
            description = "The content of this option passed to the NixOS sops.secrets option";
          };
          getSopsFile = lib.mkOption {
            description = "A helper function to get the path to a sops secret.";
          };
        };
        # Create a wrapper for the getSopsFile function that looks for the correct name
        config.getSopsFile = name: nixosConfig.getSopsFile (hmSecretName config.home.username name);
      })
    ];

    # Import the secrets that are defined inside Home Manager
    sops.secrets = pipe config.home-manager.users [
      # Get a list of name value pairs of all home manager users
      attrsToList

      # map all defined keys in home-manager to system wide keys with the user enabled
      (map (userCfg:
        pipe userCfg.value.sops.secrets [
          # same as above
          attrsToList

          (map (secret: {
            # secret name will be e.g. "hm-secrets/osi/api-keys/open-ai"
            name = hmSecretName userCfg.name secret.name;
            value =
              secret.value
              // {
                # Set the correct user
                owner = userCfg.name;
                # and the correct key
                key = secret.name;
              };
          }))
        ]))

      # transform the sops secret name value pair list to a set of sops secrets
      flatten
      listToAttrs
    ];
  };
}
