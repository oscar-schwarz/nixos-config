{
  writeShellApplication,
  nushell,
  ssh-to-age,
  sops,
  age,
  ...
}:
writeShellApplication {
  name = "sops";
  runtimeInputs = [ nushell ssh-to-age sops age ];
  text = ''
    nu ${./sops-wrapper.nu} "$@"
  '';
}