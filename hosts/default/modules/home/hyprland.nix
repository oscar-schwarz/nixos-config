{ pkgs, lib, ... }:

{
  imports = [
    ./hyprland-rice.nix
  ];

  home.packages = with pkgs; [
    wofi-emoji
    xdg-desktop-portal-hyprland
  ];

  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = "no";
    };
  };

  programs.wofi = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        

        # Module placement
        modules-left = [

        ];
        modules-center = [
          "clock"
          "clock#date"
        ];
        modules-right = [
          "battery"
        ];


        # Module settings
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

        clock = {
          format = "<base0B>{:%H:%M}</base0B>";
          tooltip = false;
        };
        "clock#date" = {
          format = "{%A, %d. %B %Y}";
          tooltip = false;
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # --- Autostart ---
      exec-once = [
        "waybar"
      ];


      # --- Display setup
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

      # --- Keyboard settings ---
      input = {
        kb_layout = "us";
        kb_variant = "colemak";
        kb_options = "ctrl:swap_rwin_rctl";
      };


      # --- Keybindings ---
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
        "$meta, U, exec, wofi-emoji"

        # window management
        "$meta, W, killactive"
        "$meta, M, fullscreen"

        # switch workspaces
        "$meta, J, workspace, r-1"
        "$meta, H, workspace, r+1"

        # move window to workspaces
        "$meta_CTRL, J, movetoworkspace, r-1"
        "$meta_CTRL, H, movetoworkspace, r+1"
      ];

      # Binds here will be repeated on press
      binde = let
         resizeFactor = "50";
      in [
        # resize window
        "$meta, G, resizeactive, -${resizeFactor} -${resizeFactor}"
        "$meta, D, resizeactive, ${resizeFactor} ${resizeFactor}"
      ];

      # locked, also works on a lockscreen
      bindl = [
        # switch behaviour
        '', switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1"''
        '', switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"''
      ]; 
    };
  };
}