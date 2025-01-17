{ lib, config, ...}: 
with lib;
with builtins;
let 
  allDirectoriesInDir = dir: (readDir dir) |> attrsets.filterAttrs (name: value: value == "directory") |> attrNames; 
  allNixFilesInDir = dir: 
    (readDir dir) 
    |> attrsets.filterAttrs (name: value: value == "regular") 
    |> attrsets.attrNames;
in {
  
  # --- INTERFACE

  options.hosts = let 
    hostOpts = { ... }: {
      options = {
        config = mkOption {
          description = "The config used for this host. Found in ./modules/configs";
          type = types.enum (allNixFilesInDir ../../../machines |> map replaceStrings [".nix"] [""]);
        };
        machine = mkOption {
          description = "The machine used for this host. Found in ./machines";
          type =  types.enum (allDirectoriesInDir ../../configs) ;
        };
      };
    };
  in {
    all = mkOption {
      default = {};
      description = "Configuration of each host.";
      type = with types; attrsOf (submodule hostOpts);
    };
    currentHost = mkOption {
      description = "The host of the current system";
      type = types.enum (attrNames config.hosts);
    };
    this = mkOption {
      description = "The configuration of the current host";
      type = submodule hostOpts;
    };
  };

  # --- IMPLEMENTATION

  config = let 
    cfg = config.hosts;
  in {
    # This is a read-only option, as it just provides convenience
    hosts.this = mkForce cfg.all.${cfg.currentHost};

    # Import config and machine
    import = [
      (../../../machines + "/${cfg.this}")
    ];

    # Set the host name to the current host
    networking.hostName = cfg.this;
  };
}
