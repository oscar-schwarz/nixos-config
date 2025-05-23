{ 
  pkgs,
  ...
}: let 
  columns = 6;
in {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];
    
    settings = {
      "plugin:hyprexpo" = {
        inherit columns;
        enable_gesture = false;
      };

      bind = [
        "$meta, O, hyprexpo:expo, toggle"
      ];


      animation = [
        "workspaces, 1, 5, default, slidevert"
      ];
    };
  };
}