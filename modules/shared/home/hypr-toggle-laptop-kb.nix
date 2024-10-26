{ pkgs, lib, config, ... }:

let
  statusFilePath = ''STATUS_FILE="$XDG_RUNTIME_DIR/keyboard.status"'';

  isEnabled = pkgs.writeShellApplication {
    name = "hypr-toggle-laptop-kb-check";
    text = ''
      if ! [ -f ${statusFilePath} ]; then
        exit 1
      elif [ """$(cat ${statusFilePath})""" = "true" ]; then
        exit 0
      elif [ """$(cat ${statusFilePath})""" = "true" ]; then
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
          hyprctl keyword "\$LAPTOP_KB_ENABLED" "true" -r
      }

      disable_keyboard() {
          printf "false" >${statusFilePath}
          # notify-send -u normal "Disabling Keyboard"
          hyprctl keyword "\$LAPTOP_KB_ENABLED" "false" -r
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
  options.hypr-toggle-laptop-kb = with lib; {
    enable = mkEnableOption ''
      hypr-toggle-laptop-kb is a script that toggles the laptop keyboard.
    '';
    hyprDeviceName = mkOption {
      default = "at-translated-set-2-keyboard";
      description = ''
        The device name of the laptop keyboard shown in `hyprctl devices`
      '';
    };
    waybarIntegration = {
      enable = mkEnableOption ''
        Integrate hypr-toggle-laptop-kb into waybar as a custom button
      '';
      moduleName = mkOption {
        default = "hypr-toggle-laptop-kb";
        description = ''
          The name of the waybar module (without the "custom/" prefix)
        '';
      };
    };
  };

  config = lib.mkIf config.hypr-toggle-laptop-kb.enable {
    # Some defaults
    hypr-toggle-laptop-kb.waybarIntegration.enable = lib.mkDefault true;
    
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
          "name" = config.hypr-toggle-laptop-kb.hyprDeviceName;
          "enabled" = "$LAPTOP_KB_ENABLED";
        }
      ];
    };

    # Make a waybar module
    programs.waybar.settings = lib.mkIf config.hypr-toggle-laptop-kb.waybarIntegration.enable {
      "custom/${config.hypr-toggle-laptop-kb.waybarIntegration.moduleName}" = {
        on-click = lib.getExe toggleKB;
        interval = 1;
      };
    };
  };  
}
