{ ... }:

{
  imports = [
    ../../../stylix/system/where-is-my-sddm-theme.nix
  ];

  programs.hyprland.enable = true; 

  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        # Erase password on failure
        blank_password = false;

        # Save settings
        save = true;

        # Hide ugly f keys hints at the top
        hide_key_hints = true;
      };
    };
    defaultSession = "hyprland";
  };
}