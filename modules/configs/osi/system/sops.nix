{ lib, ... }:

{  
  sops.age.sshKeyPaths = [ "/home/osi/.ssh/id_ed25519_sops" ];

  sops.secrets = lib.attrsets.genAttrs [
    "api-keys/open-ai"
    "uni-leipzig/idm/user"
    "uni-leipzig/idm/secret"
    "osi/hashed-password"
  ] (name: { owner = "osi"; });
}