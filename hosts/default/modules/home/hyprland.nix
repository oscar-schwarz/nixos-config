{ ... }:

{
  programs.kitty = {
    enable = true;
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
          u = "f";
          d = "s";
          l = "a";
          r = "t";
        };

        perDirection = keyByDirection: f: builtins.map (x: f x (keyByDirection."${x}")) directions;
        perDirectionLetter = perDirection lettersByDirection;  
        perDirectionArrow = perDirection arrowsByDirection;  
      in 
      (perDirectionLetter (dir: key: "$meta, ${key}, movefocus, ${dir}")) ++
      [
        "$meta, N, exec, kitty"
        "$meta, F4, killactive"
      ];
    };
  };
}