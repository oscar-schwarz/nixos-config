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

  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        # Module placement
        modules-left = [
          "custom/rofi-drun"
          "hyprland/window"
          "custom/hypr-window-close"
        ];
        modules-center = [
          "clock#time"
          "clock#date"
        ];
        modules-right = [
          "battery"
          "network"
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
          exec = pkgs.writeShellScript "" ''
            if [ "$(hyprctl activewindow)" != "Invalid" ]; then
              echo ${fa "xmark"}
            fi
          '';
          interval = 1;
          hide-empty-text = true;

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
        ];

        modules-center = [
          "custom/wvkbd-mobintl"
          "custom/hypr-toggle-laptop-kb"
          "idle_inhibitor"
          "custom/hypr-rotate-current-screen"
          "custom/hyprshot"
        ];

        modules-right = [
          "backlight"
          "backlight/slider"
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

        "idle_inhibitor" = {
          format = (fa "laptop") + " {icon}";
          format-icons = {
            deactivated = fa "moon";
            activated = fa "mug-hot";
          };
        };

        "custom/wvkbd-mobintl" = {
          format = fa "keyboard";
          on-click = pkgs.writeShellScript "" ''
            wvkbd-mobintl || wvkbd-mobintl -H 300 -L 300
          '';
        };

        "custom/hyprshot" = {
          format = (fa "camera") + " " + (fa "display"); 
          on-click = pkgs.writeShellScript "" ''
            pkill hyprshot || hyprshot -m region --clipboard-only --freeze
          '';
        };
      };
    };
  };
}