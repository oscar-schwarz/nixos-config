hostname:
args@{ pkgs, config, lib, ... }:
let
  # The content of the hosts.nix file
  hostDefinitions = import ../hosts.nix;

  sharedModulesDir = ../modules;

  # The defintion of the host with the provided name above
  host = 
    # At first apply default values to the host configuration for easier use
    ({
      nixos-modules = []; 
      shared-hm-modules = [];
      users = hostDefinitions.${hostname} |> mapAttrs (userName: _: {
        hm-modules = [];
        user-nixos-modules = [];
      });
    } // hostDefinitions.${hostname})    
    # Then convert possible strings to their correct path
    |> (host: host // {
      nixos-modules = host.nixos-modules |> map (toPathIfString (sharedModulesDir + "/nixos"));
      shared-hm-modules = host.shared-hm-modules |> map (toPathIfString (sharedModulesDir + /hm));
      users = host.users |> mapAttrs (_: user: {
        hm-modules = user.hm-modules |> map (toPathIfString (sharedModulesDir + "/hm"));
        user-nixos-modules = user.user-nixos-modules |> map (toPathIfString (sharedModulesDir + "/nixos-user"));
      });
    });

  # helper
  inherit (lib.attrsets) mapAttrs attrValues;
  inherit (lib) flatten;
  inherit (builtins) typeOf match;

  # Converts a string to a path with a prefix if input is a string (see definition at)
  toPathIfString = prefixDir: maybeStr: 
    if typeOf maybeStr == "string" then 
      # if the string ends with a "/" then it is a directory and the directory (the default.nix file) needs to be imported
      prefixDir + "/${maybeStr}" + (
        if match ".*/$" maybeStr == null then
          ".nix"
        else
          ""
      )

    # if its not a string just passthrough
    else maybeStr;
in {
  # Tell the hosts module all definitions
  # This also type checks the hosts.nix file and sets default values
  hosts.all = hostDefinitions;

  # Set the value of the `this` set
  hosts.this = config.hosts.all.${hostname} // { name = hostname;};

  # Set the host name to the current host
  networking.hostName = hostname;

  # import the defined nixos modules
  imports = [ 
    # definitions of `hosts` config
    ./options_hosts.nix 

    # the machine of the host
    (../machines + "/${host.machine}.nix")
  ] 
    # if a theme is set import it here too
    ++ (if host.theme != null then [ (../themes + "/${host.theme}") ] else [])
  
    # The nixos modules of the host
    ++ host.nixos-modules

    # The nixos modules per user
    ++ (host.users |> mapAttrs (username: userConfig: 
      userConfig.user-nixos-modules |> map (moduleOrPath:
        # when the module is a path it needs to be imported before
        let module = (
          if typeOf moduleOrPath == "path" then
            (import moduleOrPath)
          else
            moduleOrPath
        );
        in 
        
        # Give the module an additional attribute
        module (args // {inherit username;})
      )
    ) |> attrValues |> flatten);
  # Set up the users, just give an empty set, but define the set
  users.users = host.users |> mapAttrs (_: _: {});

  # Set up home manager

  # Import shared Home Manager modules (if strings in list then convert to appropriate path)
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