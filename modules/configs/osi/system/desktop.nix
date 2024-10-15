{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true; 

  # Important when using hyprland
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };
  
  services.greetd = let 
    command = pkgs.writeShellScript "" ''
      clear
      "${pkgs.hyprland}/bin/Hyprland"
    '';
  in {
    enable = true;
    settings = rec {
      # Run hyprland on boot (autologin)
      initial_session = {
        inherit command;
        user = "osi";
      };
      # user needs to authenticate on relogin
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${command}";
        user = "greeter";
      };
    };
  };
}