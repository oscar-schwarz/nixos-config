{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true; 

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = lib.getExe pkgs.greetd.tuigreet;
      };
    };
  };
}