username: { 
  config,
  lib,
  ... 
}: {
  sops.secrets = {
    "pass-hashes/${username}" = {neededForUsers = true;};
  };

  users.users.${username} = {
    isNormalUser = true;
    description = lib.toUpper username;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.getSopsFile "pass-hashes/${username}";
 
    createHome = true;
    home = "/home/${username}";
 
    useDefaultShell = true;
  };
}
