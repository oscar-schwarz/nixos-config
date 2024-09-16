{ pkgs, inputs, lib, ... }:

{
  # Import system modules
  imports =
    [ 
      # Essential stuff needed on every system
      ../../shared-modules/system/essentials.nix
      # Include the results of the hardware scan.
      ../../machines/LENOVO_LNVNB161216.nix
      # setup networks
      ./modules/system/networking.nix
      # secret management
      ./modules/system/sops.nix
      # window manager and display manager
      ./modules/system/desktop.nix
      # language specific
      ./modules/system/locale.nix
      # Theme of everything
      ./modules/system/stylix.nix
    ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    android-tools
    wineWowPackages.waylandFull
  ];

  # Allow some unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.osi = {
    isNormalUser = true;
    description = "Osi";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };

  home-manager = {
    users = {
      "osi" = import ./home.nix;
    };
    # files with this extension should be deleted regulary 
    backupFileExtension = "homeManagerBackupFileExtension";
  };

  # Root programs need access to this info too
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

    Host local.server
      HostName 192.168.178.65
      User user
      IdentityFile /home/osi/.ssh/id_server
      IdentitiesOnly yes
'';

  # Useful android stuff
  virtualisation.waydroid.enable = true;

  programs.adb.enable = true;

  services.udev = {
    packages = [
      pkgs.android-udev-rules
    ];
    customRules = [
      {
        name = "50-kaleidoscope";
        rules = ''
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0006", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0005", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"  
        '';
      }
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
