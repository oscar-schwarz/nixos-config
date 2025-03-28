{
  description = "Osi's NixOS Config Flake";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";

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

    # Working version of the hyprpolkitagent
    hyprpolkitagent = {
      url = "github:hyprwm/hyprpolkitagent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Customized build of libfprint to make my laptops fingerpint reader work
    libfprint-goodix-55b4 = {
      url = "github:oscar-schwarz/libfprint-goodix-55b4";
      # inputs.nixpkgs.follows = "nixpkgs"; # needs a specific nixpkgs version
    };
  };

  outputs = {nixpkgs, ...} @ inputs: with nixpkgs.lib; with builtins; let

    # --- PACKAGES ---
    packages.x86_64-linux = {
      claude-code = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/claude-code.nix {};
    };


    # --- NIXOS CONFIGURATIONS ---

    # Definitions are in a seperate file next to this flake.nix
    hostDefinitions = import ./hosts.nix;

    # Create a nixos configuration for each defined hosts in hosts.nix
    nixosConfigurations = hostDefinitions |> attrsets.mapAttrs (hostName: host: 
      nixosSystem {
        specialArgs = { inherit inputs; };
        
        modules = with inputs; [
          # --- FLAKE INPUTS MODULES ---
          home-manager.nixosModules.default
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          programs-sqlite.nixosModules.programs-sqlite
          custom-udev-rules.nixosModule

          # --- FLAKE MODULE ---
          # flake specific settings
          ({inputs, ...}: {

            # Enable flakes and pipe operators
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];

            # Import home manager modules to home manager
            # home-manager.sharedModules = with inputs; [ ];

            nixpkgs.overlays = with inputs; [
              # Add packages of the flakes in an overlay
              (
                final: prev: let stable = nixpkgs-stable.legacyPackages.${prev.system}; in {
                  # to access stable packages
                  inherit stable;

                  # stable packages
                  auto-cpufreq = stable.auto-cpufreq;

                  # custom flake packages
                  matcha = matcha.packages.${prev.system}.default;
                  eduroam = eduroam.packages.${prev.system};
                  hyprpolkitagent = hyprpolkitagent.packages.${prev.system}.default;
                }
              )
            ];
          })

          # --- HOSTS MODULE ---
          # All host specific settings are imported
          ({ ... }: {
            imports = [
              # Import based on current machine
              (./machines + "/${host.machine}.nix")
              (./modules/configs + "/${host.config}")

              # Defines the used options below
              ./modules/shared/system/hosts.nix
            ];

            # Tell the hosts module all definitions
            hosts.all = hostDefinitions;

            # Set the host name to the current host
            networking.hostName = hostName;
          })

          # --- SOPS MODULE ---
          # all hosts should have access to their respective secrets
          ./secrets

          # --- FIX FOR UNFREE PREDICATE ---
          ./modules/shared/system/allowed-unfree.nix
        ];
      }
    );
  in {
    inherit nixosConfigurations;
    inherit packages;
  };
}
