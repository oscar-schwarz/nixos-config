{ ... }: 

{
  # All home manager specific options
  home-manager.sharedModules = [({ ... }: {
      wayland.windowManager.hyprland.settings.monitor = let
        # Sometimes the portable monitor is listed under different names
        portableMonitorConfigs = map
          (desc: "desc:${desc}, preferred, auto, 1, transform, 3")
          # here are all the different names the monitor might have 
          ["RGT 0x5211 0x00000401" "DZX EVP-304 000000000000"];

      in
      portableMonitorConfigs ++ [
        # Laptop built-in
        "eDP-1,preferred,auto,1"

        # external portrait monitor       
        "desc:LG Electronics 27EA53 312NDNU32431, preferred, auto, 1, transform, 1"
      ];

      # Waybar output on which monitor
      programs.waybar.settings.mainBar.output = ["eDP-1" "DP-3"];
    })];
}