{ pkgs, lib, config, ... }: 

{
  options.hypr-rotate-current-screen = with lib; {
    enable = mkEnableOption "Script that rotates the focused screen.";
    waybarIntegration = {
      enable = mkEnableOption "Integrate hypr-rotate-current-screen into waybar as a custom button";
      moduleName = mkOption {
        default = "hypr-rotate-current-screen";
        description = ''
          The name of the waybar module (without the "custom/" prefix)
        '';
      };
    };
  };

  config = lib.mkIf config.hypr-rotate-current-screen.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "hypr-rotate-current-screen";
        text = ''
          # Find currently focused monitor
          MONITOR="$(hyprctl monitors | grep -B 11 'focused: yes' | grep Monitor | awk '{print $2}')"

          # Find current rotation of that monitor
          ROTATION="$(hyprctl monitors | grep -B 1 'focused: yes' | grep 'transform' | awk '{print $2}')"

          # Find the scale
          SCALE="$(hyprctl monitors | grep -B 2 'focused: yes' | grep 'scale' | awk '{print $2}')"

          NEW_ROTATION=$((ROTATION + 1))

          if [ "$NEW_ROTATION" = "4" ]; then
            NEW_ROTATION=0
          fi

          # Apply new rotation
          hyprctl keyword monitor "$MONITOR, preffered, auto, $SCALE, transform, $NEW_ROTATION"
        
          # Little hack to also rotate touchscreens when laptop built-in screen is focused
          if [ "$MONITOR" = "eDP-1" ]; then
            hyprctl keyword input:touchdevice:transform $NEW_ROTATION            
            hyprctl keyword input:tablet:transform $NEW_ROTATION            
          fi
        '';
      })
    ];

    programs.waybar.settings.mainBar = lib.mkIf config.hypr-rotate-current-screen.waybarIntegration.enable {
      "custom/${config.hypr-rotate-current-screen.waybarIntegration.moduleName}" = {
        on-click = "hypr-rotate-current-screen";
        format = "&#xf26c; &#xf2ea;";
        tooltip-format = "Rotate Current Monitor";
      };
    };
  };
}