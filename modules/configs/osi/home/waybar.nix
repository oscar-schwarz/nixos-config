{ pkgs, ... }:

let
  # Set of font awesome name and unicode code
  fa-icons = {
    battery-empty = "f244";
    battery-full = "f240";
    battery-half = "f242";
    battery-quarter = "f243";
    battery-three-quarters = "f241";
    bluetooth-b = "f294"; 
    bolt = "f0e7";
    camera = "f030";
    display = "e163";
    download = "f019";
    ellipsis = "f141";
    expand = "f065";
    keyboard = "f11c";
    laptop = "f109";
    lightbulb = "f0eb";
    moon = "f186";
    mug-hot = "f7b6";
    mug-saucer = "f0f4";
    network-wired = "f6ff";
    upload = "f093";
    volume-high = "f028";
    volume-xmark = "f6a9";
    wifi = "f1eb";
    xmark = "f00d";
  };
  # get html unicode escape sequence for font awesome icon name
  fa = name: "&#x" + fa-icons.${name} + ";";
in {
  imports = [
    ../../../shared/home/hypr-toggle-laptop-kb.nix
    ../../../shared/home/hypr-rotate-current-screen.nix
    ../../../shared/home/matcha.nix
  ];

  # Options for my hypr-toggle-laptop-kb module
  hypr-toggle-laptop-kb = {
    enable = true;
    waybarIntegration = {
      enable = true;
      barName = "bottomBar";
    };
    toggleOnLidSwitch.enable = true;
  };
  # Options for matcha idle inhibitor module
  matcha = {
    enable = true;
    waybarIntegration = {
      enable = true;
      barName = "bottomBar";
    };
  };
  hypr-rotate-current-screen = {
    enable = true;
    waybarIntegration = {
      enable = true;
      barName = "bottomBar";
    };
  };

  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome

    wvkbd # on-screen keyboard
    ];

  wayland.windowManager.hyprland.settings.exec = [
    (pkgs.writeShellScript "waybar-handler" ''
      # The time interval (in miliseconds) for checking the cursor position.
      INTERVAL=200

      # How many miliseconds does the waybar stay on while the cursor is not on it
      THRESHOLD=8000

      # Initialize the counter.
      counter=0

      while true; do
        # Get the cursor position.
        cursor_pos=$(hyprctl cursorpos)
        cursor_x=$(echo $cursor_pos | cut -d, -f1)
        cursor_y=$(echo $cursor_pos | cut -d, -f2)

        # Get the current screen's dimensions for the focused monitor.
        screen_info=$(hyprctl monitors | grep "focused: yes" -B 10 | grep @)
        screen_height=$(echo $screen_info | sed 's/^.*x\([0-9]*\)@.*$/\1/')

        # Calculate the critical y-range positions.
        low_limit=50
        high_limit=$((screen_height - 50))

        low_activate=0
        high_activate=$((screen_height - 1))

        # Check if the cursor is on the edge of the screen if so, activate the waybar        
        if (( cursor_y == high_activate || cursor_y == low_activate)); then
          pidof waybar || waybar & # only launch if not launched already
        fi


        # Only close waybar when its running

        if pidof waybar; then
          # Check if the cursor y-position not on the waybar
          if (( cursor_y > low_limit || cursor_y < high_limit )); then
            # Cursor is on the waybar then reset the counter
            counter=0
          else
            # Increment the counter since the cursor is not on the waybar
            ((counter = counter + INTERVAL))

            # Check if the counter has reached the threshold kill the waybar
            if (( counter >= THRESHOLD )); then
              pkill waybar
            fi
          fi
        else
          counter=0
        fi

        # Wait for the next interval.
        sleep $(awk -v ms="$INTERVAL" 'BEGIN {print ms / 1000}')
      done
    '')
  ];

  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        # Module placement
        modules-left = [
          "battery"
          "network"
        ];
        modules-center = [
          "clock#time"
          "clock#date"
        ];
        modules-right = [
          "custom/hypr-window-close"
          "hyprland/window"
          "custom/rofi-drun"
        ];

        # Module settings
        battery = {
          states = {
            warning = 30;
            critical = 15;
            fatal = 5;
          };

          format = "{icon} {capacity} %";

          # State specific formats
          format-fatal = (fa "battery-empty") + "! {capacity} %";
          
          # Status specific formats
          format-charging = (fa "bolt") + " {icon} {capacity} %";
          
          format-icons = map fa [
            "battery-quarter"
            "battery-half"
            "battery-three-quarters"
            "battery-full"
          ];

          interval = 2;
        };

        "clock#time" = {
          format = "{:%H:%M}";
        };
        "clock#date" = {
          format = "{:%A, %d. %B %Y}";
        };

        "network" = {
          format-ethernet = (fa "network-wired");
          format-wifi = (fa "wifi") + " {essid}";
          tooltip-format = ''${fa "download"} {bandwidthDownBits}  ${fa "upload"} {bandwidthUpBits}'';
        };

        "hyprland/window" = {
          format = "{class}";
          icon = true;
          icon-size = 18;
          seperate-outputs = true;
          rewrite = {
            # sometimes window classes formed like: com.github.xournalpp.xournalpp
            # this regex shows only the last string
            "^(?:.+?\\.)+(.+)$" = "$1";
          };
          on-click = pkgs.writeShellScript "" ''
            hyprctl dispatch fullscreen 1
          '';
        };
        "custom/hypr-window-close" = {
          format = fa "xmark";
          on-click = pkgs.writeShellScript "" ''
            hyprctl dispatch killactive
          '';
        };

        "custom/rofi-drun" = {
          format = fa "ellipsis";
          on-click = pkgs.writeShellScript "" ''
            pkill rofi || rofi -show drun 
          '';
        };
      };
      bottomBar = {
        layer = "top";
        position = "bottom";
        
        modules-left = [
          "pulseaudio"
          "pulseaudio/slider"
          "backlight"
          "backlight/slider"
        ];

        modules-right = [
          "custom/hypr-rotate-current-screen"
          "custom/hypr-toggle-laptop-kb"
          "custom/matcha"
          "custom/hyprshot"
          "custom/wvkbd-mobintl"
        ];

        "backlight" = {
          format = fa "lightbulb";
        };
        "backlight/slider" = {
          min = 2;
        };

        "pulseaudio" = {
          format = fa "volume-high";
          format-bluetooth = (fa "bluetooth-b") + " " + (fa "volume-high");
        };

        "custom/wvkbd-mobintl" = {
          format = fa "keyboard";
          on-click = pkgs.writeShellScript "" ''
            pkill wvkbd-mobintl || wvkbd-mobintl -H 300 -L 300
          '';
        };

        "custom/hyprshot" = {
          format = (fa "display") + " " + (fa "camera"); 
          on-click = pkgs.writeShellScript "" ''
            pkill hyprshot || hyprshot -m region --clipboard-only --freeze
          '';
        };
      };
    };
  };
}