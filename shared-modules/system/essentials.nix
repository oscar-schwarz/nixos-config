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
  boot.loader.systemd-boot.enable = true;

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
  sops.defaultSopsFile = ../../secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # set default shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # disable the greeting
      set fish_greeting
    '';
  };
  users.defaultUserShell = pkgs.fish;

  environment.variables = { 
    # Fix for electron apps to use wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    useGlobalPkgs = true;
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
}