{ pkgs, lib, config, ... }: 

{
  options.hypr-rotate-current-screen = with lib; {
    enable = mkEnableOption "Script that rotates the focused screen.";
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

          NEW_ROTATION=$((ROTATION + 1))

          # Apply new rotation
          hyprctl keyword monitor "$MONITOR, preffered, auto, auto, transform, $NEW_ROTATION"
        '';
      })
    ];
  };
}