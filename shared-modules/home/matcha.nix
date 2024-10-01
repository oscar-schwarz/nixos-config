{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "matcha" ''
        MATCHA_WAYBAR_OFF='&#xf186;&#xe163;\nDisabled'
        MATCHA_WAYBAR_ON='&#xf7b6;&#xe163;\nEnabled'
        ${pkgs.matcha}/bin/matcha "$@"
    '')
  ];

  # Run at the start of hyprland
  wayland.windowManager.hyprland.settings.exec-once = [ "pkill matcha;matcha --daemon" ];

  # Waybar integration
  programs.waybar.settings.mainBar = {
    modules-right = [
      "custom/matcha"
    ];

    "custom/matcha" = {
      exec = "matcha --toggle -b waybar";
      interval = "once";
    };
  };
}