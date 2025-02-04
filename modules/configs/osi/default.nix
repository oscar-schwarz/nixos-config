{
  lib,
  pkgs,
  config,
  ...
}: {
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

  sops.secrets = {
    "pass-hashes/osi" = {neededForUsers = true;};
    "api-keys/nix-access-tokens" = {};
    "api-keys/open-ai" = {owner = "osi";};
    "other/uni-leipzig-vpn-auth" = {};
    "wireguard/biome-fest/private-key" = {};
    "wireguard/biome-fest/psk" = {};
    "pgp-keys/id-0x675D2CB5013E8731/public" = {owner = "osi";};
  };

  # Add github token to github calls
  nix.extraOptions = "!include " + config.getSopsFile "api-keys/nix-access-tokens";

  # Allow some unfree packages
  allowedUnfree = [
    "obsidian"
    "steam-unwrapped"
    "steam"
  ];

  # Enable adb
  programs.adb.enable = true;

  programs.steam.enable = true;

  # Connect to phone
  programs.kdeconnect = {
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ 
      gutenprint 
      # epsonscan2 
    ];
  };

  # and avahi for bonjour
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };

  # enable fprintd but disable the pam sudo module
  services.fprintd.enable = true;
  security.pam.services = {
    sudo.fprintAuth = false;
    polkit-1.fprintAuth = false;
    cups.fprintAuth = false;
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
        "written-mind" = {
          enable = true;
          path = "/home/osi/files/local/written-mind";
          devices = ["phone"];
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
      HostName 101.201.4.22
      User user
      IdentityFile /home/osi/.ssh/id_blind-spots_user
      IdentitiesOnly yes
  '';

  # DEFINE USER
  users.users = {
    osi = {
      isNormalUser = true;
      description = "Osi";
      hashedPasswordFile = config.getSopsFile "pass-hashes/osi";
      extraGroups = ["networkmanager" "wheel" "adbusers"];
    };
    root.hashedPasswordFile = config.getSopsFile "pass-hashes/osi";
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
}
