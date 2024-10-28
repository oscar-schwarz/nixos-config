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
    network-wired = "f6ff";
    wifi = "f1eb";
    download = "f019";
    upload = "f093";

    battery-full = "f240";
    battery-three-quarters = "f241";
    battery-half = "f242";
    battery-quarter = "f243";
    battery-empty = "f244";    
  };
  # get html unicode escape sequence for font awesome icon name
  fa = name: "&#x" + fa-icons.${name} + ";";
in {
  imports = [
    ../../../shared/home/hypr-toggle-laptop-kb.nix
  ];

  # Options for my hypr-toggle-laptop-kb module
  hypr-toggle-laptop-kb = {
    enable = true;
    waybarIntegration.enable = true;
  };

  # Allow installation of fonts through home.packages
  fonts.fontconfig.enable =  true;

  home.packages = with pkgs; [  
    # font-awesome # for waybar icons
    font-awesome
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
        ];
        modules-right = [
          "custom/hypr-toggle-laptop-kb"
          "battery"
          "backlight"
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
          tooltip-format = "{:%A, %d. %B %Y}";
        };

        "backlight" = {
          format = (fa "lightbulb") + " {percent} %";
          states = {
            maximum = 100;
          };
        };

        "network" = {
          format-ethernet = (fa "network-wired");
          format-wifi = (fa "wifi") + " {essid}";
          tooltip-format = ''${fa "download"} {bandwidthDownBits}  ${fa "upload"} {bandwidthUpBits}'';
        };
      };
    };
  };
}