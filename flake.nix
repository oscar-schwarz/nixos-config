{
  description = "Osi's NixOS Config Flake";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";


    # HOME MANAGER - for all user related stuff
    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
    };


    # HYPRLAND - Tiling window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugin for touchscreen support
    hyprglass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };

    # Idle inhibitor
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Plasma manager a nice way to setup KDE declaratively
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };


    # Stylix, theming made easy peasy
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };


    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Flake programs.sqlite, fixes the command-not-found error on flake systems
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Repo containing vscode extensions from marketplace and open vsx
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Better udev nix interface
    custom-udev-rules = {
      url = "github:MalteT/custom-udev-rules";
    };
  };

  outputs = { nixpkgs, ... }@inputs: 
    
    # SYSTEMS - Declare all systems found in ./hosts
    with builtins; 
    let 
      lib = nixpkgs.lib;

      # function to make a system
      mkSystem = modules: lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = modules ++ [
          ({ inputs, ... }: {
            # Add the matcha package to pkgs
            nixpkgs.overlays = [
              (final: prev: {
                matcha = inputs.matcha.packages.${prev.system}.default;
              })
            ]
            ;
          })
        ];
      };

      readDirDirNames = path_: let 
        dirContent = readDir path_;
      in filter (x: (getAttr x dirContent) == "directory" ) (attrNames dirContent);

      # Path to hosts
      hostsPath = ./hosts;

      # filter all items in hostsPath to be only folders
      hostNames = readDirDirNames hostsPath;

      systemsFromHosts = lib.attrsets.genAttrs hostNames (name: mkSystem [ (hostsPath + "/${name}") ]);

      # Interpolate systems with doing a combination from all configs from `configsPath` with all machines in
      # `machinesPath`
      configsPath = ./modules/configs;
      machinesPath = ./machines;

      configNames = readDirDirNames configsPath;
      # only machine names without .nix
      machineNames = map (lib.strings.removeSuffix ".nix") (attrNames (readDir machinesPath));

      # All configs connected to machine names in the form { interpolatedName = { machine; config }; ...}
      connections = lib.lists.foldr (a: b: a // b) {} (concatLists ( 
        map (config: 
          map (machine: {
            # interpolated name is just `configName.machineName`
            "${config}.${machine}" = {inherit config;inherit machine;};
          }) machineNames
        ) configNames
      ));
      
      
      interpolatedSystems = lib.attrsets.genAttrs (attrNames connections) (name: let 
        connection = connections.${name};
      in mkSystem [
        # Include configs
        (configsPath + "/${connection.config}")
        # Include machine
        (machinesPath + "/${connection.machine}.nix")
        
        # Some interpolation specific settings
        ({ ... }: {
          networking.hostName = name;
        })
      ]);
    in {
    nixosConfigurations = systemsFromHosts // interpolatedSystems; 
  };
}
