{
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) elem;
  inherit (lib) getName;
in {
  nixpkgs.config.allowUnfreePredicate = p: elem (getName p) [
    "obsidian"
    "steam-unwrapped"
    "steam"
  ];
}