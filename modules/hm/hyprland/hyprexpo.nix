{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];
    
    # settings = {
    #   bind = [
    #     # workspace overview through hyprspace
    #     "$meta, V, overview:toggle"
    #   ];

    #   "plugin:overview" = {
    #     panelHeight = 200;
    #     showNewWorkspace = false;
    #     showEmptyWorkspace = true;
    #     hideTopLayers = true;
    #     hideBackgroundLayers = true;
    #     overrideGaps = false;
    #     disableGestures = true;
    #   };
    # };
  };
}