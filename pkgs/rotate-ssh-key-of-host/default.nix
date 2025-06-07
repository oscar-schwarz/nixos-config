{
  writeShellApplication,
  nushell,
  openssh,
  ssh-to-age,
  sops,
  age,
  ...
}:
writeShellApplication {
  name = "rotate-ssh-key-of-host";
  
  runtimeInputs = [
    nushell
    openssh
    ssh-to-age
    sops
    age
  ];
  
  text = ''
    nu ${./script.nu} "$@"
  '';
}
