{ lib, ... }:

{  
  sops.age.sshKeyPaths = [ "/home/osi/.ssh/id_ed25519_sops" ];
  sops.age.keyFile = "/home/osi/.age-key.txt";
  sops.age.generateKey = true;

  sops.secrets = lib.attrsets.genAttrs [
    "api-keys/open-ai"
    "uni-leipzig/idm/user"
    "uni-leipzig/idm/secret"
    "osi/hashed-password"
  ] (name: { owner = "osi"; });
}