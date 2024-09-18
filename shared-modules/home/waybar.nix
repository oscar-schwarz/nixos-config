{ pkgs, ... }:

let
  # Set of font awesome name and unicode code
  fa-icons = {
    bolt = "f0e7";
    mug-saucer = "f0f4";
    mug-hot = "f7b6";
    display = "e163";
    moon = "f186";
    lightbulb = "f0eb";

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
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock#time"
        ];
        modules-right = [
          "idle_inhibitor"
          "battery"
          "backlight"
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
          tooltip = "{:%A, %d. %B %Y}";
        };

        "idle_inhibitor" = {
          format = "{icon} " + (fa "display"); 
          format-icons = {
            activated = fa "mug-hot";
            deactivated = fa "moon";
          };
        };

        "backlight" = {
          format = (fa "lightbulb") + " {percent} %";
          states = {
            maximum = 100;
          };
        };

        "hyprland/workspaces" = {
          persistant-workspaces = {
            "*" = builtins.genList (x: x+1 ) 5;
          };
        };
      };
    };
  };
}