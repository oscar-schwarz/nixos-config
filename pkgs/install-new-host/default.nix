{
  writeShellApplication,
  nushell,
  ...
}:
writeShellApplication {
  name = "install-new-host";
  runtimeInputs = [ nushell ];
  text = ''
    nu ${./install-new-host.nu} "$@"
  '';
}