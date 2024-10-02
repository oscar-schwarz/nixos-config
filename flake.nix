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
      configsPath = ./hosts;

      # filter all items in configsPath to be only folders
      dirContent = readDir configsPath;
      configNames = filter 
        (x: (getAttr x dirContent) == "directory" ) 
        (attrNames dirContent);
    in {
    nixosConfigurations = lib.attrsets.genAttrs configNames 
      (name: lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            # Loading the configuration
            (configsPath + "/${name}")

            # Some shared settings specific to this flake
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
        }
      );
  };
}
