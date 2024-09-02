{ ... }:

{
  imports = [
    ../../../../global-modules/stylix-where-is-my-sddm-theme.nix
  ];

  programs.hyprland.enable = true; 

  services.displayManager = {
    sddm = {
      enable = true;
      wayland = {
        enable = true;
      };
    };
    defaultSession = "hyprland";
  };
}