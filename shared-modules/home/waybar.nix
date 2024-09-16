{ pkgs, ... }:

let
  # Set of font awesome name and unicode code
  fa-icons = {
    bolt = "f0e7";
    mug-saucer = "f0f4";
    mug-hot = "f7b6";
    display = "e163";
    moon = "f186";

    battery-full = "f240";
    battery-three-quarters = "f241";
    battery-half = "f242";
    battery-quarter = "f243";
    battery-empty = "f244";
  };
  # get html unicode escape sequence for font awesome icon name
  fa = name: "&#x" + fa-icons.${name} + ";";
in {
  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome
  ];

  # Autostart on hyprland
  wayland.windowManager.hyprland.settings.exec-once = [
    "waybar"
  ];

  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        

        # Module placement
        modules-left = [

        ];
        modules-center = [
          "clock#time"
          "clock#date"
        ];
        modules-right = [
          "custom/hypridle-toggle"
          "battery"
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
          tooltip = false;
        };
        "clock#date" = {
          format = "{:%A, %d. %B %Y}";
          tooltip = false;
        };

        "custom/hypridle-toggle" = {
          exec = pkgs.writeShellScript "" ''
            if [ -z "$(pidof hypridle)" ]; then 
              echo ${fa "moon"}
            else
              echo ${fa "mug-hot"}
            fi
          '';
          on-click = pkgs.writeShellScript "" ''
            PID="$(pidof hypridle)"

            if [ -z "$(PID)" ]; then
              hypridle &
            else
              kill "$PID"
            fi
          '';
        };
      };
    };
  };
}