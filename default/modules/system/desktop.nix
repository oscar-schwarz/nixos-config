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
      theme = "${pkgs.where-is-my-sddm-theme}";
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
    defaultSession = "plasma";
  };
}