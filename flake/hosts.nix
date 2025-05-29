hostname: {
  pkgs,
  config,
  lib,
  ...
}: let 
  # Variables needed for both interface and implementation
  hostDefinitions = import ../hosts.nix;
  sharedModulesDir = ../modules;
in {
  # --- INTERFACE

  options = let
    # --- FUNCTIONS
    inherit (builtins) readDir replaceStrings filter match;
    inherit (lib) pipe types mkOption filterAttrs attrNames;
    inherit (lib.filesystem) listFilesRecursive;
    # allNixFileNamesInDir = dir:
    #   (readDir dir)
    #   |> filterAttrs (name: value: value == "regular")
    #   |> attrNames
    #   |> map (replaceStrings [".nix"] [""]);
    allDirNamesInDir = dir:
      pipe dir [
        # get content of dir
        readDir
        # filter only allow directories
        (filterAttrs (name: value: value == "directory"))
        # to list
        attrNames
      ];
    listOfModulesOrStringPathWithoutPrefix = prefixDirStr:
      with types;
        listOf (oneOf [
          # path to a module
          path
          # a module itself
          deferredModule
          enum
          (
            pipe sharedModulesDir [
              # get all file paths recursively in shared module dir
              listFilesRecursive

              # convert each to string
              (map toString)

              # filter based on the prefix
              (filter (
                pathStr:
                  (match "^${toString sharedModulesDir}/${prefixDirStr}/.*" pathStr) != null
              ))

              # remove store path prefix from the strings and also the .nix and default.nix extentions
              (map (
                replaceStrings [
                  ((toString sharedModulesDir) + "/${prefixDirStr}/")
                  "default.nix"
                  ".nix" #remove repetitive file extension
                ] ["" "" ""]
              ))
            ]
          )
        ]);

    # --- VARIABLES

    hostOpts = addName: {...}: {
      options =
        {
          machine = mkOption {
            description = "The machine used for this host. Found in ./machines";
            type = types.enum (allDirNamesInDir ../machines);
          };
          theme = mkOption {
            description = "The style theme applied to the host. Found in ./themes";
            type = with types; nullOr (enum (allDirNamesInDir ../themes));
            default = null;
          };
          ip-address = mkOption {
            description = "The IP address of the host in the private network.";
            type = types.str;
            default = null;
          };
          allow-connections-from = mkOption {
            description = "The hosts which are allowed to connect to this host via SSH.";
            type = with types; listOf (attrNames hostDefinitions);
            default = null;
          };
          nixos-modules = mkOption {
            description = "All NixOS modules added to this host.";
            default = [];
            type = listOfModulesOrStringPathWithoutPrefix "nixos";
          };
          shared-hm-modules = mkOption {
            description = "All Home Manager modules added to each Home Manager configuration.";
            default = [];
            type = listOfModulesOrStringPathWithoutPrefix "hm";
          };
          users = mkOption {
            description = "The users defined on this host with their respective home manager and NixOS modules.";
            type = with types;
              attrsOf (submodule ({...}: {
                options = {
                  hm-modules = mkOption {
                    description = "All Home Manager modules of this user.";
                    default = [];
                    type = listOfModulesOrStringPathWithoutPrefix "hm";
                  };
                  user-nixos-modules = mkOption {
                    description = "All NixOS modules added by this specific user. The modules need to be functions that take the username and return a module.";
                    default = [];
                    type = listOfModulesOrStringPathWithoutPrefix "nixos-user";
                  };
                };
              }));
          };
        }
        // (
          if addName
          then {
            name = mkOption {
              description = "The host name of the host this config is used in.";
              type = types.enum (attrNames (import ../hosts.nix));
            };
          }
          else {}
        );
    };
  in {
    hosts = {
      all = mkOption {
        default = {};
        description = "Configuration of each host.";
        type = with types; attrsOf (submodule (hostOpts false));
      };
      this = mkOption {
        description = "The definition of the current host.";
        type = with types; submodule (hostOpts true);
      };
    };
  };





  # --- IMPLEMENTATION

  # Dynamic imports need to happen in a seperate file
  imports = [ (import ./hosts-dynamic-imports.nix hostname)];

  config = let
    # --- FUNCTIONS
    inherit (builtins) mapAttrs attrValues attrNames readFile;
    inherit (lib) pipe attrsToList listToAttrs concatLines;
    fromYAML = import ../lib/from-yaml.nix pkgs;
  in {
    # --- HOSTS CONFIG DEFINITION

    # Tell the hosts module all definitions
    # This also type checks the hosts.nix file and sets default values
    hosts.all = hostDefinitions;

    # Set the value of the `this` set
    hosts.this = config.hosts.all.${hostname} // {name = hostname;};

    # Set the host name to the current host
    networking.hostName = hostname;

    # Set up the users, just give an empty set, but define the set
    users.users = mapAttrs (_: _: {}) hostDefinitions.${hostname}.users;

    # and set up home-manager users
    home-manager.users =
      mapAttrs (userName: userConfig: (
        {
          # Define the user name and the home directory for reference
          home.username = userName;
          home.homeDirectory = "/home/" + userName;

          # As home manager is installed on each system the same time as home manager the state version is the same
          home.stateVersion = config.system.stateVersion;
        }
      ))
      hostDefinitions.${hostname}.users;


    # --- SSH

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

    # Add an entry for each host in /etc/hosts with their respective ip address
    networking.hosts = pipe hostDefinitions [
      attrsToList
      (map ({
        name,
        value,
      }: {
        name = value.ip-address;
        value = [name];
      }))
      listToAttrs
    ];

    # --- SECRETS RELATED TO HOSTS

    # the public keys of the authorized hosts
    sops.secrets = pipe hostDefinitions [
      attrNames

      (map (hostname: {
        name = "authorized-hosts/${hostname}";
        value = {mode = "0444";};
      }))

      listToAttrs
    ];

    system.activationScripts.setupAuthorizedKeys = {
      # Run after we have the sops secrets
      # puts each public key from the `authorizedHosts` set in /etc/ssh/authorized_keys
      deps = ["setupSecrets"];
      text =
        ''
          # --- clear file
          : > /etc/ssh/authorized_keys
        ''
        + (pipe config.sops.defaultSopsFile [
          # convert yaml file to attrset
          readFile
          fromYAML

          # only the `authorized_hosts` key is interesting
          (set: set.authorized-hosts or {})

          # only the hostnames
          attrNames

          # make a cat call for each hostname file
          (map (hostname: ''
            cat ${config.getSopsFile "authorized-hosts/${hostname}"} >> /etc/ssh/authorized_keys
            echo "" >> /etc/ssh/authorized_keys # add newline after public key
          ''))
          concatLines
        ]);
    };
  };
}
