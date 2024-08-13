{pkgs, inputs, ...}:

{
  imports = [
      # secret management
      inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ../../../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  
  sops.age.keyFile = "/home/osi/.config/sops/age/keys.txt";

  sops.secrets = {
    "api-keys/open-ai" = { owner = "osi"; };
    "uni-leipzig/idm/user" = { owner = "osi"; };
    "uni-leipzig/idm/secret" = { owner = "osi"; };
  };
}