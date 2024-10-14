{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true; 

  services.greetd = {
    enable = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      default_session = {
        command = lib.getExe pkgs.hyprland;
      };
    };
  };
}