# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hosts/LENOVO_LNVNB161216.nix
      # import home-manager
      inputs.home-manager.nixosModules.default
      # setup networks
      ./modules/system/networking.nix
      # secret management
      ./modules/system/sops.nix
      # window manager and display manager
      ./modules/system/desktop.nix
      # language specific
      ./modules/system/locale.nix
      # Theming
      ./modules/system/stylix.nix
    ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    manix
    neofetch
    sops
    tree
    bat
  ];

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # enable nix-direnv
  programs.direnv = {
    enable = true;
    silent = true;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    useGlobalPkgs = true;
    users = {
      "osi" = import ./home.nix;
    };
    # files with this extension should be deleted regulary 
    backupFileExtension = "homeManagerBackupFileExtension";
  };

  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile /home/osi/.ssh/id_rsa_github_osipog
      IdentitiesOnly yes

    Host os.github.com
      HostName github.com
      User git
      IdentityFile /home/osi/.ssh/id_rsa_github_os
      IdentitiesOnly yes
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.osi = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Osi";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # For nix path in the shell
  programs.fish.enable = true;

  # This is a mandatory option that has to be set, any other settings are in my stylix.nix
  stylix.image = ./images/nms.jpg;

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
