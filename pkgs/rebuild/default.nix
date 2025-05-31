runtimeInputs@{
  writeShellApplication,
  nushell,
  git,
  ...
}: writeShellApplication {
  inherit runtimeInputs;
  name = "rebuild";
  text = "nu ${./rebuild.nu}";
}