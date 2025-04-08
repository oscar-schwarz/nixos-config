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
    ];
    users.osi = {
      hm-modules = [
        # Code editor
        ./modules/shared/hm/vscode.nix

        # Window manager
        ./modules/shared/hm/hyprland # base config
        ./modules/shared/hm/hyprland/laptop.nix # for laptops
        ./modules/shared/hm/hyprland/touch.nix # for laptops
        ./modules/shared/hm/hyprland/waybar.nix # utility bar
        ./modules/shared/hm/hyprland/lockscreen.nix # lockscreen with auto enable on inactivity
        ./modules/shared/hm/hyprland/rofi.nix # Powerfull runner
        
        # web browser
        ./modules/shared/hm/firefox.nix

        # shell
        ./modules/shared/hm/fish.nix

        # terminal
        ./modules/shared/hm/kitty.nix

        # password manager
        ./modules/shared/hm/password-store.nix

        # Game Engine
        ./modules/shared/hm/godot.nix
      ];
      # NixOS modules given here should be a function that takes a username and returns a NixOS module
      user-nixos-modules = [];
    };
  };

  blind-spots = {
    machine = "HP_250_G4_Notebook_PC";
    nixos-modules = [
      ./modules/configs/server
    ];
  };
}
