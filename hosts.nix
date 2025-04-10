{
  biome-fest = {
    machine = "LENOVO_LNVNB161216";
    # NixOS modules this host consists of
    nixos-modules = [
      ./modules/configs/osi

      # Theme of the host
      ./modules/themes/prismarine

      # Essential things
      ./modules/shared/nixos/essentials.nix

      # fingerprint sensor
      ./modules/shared/nixos/fingerprint.nix

      # Allow selected unfree packages
      ./modules/shared/nixos/allow-some-unfree.nix

      # printing documents with printers
      ./modules/shared/nixos/printing.nix

      # gaming
      ./modules/shared/nixos/steam

      # uni leipzig
      ./modules/shared/nixos/uni-leipzig.nix
    ];
    users.osi = {
      hm-modules = [
        # shell
        ./modules/shared/hm/fish.nix

        # terminal
        ./modules/shared/hm/kitty.nix

        # Window manager
        ./modules/shared/hm/hyprland # base config
        ./modules/shared/hm/hyprland/laptop.nix # for laptops
        ./modules/shared/hm/hyprland/touch.nix # for laptops
        ./modules/shared/hm/hyprland/waybar.nix # utility bar
        ./modules/shared/hm/hyprland/lockscreen.nix # lockscreen with auto enable on inactivity
        ./modules/shared/hm/hyprland/rofi.nix # Powerfull runner

        # code editor
        ./modules/shared/hm/vscode.nix

        # web browser
        ./modules/shared/hm/firefox.nix
        ./modules/shared/hm/chromium.nix # when firefox fails

        # password manager
        ./modules/shared/hm/password-store.nix

        # Game Engine
        ./modules/shared/hm/godot.nix

        # Some common desktop apps I need
        ./modules/shared/hm/desktop-apps.nix
        ./modules/shared/hm/cli-tools.nix
      ];
      # NixOS modules here is given an additional attribute to the set called username, which is the user above
      user-nixos-modules = [
        # Use greetd as display manager and autologin to hyprland
        ./modules/shared/nixos/user/greetd-hyprland-autologin.nix
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
