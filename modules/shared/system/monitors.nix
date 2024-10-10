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

        # Desk monitors
        # I have two 1080p monitors one landscape and one portrait 
        
        # Main landscape monitor
        "desc:Samsung Electric Company U28H75x HTPK700051, preferred, 0x420, 1"

        # external portrait monitor
        "desc:LG Electronics 27EA53 312NDNU32431, preferred, 1920x0, 1, transform, 1"
      ];
    })];
}