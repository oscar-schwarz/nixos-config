{lib, ...}: let
  inherit (lib) pipe types mkOption;
  inherit (lib.attrsets) filterAttrs attrNames;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (builtins) readDir replaceStrings filter match;

  # The content of the hosts.nix file
  hostDefinitions = import ../hosts.nix;

  sharedModulesDir = ../modules;

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
in {
  # --- INTERFACE

  options = let
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
}
