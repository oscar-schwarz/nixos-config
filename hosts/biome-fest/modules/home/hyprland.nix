{ pkgs, lib, ... }:

let 
  execIfNotRunning = command: pkgs.writeShellScript "" ''
      if [ "$(pidof ${builtins.elemAt (lib.splitString " " command) 0})" = "" ]; then
        ${command}
      fi
    '';
in {
  imports = [
    # Styled
    ./hyprland-rice.nix

    # shared waybar module
    ../../../../shared-modules/home/waybar.nix

  ];

  home.packages = with pkgs; [
    wofi-emoji
    xdg-desktop-portal-hyprland

    hypridle
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
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };
      background = {
        monitor = "";
        path = "screenshot";
        blur_passes = 4;
        blur_size = 10;
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
      };
      listener = let 
        MinsToSecs = mins: builtins.floor (mins*60);
      in [  
        {
          timeout = MinsToSecs 1.5;
          on-timeout = "systemctl suspend";
        }
        {
          timeout = MinsToSecs 5;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
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
      in 
      (perDirectionLetter (dir: key: "$meta, ${key}, movefocus, ${dir}")) ++
      (perDirectionLetter (dir: key: "$meta_CTRL, ${key}, movewindow, ${dir}")) ++
      [
        # application shortcuts
        "$meta, N, exec, kitty"
        "$meta, E, exec, firefox"

        # launcher
        "$meta, O, exec, pidof wofi || wofi --show drun"
        # emoji
        "$meta, U, exec, pidof wofi || wofi-emoji"

        # window management
        "$meta, W, killactive"
        "$meta, M, fullscreen, 1"
        "$meta_CTRL, M, fullscreen"

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
        
        # Brightness keys
        ", code:233, exec, brightnessctl set +10%"
        ", code:232, exec, brightnessctl set 10%-"
      ];

      # locked, also works on a lockscreen
      bindl = let
        closeLid = pkgs.writeShellScript "" ''
          # Run hyprlock if not started
          pidof hyperlock || hyprlock &
          
          # disable monitor     
          hyprctl keyword monitor "eDP-1" disable
        '';

        openLid = pkgs.writeShellScript "" ''
          # enable screen
          hyprctl keyword monitor "eDP-1"

          # Run hyprlock if not started
          pidof hyprlock || hyprlock 
        '';
      in [
        # switch behaviour
        ", switch:on:Lid Switch, exec, ${closeLid}"
        ", switch:off:Lid Switch, exec, ${openLid}"
      ]; 
    };
  };
}