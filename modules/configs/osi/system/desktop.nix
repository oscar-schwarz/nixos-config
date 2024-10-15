{ pkgs, ... }:

{
  programs.hyprland.enable = true; 

  # Important when using hyprland
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };
  
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "osi";
      };
      default_session = initial_session;
    };
  };
}