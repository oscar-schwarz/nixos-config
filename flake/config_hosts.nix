hostname: moduleArgs @ {
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) mapAttrs attrValues;
  inherit (lib) pipe flatten;
  inherit (builtins) typeOf match;

  # The content of the hosts.nix file
  hostDefinitions = import ../hosts.nix;

  sharedModulesDir = ../modules;

  # Converts a string to a path with a prefix if input is a string (see definition at)
  toPathIfString = prefixDir: maybeStr:
    if typeOf maybeStr == "string"
    then
      # if the string ends with a "/" then it is a directory and the directory (the default.nix file) needs to be imported
      prefixDir
      + "/${maybeStr}"
      + (
        if match ".*/$" maybeStr == null
        then ".nix"
        else ""
      )
    # if its not a string just passthrough
    else maybeStr;

  # if a path is given, then the file is imported after return
  importIfPath = maybePath:
    if typeOf maybePath == "path"
    then (import maybePath)
    else maybePath;

  # Do the above function for each element in a list assuming only files in shared modules are handled
  resolveSharedModulesIn = prefix: list: map (toPathIfString (sharedModulesDir + prefix)) list;

  # The defintion of the host with the provided name above
  host =
    pipe {
      nixos-modules = [];
      shared-hm-modules = [];
      users = mapAttrs (username: userConf: {
        hm-modules = userConf.hm-modules or [];
        user-nixos-modules = userConf.user-nixos-modules or [];
      }) hostDefinitions.${hostname}.users;
    } [
      # Apply the values from the host definition
      (defaults: defaults // hostDefinitions.${hostname})

      # Convert possible strings to their correct path
      (host:
        host
        // {
          nixos-modules = resolveSharedModulesIn "/nixos" host.nixos-modules;
          shared-hm-modules = resolveSharedModulesIn "/hm" host.shared-hm-modules;
          users =
            mapAttrs (_: user: {
              hm-modules = resolveSharedModulesIn "/hm" user.hm-modules;
              user-nixos-modules = resolveSharedModulesIn "/nixos-user" user.user-nixos-modules;
            })
            host.users;
        })
    ];
in {
  # Tell the hosts module all definitions
  # This also type checks the hosts.nix file and sets default values
  hosts.all = hostDefinitions;

  # Set the value of the `this` set
  hosts.this = config.hosts.all.${hostname} // {name = hostname;};

  # Set the host name to the current host
  networking.hostName = hostname;

  # import the defined nixos modules
  imports =
    [
      # definitions of `hosts` config
      ./options_hosts.nix

      # implemenation of ssh for the hosts
      ./config_hosts_ssh.nix

      # the machine of the host
      (../machines + "/${host.machine}")
    ]
    # if a theme is set import it here too
    ++ (
      if host ? "theme"
      then [(../themes + "/${host.theme}")]
      else []
    )
    # The nixos modules of the host
    ++ host.nixos-modules
    # The nixos modules per user
    ++ (pipe host.users [
      # evaluate each module, it must be a function that takes a username which then returns a module
      (mapAttrs (
        username: userConf: map (module: (importIfPath module) username moduleArgs) userConf.user-nixos-modules
      ))

      # only flattened values -> only evaluated modules
      attrValues
      flatten
    ]);

  # Set up the users, just give an empty set, but define the set
  users.users = mapAttrs (_: _: {}) host.users;

  # Set up home manager

  # Import shared Home Manager modules (if strings in list then convert to appropriate path)
  home-manager.sharedModules = host.shared-hm-modules;

  # and set up users
  home-manager.users =
    mapAttrs (userName: userConfig: (
      {nixosConfig, ...}: {
        imports = userConfig.hm-modules;

        # Define the user name and the home directory for reference
        home.username = userName;
        home.homeDirectory = "/home/" + userName;

        # As home manager is installed on each system the same time as home manager the state version is the same
        home.stateVersion = nixosConfig.system.stateVersion;
      }
    ))
    host.users;
}
