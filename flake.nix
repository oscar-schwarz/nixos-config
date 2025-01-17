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

  outputs = {nixpkgs, ...} @ inputs: let
    # --- FLAKE MODULE ---
    # this module is shared among ALL configurations to ensure it uses the flake's inputs correctly
    sharedModule = {inputs, ...}: {
      imports = with inputs; [
        # Import all modules of the inputs
        home-manager.nixosModules.default
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        programs-sqlite.nixosModules.programs-sqlite
        custom-udev-rules.nixosModule

        # Secret management needs to be done for every configuration
        ./secrets
      ];

      # Import home manager modules to home manager
      home-manager.sharedModules = with inputs; [

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
          }
        )
      ];
    };

    # --- FUNCTIONS, ALIASES ---
    lib = nixpkgs.lib;

    # function to make a system
    # A modules list can be passed.
    mkSystem = modules:
      lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        # Make sure to add the shared module to the system
        modules = modules ++ [sharedModule];
      };

    # --- SYSTEMS ---
    # Declare all systems found in ./hosts.nix

    # Paths
    configsPath = ./modules/configs;
    machinesPath = ./machines;

    # Definitions are in a seperate file
    hostDefinitions = import ./hosts.nix;

    perDefinedHost = hostName: host:
      mkSystem [
        (
          {...}: {
            networking.hostName = hostName;
            imports = [
              (configsPath + ("/" + host.config))
              (machinesPath + ("/" + host.machine) + ".nix")
            ];
          }
        )
      ];
  in {
    nixosConfigurations = lib.attrsets.mapAttrs perDefinedHost hostDefinitions;
  };
}
