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
      theme = "${pkgs.where-is-my-sddm-theme}/share/sddm/themes/where_is_my_sddm_theme";
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
    defaultSession = "plasma";
  };
}