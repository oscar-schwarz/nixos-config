{ ... }:

{
  # Import system modules
  imports = [
      # Include the results of the hardware scan.
      ../../machines/HP_250_G4_Notebook_PC.nix

      # Server modules
      ../../modules/configs/server
    ];

  networking.hostName = "blind-spots";

  # Secrets
}
