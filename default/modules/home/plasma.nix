{ config, nixosConfig, inputs, pkgs, lib, ... }:


let 
  konsoleThemeName = "nix-generated-theme";
  konsoleColorschemeName = "nix-generated-colorscheme";

  desktopEntries = {
    yakuake = {
      "Categories" = "Qt;KDE;System;TerminalEmulator;";
      "Comment[en_GB]" = "A drop-down terminal emulator based on KDE Konsole technology.";
      "Comment" = "A drop-down terminal emulator based on KDE Konsole technology.";
      "DBusActivatable" = "true";
      "Exec" = "yakuake";
      "GenericName[en_GB]" = "Drop-down Terminal";
      "GenericName" = "Drop-down Terminal";
      "Icon" = "yakuake";
      "Name[en_GB]" = "Yakuake";
      "Name" = "Yakuake";
      "Terminal" = "false";
      "Type" = "Application";
      "X-DBUS-ServiceName" = "org.kde.yakuake";
      "X-DBUS-StartupType" = "Unique";
      "X-KDE-StartupNotify" = "false";
    };
  };

  rgbString = baseName: "${config.lib.stylix.colors."${baseName}-rgb-r"},${config.lib.stylix.colors."${baseName}-rgb-g"},${config.lib.stylix.colors."${baseName}-rgb-b"}";

in
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

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
      yakuake = {
        "toggle-window-state" = "F4";
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
      "ksplashrc" = {
        "KSplash" = {
          "Engine" = "None";
          "Theme" = "None";
        };
      };

      # -- WIDGETS --
      # make task bar panel 60 wide
      "plasmashellrc" = {
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
      
      # -- yakuake --
      "yakuakerc" = {
        # skin
        "Appearance" = {
          Skin = "breeze-minimal";
          SkinInstalledWithKns = "true"; # Sometimes in life, lying is the way to go
        };
        # do not occupy other windows
        "Window"."KeepAbove" = "false";
        "Window"."KeepOpen" = "true";
        "Window"."ToggleToFocus" = "false";
        "Window"."Height" = "100";
        "Window"."Width" = "100";
        "Window"."ShowTabBar" = "false";
        "Desktop Entry"."DefaultProfile" = "${konsoleThemeName}.profile";
      };
      "autostart/org.kde.yakuake.desktop"."Desktop Entry" = desktopEntries.yakuake;
    };
  };

  # Yakuake theme
  home.file.".local/share/yakuake/kns_skins/breeze-minimal".source = builtins.fetchGit {
    url = "ssh://git@github.com/OsiPog/breeze-minimal.git";
    rev = "3142f04c467a19611bbbe145df48316305f6b684";
  };

  # Install my custom konsole theme
  home.file.".local/share/konsole/${konsoleThemeName}.profile" = {
    text = ''
      [Appearance]
      ColorScheme=${konsoleColorschemeName}
      Font=Hack,5,-1,5,50,0,0,0,0,0

      [General]
      Command=$SHELL
      Name=${konsoleThemeName}
      Parent=FALLBACK/
      TerminalCenter=true
      TerminalMargin=20

      [Interaction Options]
      TrimTrailingSpacesInSelectedText=true

      [Scrolling]
      ScrollBarPosition=2
    '';
  };

  # https://github.com/cskeeters/base16-konsole/blob/master/templates/default.mustache
  home.file.".local/share/konsole/${konsoleColorschemeName}.colorscheme" = {
    text = ''
      [Background]
      Color=${rgbString "base00"}

      [BackgroundIntense]
      Color=${rgbString "base03"}

      [Color0]
      Color=${rgbString "base00"}

      [Color0Intense]
      Color=${rgbString "base03"}

      [Color1]
      Color=${rgbString "base08"}

      [Color1Intense]
      Color=${rgbString "base08"}

      [Color2]
      Color=${rgbString "base0B"}

      [Color2Intense]
      Color=${rgbString "base0B"}

      [Color3]
      Color=${rgbString "base0A"}

      [Color3Intense]
      Color=${rgbString "base0A"}

      [Color4]
      Color=${rgbString "base0D"}

      [Color4Intense]
      Color=${rgbString "base0D"}

      [Color5]
      Color=${rgbString "base0E"}

      [Color5Intense]
      Color=${rgbString "base0E"}

      [Color6]
      Color=${rgbString "base0C"}

      [Color6Intense]
      Color=${rgbString "base0C"}

      [Color7]
      Color=${rgbString "base05"}

      [Color7Intense]
      Color=${rgbString "base07"}

      [Foreground]
      Color=${rgbString "base05"}

      [ForegroundIntense]
      Color=${rgbString "base07"}

      [General]
      Anchor=0.5,0.5
      Blur=true
      Description=color-scheme
      FillStyle=Tile
      Opacity=${lib.strings.floatToString config.stylix.opacity.terminal}
    '';
  };

}