{ pkgs, ... }:

{
  home.packages = [
    pkgs.matcha
  ];

  # Waybar integration
  programs.waybar.settings.mainBar = {
    modules-right = [
      "custom/matcha"
    ];

    "custom/matcha" = let 
      # Toggles matcha, kill if running, start if not running
      toggleProgram = pkgs.writeShellScript "" ''
        if [ '$(pidof matcha)' != "" ]; then
          pkill matcha
        else
          matcha --deamon &
        fi 
      '';
      # Checks whether match is running
      statusCheck = pkgs.writeShellScript "" ''
        if [ '$(pidof matcha)' != "" ]; then
          echo -e '&#xf7b6;&#xe163;\nEnabled'
        else
          echo -e '&#xf186;&#xe163;\nDisabled'
        fi
      '';
    in {
      # Check status every second
      exec = statusCheck;
      interval = 1;
      # Toggle on click
      on-click = toggleProgram;
    };
  };
}