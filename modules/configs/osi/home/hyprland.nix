{ pkgs, config, lib, ... }:

{
  imports = [
    # Styled
    ./hyprland-rice.nix

    # shared waybar module
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    rofi-emoji
    hyprshot
    hypridle
    brightnessctl
    hyprpaper
    hyprpolkitagent

    # Sometimes, when I would connect the laptop to the docking station, not all screens work.
    # This script disables all external screens at once and turns them on again (and this works lol)
    (pkgs.writeShellApplication {
      name = "hypr-fix-screens";
      text = ''
        # Enable eDP-1 (will crash if not enabled)
        hyprctl keyword monitor "eDP-1"

        # Get all connected monitors, (except eDP-1, the internal screen) and disable all of them
        hyprctl monitors \
        | grep Monitor \
        | awk '{print $2}' \
        | grep -v "eDP-1" \
        | xargs -I {} hyprctl keyword monitor "{}, disable"
        
        # Wait 2 seconds
        sleep 2
        
        # Reload config -> re-enables all configured monitors
        hyprctl reload

        # Disable eDP-1
        hyprctl keyword monitor "eDP-1, disable"
      '';
    })  
  ];

  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = "no";
    };
    extraConfig = ''
      # Thanks a lot to https://github.com/kovidgoyal/kitty-fosshack2024/issues/1
      map ctrl+shift+e launch --type=overlay --allow-remote-control ${pkgs.writeShellScript "" ''

        # Get all tabs, including their ids and focused status
        tab_info=$(kitty @ ls | ${pkgs.jq}/bin/jq -r '.[].tabs[] | "\(.id)|\(.is_focused)|\(.title)"')

        # Filter out the focused tab and prepare the list for fzf
        # Format: "last_directory (id: tab_id) | full_path | tab_id"
        tab_titles=$(echo "$tab_info" | awk -F'|' '$2 == "false" {
            split($3, path, "/")
            last_dir = path[length(path)]
            if (last_dir == "") last_dir = "/"
            print last_dir " (id: " $1 ") | " $3 " | " $1
        }')

        # Use fzf to fuzzy search the tab titles
        selected=$(echo "$tab_titles" | ${pkgs.fzf}/bin/fzf --prompt="Select tab: " \
            --height=60% \
            --layout=reverse \
            --border=rounded \
            --margin=10%,10% \
            --padding=1 \
            --with-nth=1 \
            --delimiter=' | ' \
            --preview='echo {2}' \
            --preview-window=up:1)

        # If a tab was selected, focus on that tab using its ID
        if [ -n "$selected" ]; then
            tab_id=$(echo "$selected" | awk -F' \\| ' '{print $3}')
            kitty @ focus-tab --match id:"$tab_id"
        else
            echo "No tab selected or operation cancelled."
        fi
      ''}
    '';
  };

  # Highly supported runner
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    plugins = with pkgs; [
      rofi-emoji-wayland
    ];

    pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland;
    };
  };
  services.gpg-agent.pinentryPackage = pkgs.pinentry-rofi.override {
    rofi = pkgs.rofi-wayland;
  };

  programs.waybar = {
    enable = true;
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        ignore_empty_input = true;
        grace = 10;
      };
      auth = {
        fingerprint.enabled = true;
      };
    };
  };


  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock --immediate --no-fade-in";
        ignore_systemd_inhibit = true;
        ignore_dbus_inhibit = true;
      };
      listener =
        let
          seconds = s: s;
          minutes = mins: builtins.floor (mins * 60);
          hours = h: builtins.floor (h * 3600);
        in
        [
          {
            timeout = minutes 3;
            on-timeout = "hyprlock"; # not using loginctl lock-session, because it adds it is without grace and animation
          }
          {
            timeout = minutes 4;
            on-timeout = "systemctl suspend";
          }
          {
            timeout = hours 4;
            on-timeout = "shutdown now";
          }
        ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      general = {
        # Allow to resize windows with dragging the border
        resize_on_border = true;
      };

      binds = {
        # To be able to move focus to another monitor even when maximized on current
        movefocus_cycles_fullscreen = false;
      };

      touchpad = {
        clickfinger_behavior = true;
      };

      # --- Autostart ---
      # run on every reload
      exec = [

      ];
      # run every start
      exec-once = [
        # Auth agent for gui apps
        "systemctl --user start hyprpolkitagent"
      ];

      # --- Monitors ---
      monitor = [
        # This needs to be here so that hyprlock does not crash
        "FALLBACK,1920x1080@60,auto,1"

        # Mirror new monitors to laptop monitor
        ", preffered, auto, 1, mirror, eDP-1"
      ];


      # --- Mouse settings ---
      cursor = {
        enable_hyprcursor = true;
      };

      # --- Keyboard settings ---
      input = {
        kb_layout = "us,de";
        kb_variant = "colemak,";
        kb_options = "ctrl:swap_rwin_rctl,grp:win_space_toggle";
      };


      # --- Keybindings ---
      "$meta" = "SUPER";

      bind =
        let
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
        (perDirectionArrow (dir: key: "$meta, ${key}, movefocus, ${dir}")) ++
        (perDirectionLetter (dir: key: "$meta_CTRL, ${key}, movewindow, ${dir}")) ++
        (perDirectionArrow (dir: key: "$meta_CTRL, ${key}, movewindow, ${dir}")) ++
        [
          # application shortcuts
          # Terminal
          "$meta, N, exec, kitty"
          # Firefox (or LibreWolf?)
          "$meta, I, exec, ${pkgs.writeShellScript "" ''
            # Test if librewolf is installed, if so run it
            if which librewolf; then
              librewolf
            # Fallback to firefox
            else
              firefox
            fi
          ''}"

          # Rofi menus
          # launcher
          "$meta, O, exec, pidof rofi || rofi -show drun"
          # window selector
          "$meta, E, exec, pidof rofi || rofi -show window"
          # emoji
          "$meta, U, exec, pidof rofi || rofi -show emoji"
          # Pass
          "$meta, P, exec, pidof rofi || rofi-pass"

          # lock screen
          "$meta, L, exec, loginctl lock-session"
          # lock screen and suspen
          "$meta_CTRL, L, exec, ${pkgs.writeShellScript "" ''
            loginctl lock-session
            systemctl suspend
          ''}"

          # window management
          "$meta, W, killactive"
          "$meta, M, fullscreen, 1"
          "$meta_CTRL, M, fullscreen"
          "$meta, K, togglefloating"

          # switch workspaces
          "$meta, J, workspace, r-1"
          "$meta, H, workspace, r+1"

          # move window to workspaceso
          "$meta_CTRL, J, movetoworkspace, r-1"
          "$meta_CTRL, H, movetoworkspace, r+1"

          # workspace overview through hyprspace
          "$meta, V, overview:toggle"

          # toggle waybar
          "$meta, B, exec, pkill waybar || waybar"

          # Taking screenshots
          "$meta_CTRL, A, exec, hyprshot -m region --freeze -- ${lib.getExe pkgs.annotator}"
          "$meta, A, exec, pidof hyprshot || hyprshot -m region --clipboard-only --freeze"
          "$meta, Z, exec, hyprshot -m output --clipboard-only"
        ];

      # Binds here will be repeated on press
      binde =
        let
          resizeFactor = "50";
        in
        [
          # resize window
          "$meta, G, resizeactive, -${resizeFactor} -${resizeFactor}"
          "$meta, D, resizeactive, ${resizeFactor} ${resizeFactor}"

          # Brightness keys
          ", code:233, exec, brightnessctl set +10%"
          ", code:232, exec, brightnessctl set 10%-"
          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume 0 +10%"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume 0 -10%"
        ];

      # binds that also works on a lockscreen
      bindl =
        let
          docked = pkgs.writeShellScript "" ''
            [ $(hyprctl monitors | grep -c '(ID ') -ge 2 ]
          '';

          closeLid = pkgs.writeShellScript "" ''
            # disable monitor if it is not the only one
            if ${docked}; then
              hyprctl keyword monitor "eDP-1, disable"
            # otherwise lock the screen
            else
              loginctl lock-session
            fi
          '';

          openLid = pkgs.writeShellScript "" ''
            # enable monitor
            hyprctl reload

            # Run hyprlock if laptop is not docked
            if ! ${docked}; then
              loginctl lock-session
            fi
          '';
        in
        [
          # switch behaviour
          ", switch:on:Lid Switch, exec, ${closeLid}"
          ", switch:off:Lid Switch, exec, ${openLid}"
        ];
      
      # The binds here are for the mouse
      bindm = [
        "$meta, mouse:272, movewindow" # Move when super and left click
        ", mouse:275, movewindow" # or with mouse 5 (lower side)
      ];


      # --- WINDOW RULES
      windowrulev2 = [
        "stayfocused, title:^Hyprland Polkit Agent$"
        # "dimaround, title:^Hyprland Polkit Agent$"
      ];

      # --- HYPRGRASS PLUGIN
      "plugin:touch-gestures" = {
        sensitivity = 4.0;
        workspace_swipe_fingers = 3;
        workspace_swipe_edge = false;
        edge_margin = 50;

        # Mouse binds
        hyprgrass-bindm= [
          ", longpress:3, movewindow"
          ", longpress:4, resizewindow"
        ];

        hyprgrass-bind = [
          ", swipe:4:u, movetoworkspace, r-1"
          ", swipe:4:d, movetoworkspace, r+1"
          ", edge:r:l, exec, pkill hyprshot || hyprshot -m region --clipboard-only --freeze"
          ", edge:l:r, overview:toggle" # swipe from left to right
          ", edge:u:d, exec, pkill waybar || waybar" # swipe from top to bottom
          # swipe from bottom to top does not work
        ];
      };

      gestures = {
        workspace_swipe = false;
        workspace_swipe_cancel_ratio = 0.15;
      };


      "plugin:overview" = {
        panelHeight = 200;
        showNewWorkspace = false;
        showEmptyWorkspace = false;
        hideTopLayers = true;
        hideBackgroundLayers = true;
        overrideGaps = false;
      };
    };

    plugins = with pkgs.hyprlandPlugins; [
      hyprgrass
      hyprspace
    ];
  };
}
