{ ... }:

{
  # Import system modules
  imports = [
      # Include the results of the hardware scan.
      ../../machines/LENOVO_LNVNB161216.nix

      # Osi modules
      ../../modules/configs/osi
    ];

  networking.hostName = "biome-fest";

  sops.age = {
    generateKey = true;

    # Key to be generated
    keyFile = "/home/osi/.age-key.txt";

    # From which key to generate it
    sshKeyPaths = [ "/home/osi/.ssh/id_ed25519_sops" ];  
  };

  # Osi options
  osi = {
    # sops paths
    secrets = {
      openAiKey = "api-keys/open-ai";
      publicPgpKey = "pgp-keys/id-0x675D2CB5013E8731/public";
    };
  };
}
