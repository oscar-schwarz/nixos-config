{
  biome-fest = {
    machine = "LENOVO_LNVNB161216";
    # NixOS modules this host consists of
    nixos-modules = [
      ./modules/configs/osi

      # Theme of the host
      ./modules/themes/prismarine
    ];
    # Configuration options for each user
    users.osi = {
      # Home Manager modules added to this users Home Manager config
      hm-modules = [ ];
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