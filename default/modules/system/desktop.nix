{ pkgs, lib, ... }:

{
	services.desktopManager = {
		# Enable Desktop Environment.
		plasma6.enable = true;
	};

  # Default should be wayland
  services.displayManager = {
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        # compositor = "kwin";
      };
    };
    defaultSession = "plasma";
  };
}