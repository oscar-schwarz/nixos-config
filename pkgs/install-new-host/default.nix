{
  writeShellApplication,
  nushell,
  ...
}:
writeShellApplication {
  name = "sops";
  runtimeInputs = [ nushell ];
  text = ''
    nu ${./install-new-host.nu} "$@"
  '';
}