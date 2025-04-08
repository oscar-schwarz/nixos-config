{ lib, config, ...}: 
with lib;
# with builtins;
let 
  allDirectoriesInDir = dir:
    (readDir dir) 
    |> attrsets.filterAttrs (name: value: value == "directory") 
    |> attrNames; 
  allNixFilesInDir = dir: 
    (readDir dir) 
    |> attrsets.filterAttrs (name: value: value == "regular") 
    |> attrNames;
  
  # Define a type that can be either a path or a module (attrset or function)
  moduleOrPathList = with types; listOf (oneOf [ path deferredModule]);
  
  cfg = config.hosts;
in {
  
  # --- INTERFACE

  options = let
    hostOpts = addName: { ... }: {
      options = {
        machine = mkOption {
          description = "The machine used for this host. Found in ./machines";
          type =  types.enum (allDirectoriesInDir ../machines) ;
        };
        nixos-modules = mkOption {
          description = "All NixOS modules added to this host.";
          default = [];
          type = moduleOrPathList;
        };
        shared-hm-modules = mkOption {
          description = "All Home Manager modules added to each Home Manager configuration.";
          default = [];
          type = moduleOrPathList;
        };
        users = mkOption {
          description = "The users defined on this host with their respective home manager and NixOS modules.";
          type = with types; attrsOf submodule ({ ... }: {
            options = {
              hm-modules =  mkOption {
                description = "All Home Manager modules of this user.";
                default = [];
                type = moduleOrPathList;
              };
              user-nixos-modules = mkOption {
                description = "All NixOS modules added by this specific user. The modules need to be functions that take the username and return a module.";
                default = [];
                type = with types; listOf (oneOf [ path (functionTo deferredModule)]);
              };
            };
          });
        } // (
          if addName then {
            name = mkOption {
              description = "The host name of the host this config is used in.";
              type = types.enum (attrsets.attrNames (import ../hosts.nix));
            };
          } else {}
        ); 
      };
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
        type = with types; attrsOf (submodule (hostOpts true));
      };
    };
  };
}
