{
  writeShellApplication,
  nushell,
  git,
  ...
}: writeShellApplication {
  name = "rebuild";
  runtimeInputs = [ nushell git ];
  text = "nu ${./rebuild.nu}";
}