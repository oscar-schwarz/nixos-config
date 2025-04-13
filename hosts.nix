{
  biome-fest = {
    machine = "LENOVO_LNVNB161216";
    theme = "prismarine";
    ip-address = "10.12.21.10";
    # NixOS modules this host consists of
    nixos-modules = [
      # Essential things
      "essentials"

      # connection to the world
      "networking"

      # fingerprint sensor
      "fingerprint"

      # Allow selected unfree packages
      "allow-some-unfree"

      # printing documents with printers
      "printing"

      # gaming
      "steam/"

      # Settings specific to my monitor setup
      "monitors"

      # certain ssh keys configured
      "github-ssh"
    ];
    users.osi = {
      hm-modules = [
        # shell
        "fish"

        # terminal
        "kitty"

        # Window manager
        "hyprland/" # base config
        "hyprland/laptop" # for laptops
        "hyprland/touch" # for laptops
        "hyprland/waybar" # utility bar
        "hyprland/lockscreen" # lockscreen with auto enable on inactivity
        "hyprland/rofi" # Powerfull runner

        # code editor
        "vscode"

        # web browser
        "firefox"
        "chromium" # when firefox fails

        # password manager
        "password-store"

        # Game Engine
        "godot"

        # Some common desktop apps I need
        "desktop-apps"
        "cli-tools"

        "syncthing/"
      ];
      # NixOS modules here is given an additional attribute to the set called username, which is the user above
      user-nixos-modules = [
        # base user
        "normal-wheel-user"

        # set the password of the root user to the one of the user
        ({ config, username, ...}: {users.users.root.hashedPasswordFile = config.getSopsFile "pass-hashes/${username}";})

        # Use greetd as display manager and autologin to hyprland
        "greetd-hyprland-autologin"

        # Uni Leipzig
        "uni-leipzig"
      ];
    };
  };

  blind-spots = {
    machine = "HP_250_G4_Notebook_PC";
    ip-address = "10.12.21.33";
    nixos-modules = [
      ./modules/configs/server
    ];
  };
}
