{
  pkgs,
  config,
  lib,
  inputs,
  options,
  ...
}: let 
  hmSecretName = userName: name: "hm-secret-${userName}-${name}"; 

  inherit (lib) attrsToList flatten mkOption;
  inherit (builtins) listToAttrs;
in {
  # Import the nixos module
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.getSopsFile = lib.mkOption {
    description = "A helper function to get the path to a sops secret.";
  };
  config = {
    
    getSopsFile = name: config.sops.secrets.${name}.path;

    environment.systemPackages = with pkgs; [
      sops
    ];

    # Setup the secrets file
    sops.defaultSopsFile = ../secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    # Generate the age key from a provided ssh key
    sops.age = {
      generateKey = true;

      # Key to be generated
      keyFile = "/root/.age-key.txt";

      # From which key to generate it
      # This only needs to be present on the machine that executes 'nixos-rebuild'
      sshKeyPaths = ["/root/.ssh/id_ed25519_sops"];
    };

    # Simulate the a home manager module for sops nix. Actually the secrets are imported through the system
    # but we need to create an api from inside Home Manager
    home-manager.sharedModules = [
      ({ nixosConfig, config, ... }: { 
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
    sops.secrets = 
      # Get a list of name value pairs of all home manager users
      attrsToList config.home-manager.users
      # map the name, value pair list to name = "" and value = sops secret name value pair list
      |> map (userCfg: {
        name = "";

        value = userCfg.value.sops.secrets
          # Same as above
          |> attrsToList
        
          # Create a list of secrets of this user
          |> map (secret: {
            # secret name will be e.g. "hm-secret-osi-api-keys/open-ai"
            name = hmSecretName userCfg.name secret.name;
            value = secret.value // { 
              # Set the correct user
              owner = userCfg.name;
              # and the correct key
              key = secret.name;
            };
          });
      })
      # Transform into a name value pair list of sops secrets
      |> map (value: value.value)
      |> flatten
      
      # transform the sops secret name value pair list to a set of sops secrets
      |> listToAttrs;

  };
}
