{
  writeShellApplication,
  nushell,
  ssh-to-age,
  ...
}:
writeShellApplication {
  name = "sops-multi-host";
  runtimeInputs = [ nushell ssh-to-age ];
  text = ''
    nu ${./sops-multi-host.nu} "$@"
  '';
}