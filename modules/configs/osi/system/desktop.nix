{ pkgs, lib, ... }:

{
  programs.hyprland.enable = true; 

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