{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wofi-emoji
  ];

  programs.kitty = {
    enable = true;
    settings = {
      window_padding_width = 10;
    };
  };

  programs.wofi = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {

    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = let 
        gaps = 5;
      in {
        border_size = 3;
        gaps_out = gaps;
        gaps_in = gaps; 
      };

      decoration = {
        dim_inactive = true;
        dim_strength = 0.3;
      };

      monitor = let
        # Sometimes the portable monitor is listed under different names
        portableMonitorConfigs = map
          (desc: "desc:${desc}, preferred, auto, 1, transform, 3")
          # here are all the different names the monitor might have 
          ["RGT 0x5211 0x00000401" "DZX EVP-304 000000000000"];

      in
      portableMonitorConfigs ++ [
        # Laptop built-in
        "eDP-1,preferred,auto,1"

        # external portrait monitor       
        "desc:LG Electronics 27EA53 312NDNU32431, preferred, auto, 1, transform, 1"
      ];

      bindl = [
        '', switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1"''
        '', switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"''
      ];

      bezier = [
        "fast-in, 0.34, 0.12, 0.07, 0.96"
      ];
      animation = [
        "windows, 1, 3, fast-in, popin"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "colemak";
        kb_options = "ctrl:swap_rwin_rctl";
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

        openOrNotWofi = pkgs.writeShellApplication {
          name = "open-or-not-wofi";
          text = ''
            if [ "$(pidof wofi)" = "" ]; then
             wofi --show drun
            fi
          '';
        }; 
      in 
      (perDirectionLetter (dir: key: "$meta, ${key}, movefocus, ${dir}")) ++
      (perDirectionLetter (dir: key: "$meta_CTRL, ${key}, movewindow, ${dir}")) ++
      [
        # application shortcuts
        "$meta, N, exec, kitty"
        "$meta, E, exec, firefox"

        # launcher
        "$meta, O, exec, ${lib.getExe openOrNotWofi}"
        # emoji
        "$meta, ., exec, wofi-emoji"

        # window management
        "$meta, W, killactive"
        "$meta, M, fullscreen"
        "$meta, J, workspace, r-1"
        "$meta, H, workspace, r+1"
      ];
    };
  };
}