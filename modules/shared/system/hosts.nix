{ lib, ...}: 
with lib;
with builtins;
let 
  allDirectoriesInDir = dir: (readDir dir) |> attrsets.filterAttrs (name: value: value == "directory") |> attrsets.attrNames; 
  allNixFilesInDir = dir: 
    (readDir dir) 
    |> attrsets.filterAttrs (name: value: value == "regular") 
    |> attrsets.attrNames;
in {
  
  # --- INTERFACE

  options = let 
    hostOpts = { ... }: {
      options = {
        config = mkOption {
          description = "The config used for this host. Found in ./modules/configs";
          type = allNixFilesInDir ../../../machines |> map replaceStrings [".nix"] [""] |> types.enum;
        };
        machine = mkOption {
          description = "The machine used for this host. Found in ./machines";
          type =  allDirectoriesInDir ../../configs |> types.enum;
        };
      };
    };
  in {
    hosts = mkOption {
      default = {};
      description = "Configuration of each host.";
      type = with types; attrsOf (submodule hostOpts);
    };
    currentHost = mkOption {
      type = types.enum ();
    };
  };

  # --- IMPLEMENTATION

  config = {
  };
}
