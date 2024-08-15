{ config, pkgs, lib, inputs, ...}:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    hotkeys.commands =
      let
        pythonZoomIn = pkgs.writeText "" ''
          import pyautogui
          pyautogui.scroll(1)     
        '';
        pythonZoomOut = pkgs.writeText "" ''
          import pyautogui
          pyautogui.scroll(-1)     
        '';
        zoomYakuake = pkgs.writeShellApplication {
          runtimeInputs = with pkgs; [
            python3
            python3Packages.pyautogui
          ];
          name = "zoom-yakuake";
          text = ''
            ZOOM_IN=''${1:-true}
            IS_ACTIVE=$(qdbus org.kde.yakuake /yakuake/MainWindow_1 org.qtproject.Qt.QWidget.isActiveWindow)

            if ! $IS_ACTIVE; then
              exit
            fi

            if $ZOOM_IN; then
              python ${pythonZoomIn}
            else
              python ${pythonZoomOut}
            fi
          '';
        };
      in  {
      yakuake-zoom-in = {
        name = "Yakuake Zoom In";
        key = "Ctrl++";
        command = lib.getExe zoomYakuake;
      };
    };
    configFile = {
      # -- yakuake --
      yakuakerc = {

        # Window appearance
        Window = {
          # don't occupy other windows
          KeepAbove = "false";
          # don't close when focus lost 
          KeepOpen = "true";
          # double F4 feels a lot better for some reason
          ToggleToFocus = "false";

          Height = "100";
          Width = "100";

          ShowTabBar = "false";
        };

        # Yakuake shortcuts
        Shortcuts = {
          # Creates a new session with 2x2 terminal grid
          new-session-quad = "Ctrl+Shift+Up";

          # Switches between sessions
          next-session = "Ctrl+Shift+Right";
          previous-session = "Ctrl+Shift+Left";

          # Switches between terminal within a session
          next-terminal = "Shift+Right";
          previous-terminal = "Shift+Left";

          # Set them to 'none' because their defaults conflict with above shortcuts
          move-session-left = "none";
          move-session-right = "none";
          
          toggle-window-state = "F4";
        };
      };

      # Autostart yakuake
      "autostart/org.kde.yakuake.desktop"."Desktop Entry" = {
        "DBusActivatable" = "true";
        "Exec" = "${lib.getExe pkgs.yakuake}";
        "Icon" = "yakuake";
        "Name" = "Yakuake";
        "Terminal" = "false";
        "X-DBUS-ServiceName" = "org.kde.yakuake";
        "X-DBUS-StartupType" = "Unique";
        "X-KDE-StartupNotify" = "false";
      };

    };
  };
}