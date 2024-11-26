{ ... }: 

{
  # All home manager specific options
  home-manager.sharedModules = [({ ... }: {

      # Config for hyprland
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

        # Desk monitors
        # I have two 1080p monitors one landscape and one portrait 
        
        # Main landscape monitor
        "desc:ViewSonic Corporation VA3209-QHD WYM241340384, 2560x1440, 0x240, 1"

        # external portrait monitor
        "desc:LG Electronics 27EA53 312NDNU32431, 1920x1080@50, 2560x0, 1, transform, 1"
        "desc:LG Electronics 27EA53 0x01010101, 1920x1080@50, 2560x0, 1, transform, 1"
        "desc:LG Electronics E2711 111NDBP2U853, 1920x1080, 2560x0, transform, 1"
      ];
    })];
}