{ lib, pkgs, config, ... }:

{
  imports = [
    # Essential stuff needed on every system
    ../../shared/system/essentials.nix
    # setup networks
    ./system/networking.nix
    # window manager and display manager
    ./system/desktop.nix
    # language specific
    ./system/locale.nix
    # Theme of everything
    ./system/stylix.nix
    # Settings specific to my monitor setup
    ../../shared/system/monitors.nix    
  ];

  options.osi = with lib; {
    # Define all secrets used in this config
    secrets = let 
      mkSecretOption = mkOption {
        default = "";
        description = "A path in secrets.yaml managed by sops.";
      };
    in {
      openAiKey = mkSecretOption;
      publicPgpKey = mkSecretOption;
      osiPasswordHash = mkSecretOption;
      nixAccessTokens = mkSecretOption;
    };
  };

  config = {

    # IMPLEMENT OPTIONS

    # Define sops secrets
    sops.secrets = with config.osi.secrets; let
      common = {
        owner = "osi";
        mode = "0440";
      };
    in {
      ${openAiKey} = common;
      ${publicPgpKey} = common;
      ${nixAccessTokens} = common;
      ${osiPasswordHash}.neededForUsers = true;
    };

    # Set hashed password for osi
    users.users.osi.hashedPasswordFile = config.sops.secrets.${config.osi.secrets.osiPasswordHash}.path;

    # Add github token to github calls
    nix.extraOptions = "!include " + config.sops.secrets.${config.osi.secrets.nixAccessTokens}.path;

    # Allow some unfree packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "obsidian"
      ];

    # Enable adb
    programs.adb.enable = true;

    # Connect to phone
    programs.kdeconnect = {
      enable = true;
    };

    # Gitlab runner 
    services.gitlab-runner = {
      enable = true;
    };

    # Syncthing
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "osi";
      configDir = "/home/osi/.config/syncthing";
      dataDir = "/home/osi/files/local";
      settings = {
        folders = {
          "todo" = {
            enable = true;
            path = "/home/osi/files/local/todo";
            devices = [ "phone" ];
          };
        };
        devices = {
          "phone" = {
            id = "4QPQX3G-WOEEQUD-QJASCBF-DJN6D4H-SXDXHHR-NCP4D4P-2YEIESD-BMXVYAS";
          };
        };
      };
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
        
      Host git.informatik.uni-leipzig.de
        HostName git.informatik.uni-leipzig.de
        User git
        IdentityFile /home/osi/.ssh/id_rsa_github_os
        IdentitiesOnly yes

      Host local.server
        HostName 192.168.178.65
        User user
        IdentityFile /home/osi/.ssh/id_blind-spots_user
        IdentitiesOnly yes
    '';

    # DEFINE USER
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

    # CUSTOM USB DEVICE
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