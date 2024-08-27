{ ... }:

{
  programs.kitty = {
    enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = "../../images/nms.jpg";
      wallpaper = ", ../../images/nms.jpg";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
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
        "$meta, N, exec, kitty"
        "$meta, W, killactive"
        "$meta, M, fullscreen"
        "$meta, E, exec, firefox"
      ];
    };
    extraConfig = ''
      monitor = eDP-1,preferred,auto,1
      monitor = desc:DZX EVP-304 000000000000, preferred, auto, 1, transform, 3
    '';
  };
}