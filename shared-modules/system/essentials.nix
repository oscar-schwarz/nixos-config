{ pkgs, inputs, ... }:

{
  imports = [
    # import home-manager
    inputs.home-manager.nixosModules.default
    # secret management
    inputs.sops-nix.nixosModules.sops
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
  programs.fish.enable = true;
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