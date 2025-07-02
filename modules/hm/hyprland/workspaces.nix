{ 
  pkgs,
  ...
}: let 
  columns = 6;
in {
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      # hyprexpo
      hyprspace
    ];
    
    settings = {
      # "plugin:hyprexpo" = {
      #   inherit columns;
      #   enable_gesture = false;
      #   workspace_method = "center current";
      # };

      bind = [
        # "$meta, O, hyprexpo:expo, toggle"
        "$meta, O, overview:toggle"
      ];


      animation = [
        "workspaces, 1, 5, default, slidevert"
      ];
    };
  };
}