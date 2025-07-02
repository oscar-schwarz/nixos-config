{
  description = "Osi's NixOS Config Flake";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    # "Too much bleeding" age nixpkgs
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utilities
    flake-utils.url = "github:numtide/flake-utils";

    # HOME MANAGER - for all user related stuff
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # make the disk layout of the machines declareable
    disko = {
      url = "github:nix-community/disko";
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
      # url = "github:nix-community/stylix";
      url = "github:osipog/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Development environments the easy nix way
    devenv = {
      url = "github:cachix/devenv";
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
    # Repo containing firefox addons
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
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

    # Customized build of libfprint to make my laptops fingerprint reader work
    libfprint-goodix-55b4 = {
      url = "github:oscar-schwarz/libfprint-goodix-55b4";
      # inputs.nixpkgs.follows = "nixpkgs"; # needs a specific nixpkgs version
    };

    # declarative neovim distribution
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (builtins) readDir;
    inherit (nixpkgs.lib) pipe nixosSystem;
    inherit (nixpkgs.lib.trivial) flip; 
    inherit (nixpkgs.lib.attrsets) mapAttrs listToAttrs attrNames attrValues;
    inherit (nixpkgs.lib.strings) removeSuffix;
    inherit (flake-utils.lib) eachDefaultSystem;

    # --- NIXOS CONFIGURATIONS ---
    # Create a nixos configuration for each defined host in hosts.nix
    nixosConfigurations = flip mapAttrs (import ./hosts.nix) (
      hostName: host:
        nixosSystem {
          specialArgs = {inherit self;inherit inputs;};
          modules = [
            # --- SHARED MODULE ---
            ./flake/shared-module.nix

            # --- HOSTS MODULE ---
            # All host specific settings are imported
            (import ./flake/hosts.nix hostName)

            # --- SOPS MODULE ---
            # all hosts should have access to their respective secrets
            ./flake/secrets.nix
          ];
        }
    );

    # --- OTHER OUTPUTS FOR EACH SYSTEM ---
    outputsEachSystem = eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Get custom packages from pkgs directory
        customPackages = pipe (readDir ./pkgs) [
          # get all file names
          attrNames

          # assume that each entry returned by readDir is a valid nix import argument

          # evaluate package and transform list to name-value-pairs
          (map (file: {
            name = removeSuffix ".nix" file;
            value = pkgs.callPackage (./pkgs + "/${file}") {};
          }))

          listToAttrs
        ];
      in {
        formatter = pkgs.alejandra;
        packages = customPackages // {icon = pkgs.callPackage (import ./lib/tint-nixos-svg.nix {blue="ffa7a6";cyan="ffebd6";}) {};};
        devShells.default = pkgs.mkShell {
          name = (import ./flake.nix).description; # sir, is that legal?
          buildInputs = attrValues customPackages;
        };
      }
    );
  in
    {
      inherit nixosConfigurations;
    }
    // outputsEachSystem;
}
