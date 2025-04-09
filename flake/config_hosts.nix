hostName:
args@{ pkgs, config, lib, ... }:
let
  # The content of the hosts.nix file
  hostDefinitions = import ../hosts.nix;

  # The defintion of the host with the provided name above

  host = {
    # with defaults
    nixos-modules = []; 
    shared-hm-modules = [];
    users = hostDefinitions.${hostName} |> mapAttrs (userName: _: {
      hm-modules = [];
      user-nixos-modules = [];
    });
  } // hostDefinitions.${hostName};

  # helper
  inherit (lib.attrsets) mapAttrs attrValues;
  inherit (lib) flatten;
  inherit (builtins) typeOf;
in {
  # Tell the hosts module all definitions
  # This also type checks the hosts.nix file and sets default values
  hosts.all = hostDefinitions;

  # Set the value of the `this` set
  hosts.this = config.hosts.all.${hostName} // { name = hostName;};

  # Set the host name to the current host
  networking.hostName = hostName;

  # import the defined nixos modules
  imports = [ 
    # definitions of `hosts` config
    ./options_hosts.nix 

    # the machine of the host
    (../machines + "/${host.machine}" + ".nix")
  ] 
  
    # The nixos modules of the host 
    ++ host.nixos-modules

    # The nixos modules per user
    ++ (host.users |> mapAttrs (userName: userConfig: 
      userConfig.user-nixos-modules |> map (module: 
        # If a path was provided import the file and give it the userName as an argument, else just give the argument
        if typeOf module == "path" then
          (import module (args // {inherit userName;}))
        else
          (module (args // {inherit userName;}))
      )
    ) |> attrValues |> flatten);
  # Set up the users, just give an empty set, but define the set
  users.users = host.users |> mapAttrs (_: _: {});


  # Set up home manager

  # Import shared Home Manager modules
  home-manager.sharedModules = host.shared-hm-modules;

  # and set up users
  home-manager.users = host.users |> mapAttrs (userName: userConfig: (
    { nixosConfig, ... }: {
      imports = userConfig.hm-modules;

      # Define the user name and the home directory for reference
      home.username = userName;
      home.homeDirectory = "/home/" + userName;

      # As home manager is installed on each system the same time as home manager the state version is the same
      home.stateVersion = nixosConfig.system.stateVersion;
    }
  ));
}