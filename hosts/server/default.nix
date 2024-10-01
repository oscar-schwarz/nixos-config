{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../machines/HP_250_G4_Notebook_PC.nix

      # http server serving my p5 app
      ./feldlinien.nix

      # vpn
      ./wireguard.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "far"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.firewall.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Autologin with user
  services.getty.autologinUser = "user";

  # Fishy shell
  programs.fish = {
    shellInit = "set fish_greeting";
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.fish;
    users = 
    let
      publicSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONJE7lYiuiEMPYII3aFk3WBNeNeDN4YCFaKJ6pwYQtA user"; 
    in {
      root = {
        isNormalUser = false;
        openssh.authorizedKeys.keys = [
          publicSshKey
        ];
      };
      user = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #    packages = with pkgs; [
    #      firefox
    #      tree
    #    ];
        openssh.authorizedKeys.keys = [
          publicSshKey
        ];
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

