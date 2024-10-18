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

    # Hyprland plugin for touchscreen support
    hyprgrass = {
      url = "github:horriblename/hyprgrass";
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
      # --- FUNCTIONS, ALIASES ---
      lib = nixpkgs.lib;
      forAllSystems =
        f:
        builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value = f name;
            })
            [
              "x86_64-linux"
              "i686-linux"
              "x86_64-darwin"
              "aarch64-linux"
              "aarch64-darwin"
            ]
        );

      # function to make a system
      # A modules list can be passed.
      mkSystem =
        modules:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = modules ++ [
            # A shared module among all systems to reference this flake
            (
              { inputs, ... }:
              {
                # Import all modules of the inputs 
                imports = with inputs; [
                  # import home-manager
                  home-manager.nixosModules.default
                  sops-nix.nixosModules.sops
                  stylix.nixosModules.stylix
                  flake-programs-sqlite.nixosModules.programs-sqlite
                  custom-udev-rules.nixosModule
                ];

                # Enable flakes
                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];

                # Add packages of the flakes
                nixpkgs.overlays = [
                  (
                    final: prev: with inputs; {
                      matcha = matcha.packages.${prev.system}.default;
                      eduroam = eduroam.packages.${prev.system};
                    }
                  )
                ];
              }
            )
          ];
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

      # --- DEV SHELL ---
      # Declare the shell environment for working with this flake
      devShells = forAllSystems (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        {
          # Here starts the shell definition
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              onefetch
            ];

            # Show a greeter on entering the shell
            shellHook = ''
              onefetch
            '';
          };
        }
      );

      # --- FORMATTER ---
      # Flake feature that auto-formats nix files
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    in
    {
      inherit nixosConfigurations;
      inherit devShells;
      inherit formatter;
    };
}
