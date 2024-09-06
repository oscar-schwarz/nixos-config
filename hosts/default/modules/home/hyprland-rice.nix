{ pkgs, config, ... }:

let
  border = {
    radius = 10;
    width = 3;
  };
  margin = 3;

  brightness-inactive = 0.7;

  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors;

  # Some functions
  str = builtins.toString; # need that a lot
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
            "&#xf244;" # battery-empty
            "&#xf243;" # battery-quarter
            "&#xf242;" # battery-half
            "&#xf241;" # battery-three-quarters
            "&#xf240;" # battery-full
          ];
        };
      };
    };
    style = with colors.withHashtag; ''
      /* Stylix colors */
      @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
      @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

      @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
      @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};

      * {
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: FontAwesome, ${fonts.sansSerif.name}, sans-serif;
        font-size: ${str fonts.sizes.desktop}px;
      }

      window#waybar {
        background-color: #00000000;
      }

      box.module {
        border-style: solid;
        border-width: ${str border.width}px;
        border-radius: ${str border.radius}px;
        border-color: @base03;

        background-color: @base00;

        color: @base05;
      }
    '';
  };

  # Hyprland itself
  wayland.windowManager.hyprland = {
    settings = {
      # --- General ---
      general = {
        border_size = border.width;
        gaps_out = margin;
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