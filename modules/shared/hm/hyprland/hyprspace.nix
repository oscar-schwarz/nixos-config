{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # workspace overview through hyprspace
      "$meta, V, overview:toggle"
    ];

    # Plugin for overview over workspaces
    plugins = with pkgs.hyprlandPlugins; [
      hyprspace
    ];

    plugin.overview = {
      panelHeight = 200;
      showNewWorkspace = false;
      showEmptyWorkspace = true;
      hideTopLayers = true;
      hideBackgroundLayers = true;
      overrideGaps = false;
      disableGestures = true;
    };
  };
}