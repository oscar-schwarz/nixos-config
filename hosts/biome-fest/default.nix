{ config, ... }:

{
  # Import system modules
  imports = [
      # Include the results of the hardware scan.
      ../../machines/LENOVO_LNVNB161216.nix

      # Osi modules
      ../../modules/configs/osi
    ];

  networking.hostName = "biome-fest";
}
