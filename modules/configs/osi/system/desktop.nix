{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true; 

  # Important when using hyprland with ly
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  services.displayManager.ly = { 
    enable = true;

    settings = {
      # Erase password on failure
      blank_password = true;

      # Save user
      save = true;

      # Hide ugly f keys info
      hide_key_hints = true;
    };
  };
}