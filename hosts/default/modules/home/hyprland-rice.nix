{ pkgs, ... }:

let
  border = {
    radius = 10;
    width = 3;
  };
  margin = 3;

  brightness-inactive = 0.7;

in {
  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome_5
  ];

  # Terminal
  programs.kitty = {
    settings = {
      # Text is moved a bit inwards, like that its not so close to the border
      window_padding_width = 10;
    };
  };

  # Waybar is completely rice
  stylix.targets.waybar.enable = false; # turn off stylix ricing that style.css can be changed
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        height = 30;
        modules-left = [

        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "battery"
        ];

        battery = {
          format = "<span>{icon}</span> {capacity} %";
          format-icons = [
            "&#xf240;" # battery-full
            "&#xf241;" # battery-three-quarters
            "&#xf242;" # battery-half
            "&#xf243;" # battery-quarter
            "&#xf244;" # battery-empty
          ];
        };
      };
    };
  };

  # Hyprland itself
  wayland.windowManager.hyprland = {
    settings = {
      # --- General ---
      general = {
        border_size = border.width;
        gaps_out = margin * 2;
        gaps_in = margin;
      };

      misc = {
        disable_hyprland_logo = true; # hyprpaper is already running
        disable_splash_rendering = true; # not visible due to hyprpaper
      };

      decoration = {
        dim_inactive = true;
        dim_strength = 1 - brightness-inactive;

        rounding = border.radius;
      };


      # --- Animations ---
      bezier = [
        "fast-in, 0.34, 0.12, 0.07, 0.96"
      ];
      animation = [
        "windows, 1, 3, fast-in, popin"
        "workspaces, 1, 5, default, slidevert"
      ];
    };
  };
}