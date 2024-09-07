{ pkgs, config, lib, ... }:

let
  border = {
    radius = 10;
    width = 3;
  };
  margin = 3;
  terminal-padding = 7;

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

  # Set of font awesome name and unicode code
  fa-icons = {
    bolt = "f0e7";

    battery-full = "f240";
    battery-three-quarters = "f241";
    battery-half = "f242";
    battery-quarter = "f243";
    battery-empty = "f244";
  };
  fa = name: "&#x" + fa-icons.${name} + ";";

  filterStr = str: cs: builtins.concatStringsSep "" (lib.filter (c: ! builtins.elem c cs) (lib.splitString "" str));
in {
  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome
    fonts.monospace.package
  ];

  # Terminal
  programs.kitty = {
    settings = {
      # Text is moved a bit inwards, like that its not so close to the border
      window_padding_width = terminal-padding;
    };
  };

  # Waybar is ric
  stylix.targets.waybar.enable = false; # turn off stylix ricing that style.css can be changed
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        

        # Module placement
        modules-left = [

        ];
        modules-center = [
          "clock#time"
          "clock#date"
        ];
        modules-right = [
          "battery"
        ];


        # Module settings
        battery = {
          states = {
            full = 100;
            fine = 90;
            warning = 30;
            critical = 15;
            fatal = 5;
          };

          format = "{icon} {capacity} %";
          format-fatal = "{icon}! {capacity} %";
          
          "format-not-charging" = "{icon} 100 %";
          format-charging = (fa "bolt") + " {icon} {capacity} %";
          
          format-icons = map fa [
            "battery-empty"
            "battery-quarter"
            "battery-half"
            "battery-three-quarters"
            "battery-full"
          ];

          interval = 2;
        };

        "clock#time" = {
          format = "{:%H:%M}";
          tooltip = false;
        };
        "clock#date" = {
          format = "{:%A, %d. %B %Y}";
          tooltip = false;
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

      i {
        font-style: normal;
        color: @base0B;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
      }

      .modules-left, .modules-center, .modules-right {
        padding-top: ${str margin}px;
      }
      .modules-left {
        padding-left: ${str margin}px;
      }
      .modules-right {
        padding-right: ${str margin}px;
      }


      /* BASE STYLE OF MODULES */
      .module {
        border-style: solid;
        border-width: ${str border.width}px;
        border-radius: ${str border.radius}pt;
        border-color: @base03;

        margin-left: ${str margin}px;
        margin-right: ${str margin}px;

        padding: ${str terminal-padding}px;

        background-color: rgba(${rgbString "base00"}, ${str opacity.terminal});

        color: @base05;

        transition-property: all;
        transition-duration: 0.1s;
        transition-timing-function: ease-in-out;
      }

      /* SHORT BORDER CHANGE ON UPDATE */
      ${builtins.concatStringsSep "\n" (
        map (selector: let animationName = "notifyChange" + (filterStr selector ["#" "."]); in ''
          @keyframes ${animationName} {
            0% {
              border-color: @base03;
            }
            50% {
              border-color: @base0D;
            }
            100% {
              border-color: @base03;
            }
          }
          ${selector} {
            animation: ${animationName} 1s ease-in-out;
            animation-play-state: running;
          } 
        '') [
          "#battery.charging" 
          "#battery.not_charging"
          "#battery.discharging"
        ]
      )}

      /* BATTERY */
      label#battery.not-charging {
        color: @base0B;
      }
      #battery.warning {
        color: @base0A;
      }
      #battery.critical {
        color: @base09;
      }
      #battery.fatal {
        color: @base08;
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

        blur = {
          enabled = true;
        };
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