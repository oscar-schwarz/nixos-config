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

    # HYPRLAND - Wayland tiling window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprlang";
    };

    hyprlang = {
      url = "github:hyprwm/hyprlang?rev=9995f54eddb20de2123bc45c020ac124654c1111";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugin for touchscreen support
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };

    # Hyprland plugin for a window focused animation
    hyprfocus = {
      url = "github:pyt0xic/hyprfocus";
      inputs.hyprland.follows = "hyprland";
    };

    # Hyprland plugin for workspace overview
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    # Idle inhibitor
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # Plasma manager a nice way to setup KDE declaratively
    # plasma-manager = {
    #   url = "github:pjones/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };

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
    programs-sqlite = {
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

    # Scripts to login into eduroam networks (university wifi)
    eduroam = {
      url = "github:MayNiklas/eduroam-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:

    with builtins;
    let
      # --- FLAKE MODULE ---
      # this module is shared among ALL configurations to ensure it uses the flake's inputs correctly
      sharedModule = { inputs, ... }:
        {
          # Import all modules of the inputs 
          imports = with inputs; [
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops
            stylix.nixosModules.stylix
            programs-sqlite.nixosModules.programs-sqlite
            custom-udev-rules.nixosModule
            hyprland.nixosModules.default
          ];

          # Import home manager modules to home manager
          home-manager.sharedModules = with inputs; [
            hyprland.homeManagerModules.default
          ];

          # Enable flakes
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          nixpkgs.overlays = with inputs; [
            # Add packages of the flakes in an overlay
            (
              final: prev: {
                matcha = matcha.packages.${prev.system}.default;
                eduroam = eduroam.packages.${prev.system};
                hyprlandPlugins = {
                  hyprgrass = hyprgrass.packages.${prev.system}.default;
                  hyprfocus = hyprfocus.packages.${prev.system}.default;
                  Hyprspace = Hyprspace.packages.${prev.system}.Hyprspace;
                };
              }
            )
          ];
        };

      # --- FUNCTIONS, ALIASES ---
      lib = nixpkgs.lib;

      # function to make a system
      # A modules list can be passed.
      mkSystem =
        modules:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          # Make sure to add the shared module to the system
          modules = modules ++ [sharedModule];
        };

      # Function to that takes a path and returns all directory names in that path
      readDirDirNames =
        path_:
        let
          dirContent = readDir path_;
        in
        filter (x: (getAttr x dirContent) == "directory") (attrNames dirContent);

      # --- SYSTEMS --- 
      # Declare all systems found in ./hosts

      # Path to hosts
      hostsPath = ./hosts;

      # filter all items in hostsPath to be only folders
      hostNames = readDirDirNames hostsPath;

      systemsFromHosts = lib.attrsets.genAttrs hostNames (name: mkSystem [ (hostsPath + "/${name}") ]);

      # --- INTERPOLATED SYSTEMS ---
      # Interpolate systems with doing a combination from all configs from `configsPath` with all machines in
      # `machinesPath`
      configsPath = ./modules/configs;
      machinesPath = ./machines;

      configNames = readDirDirNames configsPath;
      # only machine names without .nix
      machineNames = map (lib.strings.removeSuffix ".nix") (attrNames (readDir machinesPath));

      # All configs connected to machine names in the form { interpolatedName = { machine; config }; ...}
      connections = lib.lists.foldr (a: b: a // b) { } (
        concatLists (
          map (
            config:
            map (machine: {
              # interpolated name is just `configName--machineName`
              "${config}--${machine}" = {
                inherit config;
                inherit machine;
              };
            }) machineNames
          ) configNames
        )
      );

      interpolatedSystems = lib.attrsets.genAttrs (attrNames connections) (
        name:
        let
          connection = connections.${name};
        in
        mkSystem [
          # Include configs
          (configsPath + "/${connection.config}")
          # Include machine
          (machinesPath + "/${connection.machine}.nix")

          # Some interpolation specific settings
          (
            { ... }:
            {
              networking.hostName = name;
            }
          )
        ]
      );

      # Add all systems as nixos configs
      nixosConfigurations = systemsFromHosts // interpolatedSystems;
    in
    {
      inherit nixosConfigurations;
    };
}
