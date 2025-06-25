{
  writeShellApplication,
  nushell,
  openssh,
  sops,
  ssh-to-age,
  age,
  sshpass,
  ...
}:
writeShellApplication {
  name = "manage-hosts";
  
  runtimeInputs = [
    nushell
    openssh
    ssh-to-age
    age
    sops
    sshpass
  ];
  
  text = ''
    nu ${./.}/manage-hosts.nu "$@"
  '';
}
