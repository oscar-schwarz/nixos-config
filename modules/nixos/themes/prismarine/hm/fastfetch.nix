{
  pkgs,
  lib,
  config,
  nixosConfig,
  ...
}: {
  programs.fastfetch.settings.logo = {
    width = lib.mkDefault 40;
    source = nixosConfig.lib.stylix.nixos-logo {svg = true;};
  };
}
