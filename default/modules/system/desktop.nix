{ pkgs, lib, ... }:

{
	services.xserver.desktopManager = {
		# Enable Desktop Environment.
		plasma5.enable = true;
	};

  # Default should be wayland
  services.displayManager = {
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
    defaultSession = "plasmawayland";
  };
}