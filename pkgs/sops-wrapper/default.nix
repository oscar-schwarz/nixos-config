{
  writeShellApplication,
  nushell,
  ssh-to-age,
  sops,
  ...
}:
writeShellApplication {
  name = "sops";
  runtimeInputs = [ nushell ssh-to-age sops ];
  text = ''
    nu ${./sops-multi-host.nu} "$@"
  '';
}