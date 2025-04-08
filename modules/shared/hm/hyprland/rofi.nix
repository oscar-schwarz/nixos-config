{ pkgs, ... }: 
{
  # Highly supported runner
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    plugins = with pkgs; [
      rofi-emoji-wayland
    ];
  };

  services.gpg-agent.pinentryPackage = pkgs.pinentry-rofi.override {
    rofi = pkgs.rofi-wayland;
  };

  wayland.windowManager.hyprland.settings.bind = [
    # Rofi menus
    # launcher
    "$meta, O, exec, pidof rofi || rofi -show drun"
    # window selector
    "$meta, E, exec, pidof rofi || rofi -show window"
    # emoji
    "$meta, U, exec, pidof rofi || rofi -show emoji"
    # Pass
    "$meta, P, exec, pidof rofi || rofi-pass"
  ];
}