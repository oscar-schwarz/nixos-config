args@{ lib, pkgs, config, ... }:

let
  border = {
    radius = 10;
    width = 3;
  };
  margin = 3;
  terminal-padding = 7;

  brightness-inactive = 0.7;

  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors;
  opacity = config.stylix.opacity;

  rgbString = colorID:
      builtins.concatStringsSep ","
        (map (x: config.lib.stylix.colors."${colorID}-${x}") ["rgb-r" "rgb-g" "rgb-b"]);

in {

  imports = [
    # Waybar styling from stylix that is based of stylix terminal
    (import ../../../stylix/home/waybar-terminal.nix 
      (args // {
        inherit border;
        inherit margin;
        inherit terminal-padding;
      })
    )

    # Rofi styling
    ../../../stylix/home/rofi-terminal.nix
  ];

  # Terminal
  programs.kitty.settings = {
    # Text is moved a bit inwards, like that its not so close to the border
    window_padding_width = terminal-padding;
  };

  # Hyprlock
  programs.hyprlock.settings = {
    general = {
      hide_cursor = true;
    };
    background = {
      monitor = "";
      path = lib.mkForce "screenshot";
      blur_passes = 4;
      blur_size = 10;
    };
    input-field = {
      monitor = "";

      outline_thickness = border.width;
      rounding = border.radius;

      # TODO: Should be removed once PR merged 
      # https://github.com/danth/stylix/pull/619
      outer_color = "rgb(${colors.base03})";
      inner_color = "rgb(${colors.base00})";
      font_color = "rgb(${colors.base05})"; 
      fail_color = "rgb(${colors.base08})";


      check_color = lib.mkForce "rgb(${colors.base0D})";

      fade_on_empty = true;

      placeholder_text = "";
      fail_text = "";

      fail_timeout = 500;
    };
  };

  # Hyprland itself
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprfocus
    ];

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
        rounding = border.radius;

        blur = {
          enabled = true;
        };
      };

      cursor = {
        hide_on_key_press = true;
        inactive_timeout = 1;
      };

      # --- Animations ---
      bezier = [
        "fast-in, 0.34, 0.12, 0.07, 0.96"
      ];
      animation = [
        "windows, 1, 3, fast-in, popin"
        "workspaces, 1, 5, default, slidevert"
        "layersIn, 1, 3, fast-in"
      ];

      # --- Layerrules
      layerrule = [
        "animation popin, rofi"
        "dimaround, rofi"
      ];

      # --- Plugins ---
      plugin = {
        # --- Hyprfocus, flash aniomation on focus change
        hyprfocus = {
          enabled = "yes";
          focus_animation = "flash";
          flash = {
            flash_opacity = 0.8;
          };
        };
      };
    };
  };
}