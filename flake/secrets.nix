{
  pkgs,
  config,
  lib,
  ...
}: {
  options.getSopsFile = lib.mkOption {
    description = "A helper function to get the path to a sops secret.";
  };
  config = {
    getSopsFile = name: config.sops.secrets.${name}.path;

    environment.systemPackages = with pkgs; [
      sops
    ];

    # Setup the secrets file
    sops.defaultSopsFile = ../secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    # Generate the age key from a provided ssh key
    sops.age = {
      generateKey = true;

      # Key to be generated
      keyFile = "/root/.age-key.txt";

      # From which key to generate it
      # This only needs to be present on the machine that executes 'nixos-rebuild'
      sshKeyPaths = ["/root/.ssh/id_ed25519_sops"];
    };
  };
}
