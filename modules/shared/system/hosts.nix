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
  
  cfg = config.hosts;
in {
  
  # --- INTERFACE

  options = let 
    hostOpts = { ... }: {
      options = {
        config = mkOption {
          description = "The config used for this host. Found in ./modules/configs";
          type = types.enum (allNixFilesInDir ../../machines |> map replaceStrings [".nix"] [""]);
        };
        machine = mkOption {
          description = "The machine used for this host. Found in ./machines";
          type =  types.enum (allDirectoriesInDir ../configs) ;
        };
      };
    };
  in {
    hosts = {
      all = mkOption {
        default = {};
        description = "Configuration of each host.";
        type = with types; attrsOf (submodule hostOpts);
      };
      this = mkOption {
        description = "The definition of the current host.";
      };
    };
  };

  # --- IMPLEMENTATION

  config = {
    hosts.this = cfg.all.${config.networking.hostName} // { name = config.networking.hostName;};
  };
}
