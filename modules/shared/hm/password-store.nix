{
  pkgs,
  config,
  lib,
  ...
}: let
  repositoryOrigin = "git@github.com:OsiPog/pass.git";

  inherit (builtins) match;
in {
  home.packages = [
    # a script to fetch the password store easily in the correct folder
    (pkgs.writeShellApplication {
      name = "pass-fetch";
      text = ''
        DEST_DIR="${config.programs.password-store.settings.PASSWORD_STORE_DIR}"

        if [ ! -d "$DEST_DIR" ]; then
          git clone "${repositoryOrigin}" "$DEST_DIR"
        else
          pass git pull
          pass git push
        fi
      '';
    })
  ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
    ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };

  # add plugin to rofi if enabled
  programs.rofi.pass = lib.mkIf config.programs.rofi.enable {
    enable = true;
    package =
      if (match ".*wayland.*" config.programs.rofi.package.name) != null
      then pkgs.rofi-pass-wayland
      else pkgs.rofi-pass;
  };
}
