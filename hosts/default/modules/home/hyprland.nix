{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wofi-emoji

    # font-awesome # for waybar icons
    font-awesome_5

    xdg-desktop-portal-hyprland
  ];

  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

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
      mainBar = {
        height = 35;
        modules-center = [
          "clock"
        ];
        modules-left = [
          "battery"
        ];

        battery = {
          format = ''<div class="icon battery">{icon}</div> {capacity}%'';
          format-icons = [
            
          ];
        };
      };
    };
  };
  stylix.targets.waybar.enable = false;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {


      # --- General ---
      general = let 
        gaps = 8;
      in {
        border_size = 3;
        gaps_out = gaps;
        gaps_in = builtins.div gaps 2;
      };

      misc = {
        disable_hyprland_logo = true; # hyprpaper is already running
        disable_splash_rendering = true; # not visible due to hyprpaper
      };

      decoration = {
        dim_inactive = true;
        dim_strength = 0.3;
      };


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


      # --- Animations ---
      bezier = [
        "fast-in, 0.34, 0.12, 0.07, 0.96"
      ];
      animation = [
        "windows, 1, 3, fast-in, popin"
        "workspaces, 1, 5, default, slidevert"
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