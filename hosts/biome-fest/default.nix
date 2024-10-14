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


  # Automount the bid hdd which is not always connected
  sops.secrets."drives/speicherfresser" = {owner = "osi"; mode = "0440";};
  environment.etc.crypttab.text = ''
    speicherfresser UUID=9debc741-b5d9-4721-a2bc-971008511283 ${config.sops.secrets."drives/speicherfresser".path} noauto
  '';
  services.udev.customRules = [
    { 
      name = "99-speicherfresser";
      rules = ''
        ACTION=="add" ENV{ID_WWN}=="0x5000c500a22a895e" TAG+="systemd" ENV{SYSTEMD_WANTS}="systemd-cryptsetup@speicherfresser.service"
      '';
    }
  ];
  fileSystems."/home/osi/files/remote" = {
    device = "/dev/disk/by-uuid/1c9bb556-309f-4add-a7f0-723a3b96b2f6";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
      "noauto"
    ];
  }
  ;
}
