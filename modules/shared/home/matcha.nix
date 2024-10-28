{ pkgs, lib, config, ... }:
{
  options.matcha = with lib; {
    enable = mkEnableOption "a wayland idle inhibitor";
    waybarIntegration = {
      enable = mkEnableOption "declare a waybar module that can be used";
      moduleName = mkOption {
        default = "matcha";
        description = ''
          The name of the waybar module (without the "custom/" prefix)
        '';
      };
    };
  };

  config = lib.mkIf config.matcha.enable {
    home.packages = [
      pkgs.matcha

      (pkgs.writeShellScriptBin "matcha-toggle" ''
        if pidof matcha >/dev/null; then
          pkill matcha
        else
          matcha --daemon &
        fi 
      '')
    ];

    # Waybar integration
    programs.waybar.settings.mainBar = lib.mkIf config.matcha.waybarIntegration.enable {
      "custom/${config.matcha.waybarIntegration.moduleName}" = let 
        # Toggles matcha, kill if running, start if not running
        
        # Checks whether match is running
        statusCheck = pkgs.writeShellScript "" ''
          if pidof matcha>/dev/null; then
            echo -e '&#xe163; &#xf7b6;\nIdle Inhibitor Enabled'
          else
            echo -e '&#xe163; &#xf186;\nIdle Inhibitor Disabled'
          fi
        '';
      in {
        # Check status every second
        exec = statusCheck;
        interval = 1;
        # Toggle on click
        on-click = "matcha-toggle";
      };
    };
  };
}