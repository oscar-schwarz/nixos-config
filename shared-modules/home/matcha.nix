{ pkgs, ... }:

{
  home.packages = [
    pkgs.matcha
  ];

  # Run at the start of hyprland
  wayland.windowManager.hyprland.settings.exec-once = [ "pkill matcha;matcha --daemon --off" ];

  # Waybar integration
  programs.waybar.settings.mainBar = {
    left_modules = [
      "custom/matcha"
    ];

    "custom/matcha" = {
      exec = "matcha --toggle -b waybar";
    };
  };
}