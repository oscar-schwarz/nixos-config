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

        # web browser
        ./modules/shared/hm/firefox.nix

        # terminal
        ./modules/shared/hm/fish.nix

        # password manager
        ./modules/shared/hm/password-store.nix
        
        # Game Engine
        ./modules/shared/hm/godot.nix
      ];
      # NixOS modules given here should be a function that takes a username and returns a NixOS module
      user-nixos-modules = [ ];
    };
  };


  blind-spots = {
    machine = "HP_250_G4_Notebook_PC";
    nixos-modules = [
      ./modules/configs/server
    ];
  };
}