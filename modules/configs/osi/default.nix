{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    # setup networks
    ./system/networking.nix
    # Settings specific to my monitor setup
    ../../shared/nixos/monitors.nix
  ];

  sops.secrets = {
    "pass-hashes/osi" = {neededForUsers = true;};
    "api-keys/nix-access-tokens" = {};
    "wireguard/biome-fest/private-key" = {};
    "wireguard/biome-fest/psk" = {};
  };

  # Add github token to github calls
  nix.extraOptions = "!include " + config.getSopsFile "api-keys/nix-access-tokens";

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
        '';
      }
      {
        # TODO: this doesnt work, as hyprctl cannot be called with superuser
        name = "98-atreus-toggle-hypr-laptop-kb";
        rules = ''
          ACTION=="add", SUBSYSTEMS=="usb" ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", RUN+="${pkgs.writeShellScript "" ''
            hyprctl keyword device[at-translated-set-2-keyboard]:enabled false | tee /home/osi/test
          ''}"
          ACTION=="remove", SUBSYSTEMS=="usb" ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", RUN+="${pkgs.writeShellScript "" ''
            hyprctl keyword device[at-translated-set-2-keyboard]:enabled true | tee /home/osi/test
          ''}"
        '';
      }
    ];
  };
}
