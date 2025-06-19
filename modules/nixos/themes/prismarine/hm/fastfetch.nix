{
  pkgs,
  lib,
  config,
  ...
}: let
  tintedNixosSvg = pkgs.callPackage (import ../../../../../lib/tint-nixos-svg.nix config.lib.stylix.colors) {};
in {
  # programs.fastfetch.settings.logo = {
  #   width = lib.mkDefault 40;
  #   source = tintedNixosSvg;
  # };
}
