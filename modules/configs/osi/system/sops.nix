{ lib, ... }:

{  
  sops.age.keyFile = "/home/osi/.config/sops/age/keys.txt";

  sops.secrets = lib.attrsets.genAttrs [
    "api-keys/open-ai"
    "uni-leipzig/idm/user"
    "uni-leipzig/idm/secret"
    "osi/hashed-password"
  ] (name: { owner = "osi"; });
}