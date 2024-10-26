{ pkgs, lib, config, ... }:

let
  statusFilePath = ''STATUS_FILE="$XDG_RUNTIME_DIR/keyboard.status"'';

  isEnabled = pkgs.writeShellApplication {
    name = "hypr-toggle-laptop-kb-check";
    text = ''
      if ! [ -f ${statusFilePath} ]; then
        exit 1
      elif [ $(cat ${statusFilePath}) = "true" ]; then
        exit 0
      elif elif [ $(cat ${statusFilePath}) = "true" ]; then
        exit 1
      fi
    '';
  };
  toggleKB = pkgs.writeShellApplication {
    name = "hypr-toggle-laptop-kb";
    text = ''
      export 

      enable_keyboard() {
          printf "true" >${statusFilePath}
          # notify-send -u normal "Enabling Keyboard"
          hyprctl keyword '$LAPTOP_KB_ENABLED' "true" -r
      }

      disable_keyboard() {
          printf "false" >${statusFilePath}
          # notify-send -u normal "Disabling Keyboard"
          hyprctl keyword '$LAPTOP_KB_ENABLED' "false" -r
      }

      if ! ${lib.getExe isEnabled}; then
        enable_keyboard
      else
        disable_keyboard
      fi
    '';
  };
in
{
  options.hypr-toggle-laptop-kb = with lib.mkOption; {
    hyprDeviceName = mkOption {
      default = "at-translated-set-2-keyboard";
      decription = ''
        The device name of the laptop keyboard shown in `hyprctl devices`
      '';
    };
  };

  config = {
    # Add it for use
    home.packages = [
      toggleKB
      isEnabled
    ];

    # Implement the script above
    wayland.windowManager.hyprland.settings = {
      "$LAPTOP_KB_ENABLED" = true;
      device = [
        {
          "name" = config.hypr-toggle-laptop.hyprDeviceName;
          "enabled" = "$LAPTOP_KB_ENABLED";
        }
      ];
    };

    # Make a waybar module
    programs.waybar.settings = {
      "custom/hypr-toggle-laptop-kb" = {
        on-click = lib.getExe toggleKB;
        interval = 1; 
      };
    };
  };  
}
