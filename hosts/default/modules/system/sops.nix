{ ... }:

{  
  sops.age.keyFile = "/home/osi/.config/sops/age/keys.txt";

  sops.secrets = {
    "api-keys/open-ai" = { owner = "osi"; };
    "uni-leipzig/idm/user" = { owner = "osi"; };
    "uni-leipzig/idm/secret" = { owner = "osi"; };
  };
}