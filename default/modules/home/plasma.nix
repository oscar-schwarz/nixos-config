{ config, nixosConfig, inputs, pkgs, lib, ... }:

{
  programs.plasma = {
    enable = true;

    # -- HOTKEYS --
    # custom
    hotkeys.commands = {
      "launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+K";
        command = "konsole";
      };
    };
    # kwin
    shortcuts = {
      kwin = {
        "Window Maximize" = "Meta+M";
        "Expose" = "Meta+O";
      };
      "org.kde.spectacle.desktop" = {
        "RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };

    # low level config editing
    configFile = {
      # -- KWIN --
      "kwinrc" = {
        "Effect-windowview" = {
          "TouchBorderActivate" = "4";
        };
        "Input" = {
          "TabletMode" = "off";
        };
      };

      # -- SETTINGS --
      # Laptop touchpad settings
      # wayland
      "kcminputrc" = {
        "Libinput/1739/52856/MSFT0001:00 06CB:CE78 Touchpad" = {
          "ClickMethod" = "2";
          "NaturalScroll" = "true";
          "TapToClick" = "true";
          "DisableWhileTyping" = "false";
        };
        "Mouse" = {
          # take the cursor from stylix
          "cursorTheme" = "default";
        };
      };
      #  x11 version, dont use that
      # "touchpadxlibinputrc"."MSFT0001:00 06CB:CE78 Touchpad" = {
      #   "clickMethodAreas" = {
      #     value = "false";
      #     immutable = true;
      #   };
      #   "clickMethodClickfinger" = {
      #     value = "true";
      #     immutable = true;
      #   };
      #   "naturalScroll" = {
      #     value = "true";
      #     immutable = true;
      #   };
      # };

      # -- LOOK AND FEEL --
      ksplashrc = {
        KSplash = {
          Engine = "None";
          Theme = "None";
        };
      };

      # -- WIDGETS --
      # make task bar panel 60 wide
      plasmashellrc = {
        "PlasmaViews/Panel 2/Defaults" = {
          thickness = "60";
          immutability = "1";
        };
      };

      "plasma-org.kde.plasma.desktop-appletsrc" = {
        # set nix logo as application menu icon (immutable must be set through "immutability" attribute)
        "Containments/2/Applets/3/Configuration/General" = {
          icon = "nix-snowflake";
          immutability = "1";
        };
        # make task bar a side panel
        "Containments/2" = {
          formfactor = "3";
          location = "5";
          immutability = "1";
        };
        # Task manager
        "Containments/2/Applets/5/Configuration/General" = {
          launchers = "applications:systemsettings.desktop" # Settings
          + ",preferred://filemanager" # Dolphin
          + ",preferred://browser" # Firefox
          + ",applications:signal-desktop.desktop" # Signal
          + ",applications:codium.desktop"; # Codium
          immutability = "1";
        };
        # Date display
        "Containments/2/Applets/18/Configuration/Appearance" = {
          customDateFormat = "dd.MM.yy";
          dateFormat = "custom";
        };
      };
    };
  };
}