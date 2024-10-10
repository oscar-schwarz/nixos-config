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

  # Auto mount my drive
  services.udisks2.settings = {
    "drives.conf" = {
      fs1 = {
        match-device = "uuid:9debc741-b5d9-4721-a2bc-971008511283";
        mount-options = "default";
        mount-point = "/home/osi/files/remote";
      };
    };
  };

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
