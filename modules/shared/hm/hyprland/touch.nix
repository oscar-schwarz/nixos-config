{ pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Touch input is sent to the currently focused monitor
    input.tablet.output = "current";

    # Plugin for touch inputs
    plugins = with pkgs.hyprlandPlugins; [
      hyprgrass
    ];

    # settings for above plugin
    "plugin:touch-gestures" = {
      sensitivity = 4.0;
      workspace_swipe_fingers = 3;
      workspace_swipe_edge = false;
      edge_margin = 50;

      # Mouse binds
      hyprgrass-bindm = [
        ", longpress:3, movewindow"
        ", longpress:4, resizewindow"
      ];

      hyprgrass-bind = [
        ", swipe:4:u, movetoworkspace, r-1"
        ", swipe:4:d, movetoworkspace, r+1"
        ", edge:r:l, exec, pkill hyprshot || hyprshot -m region --clipboard-only --freeze"
        ", edge:l:r, overview:toggle" # swipe from left to right
        ", edge:u:d, exec, pkill waybar || waybar" # swipe from top to bottom
        # swipe from bottom to top does not work
      ];
    };
  };
}