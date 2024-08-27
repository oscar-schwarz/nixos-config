{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wofi
  ];

  programs.kitty = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        border_size = 3;
      };

      decoration = {
        dim_inactive = true;
        dim_strength = 0.3;
      };

      monitor = [
        "eDP-1,preferred,auto,1"
        "desc:DZX EVP-304 000000000000, preferred, auto, 1, transform, 3"
      ];

      bezier = [
        "fast-in, 0.34, 0.12, 0.07, 0.96"
      ];
      animation = [
        "windows, 1, 3, fast-in, popin"
      ];

      input = {
        kb_layout = "us,de";
        kb_variant = "colemak,";
      };

      "$meta" = "SUPER";

      bind = let
        directions = [ "u" "d" "l" "r" ];

        arrowsByDirection = {
          u = "Up";
          d = "Down";
          l = "Left";
          r = "Right";
        };

        lettersByDirection = {
          u = "F";
          d = "S";
          l = "R";
          r = "T";
        };

        perDirection = keyByDirection: f: builtins.map (x: f x (keyByDirection."${x}")) directions;
        perDirectionLetter = perDirection lettersByDirection;  
        perDirectionArrow = perDirection arrowsByDirection;  
      in 
      (perDirectionLetter (dir: key: "$meta, ${key}, movefocus, ${dir}")) ++
      [
        # application shortcuts
        "$meta, N, exec, kitty"
        "$meta, E, exec, firefox"

        # launcher
        "$meta, O, exec, wofi --show drun"

        # window management
        "$meta, W, killactive"
        "$meta, M, fullscreen"
      ];
    };
  };
}