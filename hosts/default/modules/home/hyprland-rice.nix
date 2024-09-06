{ pkgs, config, ... }:

let
  border = {
    radius = 10;
    width = 3;
  };
  margin = 5;
  terminal-padding = 10;

  brightness-inactive = 0.7;

  # Defined by stylix somewhere else
  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors;
  opacity = config.stylix.opacity;

  # Some functions
  str = builtins.toString; # need that a lot
  # Function that takes a base16 color id (like 0A) and outputs a string with rgb values (like "129,89,199)
  rgbString = colorID:
      builtins.concatStringsSep ","
        (map (x: config.lib.stylix.colors."${colorID}-${x}") ["rgb-r" "rgb-g" "rgb-b"]);
in {
  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome_5
    fonts.monospace.package
  ];

  # Terminal
  programs.kitty = {
    settings = {
      # Text is moved a bit inwards, like that its not so close to the border
      window_padding_width = terminal-padding;
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
    style = with colors.withHashtag;''
      /* Stylix colors */
      @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
      @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

      @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
      @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};

      * {
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: "${fonts.monospace.name}";
        font-weight: 500;
        font-size: ${str fonts.sizes.terminal}pt;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
      }

      .modules-left, .modules-center, .modules-right {
        padding-top: ${str (margin*2)}px;
      }
      .modules-left {
        padding-left: ${str (margin*2)}px;
      }
      .modules-right {
        padding-right: ${str (margin*2)}px;
      }


      .module {
        border-style: solid;
        border-width: ${str border.width}px;
        border-radius: ${str border.radius}pt;
        border-color: @base03;

        /* needs additional margin because screen edge */
        margin-top: ${str margin}px;

        padding: ${str terminal-padding}px;

        background-color: rgba(${rgbString "base00"}, 0.9);

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
        gaps_out = margin * 2; # screen edge margin is not a double margin
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