{
  writeShellApplication,
  nushell,
  ssh-to-age,
  sops,
  age,
  ...
}:
writeShellApplication {
  name = "rotate-host-ssh-key";
  runtimeInputs = [ nushell ssh-to-age sops age ];
  text = ''
    nu ${./rotate-host-ssh-key.nu} "$@"
  '';
}