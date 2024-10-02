{ lib, pkgs, nixosConfig, ... }:

{
  imports = [
    # Essential stuff needed on every system
    ../../shared/system/essentials.nix
    # setup networks
    ./system/networking.nix
    # secret management
    ./system/sops.nix
    # window manager and display manager
    ./system/desktop.nix
    # language specific
    ./system/locale.nix
    # Theme of everything
    ./system/stylix.nix
    # Settings specific to my monitor setup
    ../../shared/system/monitors.nix

    # Define home manager settings
    ({ ... }: {
      home-manager = {
        users = {
          "osi" = import ./home.nix;
        };
        # files with this extension should be deleted regulary 
        backupFileExtension = "homeManagerBackupFileExtension";
      };
    })    
  ];

  config = {
    # Allow some unfree packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "obsidian"
      ];

    # Enable adb
    programs.adb.enable = true;

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

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.osi = {
      isNormalUser = true;
      description = "Osi";
      extraGroups = [ "networkmanager" "wheel" "adbusers" ];
      initialPassword = "osi";
    };

    services.udev = {
    packages = [
      pkgs.android-udev-rules
    ];
    customRules = [
        {
          name = "50-kaleidoscope";
          rules = ''
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"  
          '';
        }
      ];
    };
  };
}