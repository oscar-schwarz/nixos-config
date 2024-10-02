{ pkgs, inputs, ... }:

{
  imports = with inputs; [
    # import home-manager
    home-manager.nixosModules.default
    # secret management
    sops-nix.nixosModules.sops
    # stylix rice
    stylix.nixosModules.stylix
    # fix for program not found
    flake-programs-sqlite.nixosModules.programs-sqlite
    # easier udev config
    custom-udev-rules.nixosModule
  ];
  
  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader setup
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 42;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  

  # needed packages
  environment.systemPackages = with pkgs; [
    neofetch
    sops
    tree
    bat
  ];

  # Secrets
  sops.defaultSopsFile = ../../../secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # configure fish* and set default shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # disable the greeting
      set fish_greeting
    '';
  };
  users.defaultUserShell = pkgs.fish;

  # Configure direnv
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
  };

  environment.variables = { 
    # Fix for electron apps to use wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Setup home-manager
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    useGlobalPkgs = true;
    
    # Home manager settings for every user
    sharedModules = [({...}: {
      # Let home manager manage itself
      programs.home-manager.enable = true;

      # better cd
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      # Git
      programs.git = {
        enable = true;
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
        };
      };
    })];
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Make all keyboards the same

  # xserver keymap
  services.xserver = {
    # Configure keymap in X11.
		xkb.layout = "us";
		xkb.variant = "colemak";
  };

  # Configure console keymap
  console.keyMap = "colemak";
}