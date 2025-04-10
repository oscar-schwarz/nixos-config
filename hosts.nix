{
  biome-fest = {
    machine = "LENOVO_LNVNB161216";
    theme = "prismarine";
    # NixOS modules this host consists of
    nixos-modules = [
      ./modules/configs/osi

      # Essential things
      "essentials"

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
      ];
      # NixOS modules here is given an additional attribute to the set called username, which is the user above
      user-nixos-modules = [
        # Use greetd as display manager and autologin to hyprland
        "greetd-hyprland-autologin"

        # Uni Leipzig
        "uni-leipzig"
      ];
    };
  };

  blind-spots = {
    machine = "HP_250_G4_Notebook_PC";
    nixos-modules = [
      ./modules/configs/server
    ];
  };
}
