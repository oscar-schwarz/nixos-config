{
  writeShellApplication,
  nushell,
  openssh,
  ssh-to-age,
  age,
  ...
}:
writeShellApplication {
  name = "create-new-host";
  
  runtimeInputs = [
    nushell
    openssh
    ssh-to-age
    age
  ];
  
  text = ''
    nu ${./script.nu} "$@"
  '';
}
