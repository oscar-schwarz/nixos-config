{ pkgs, lib, ... }:

let
  sddmTheme = pkgs.where-is-my-sddm-theme.override {
    themeConfig.General = {
      hideCursor = "true";
      passwordFontSize= "48";
      passwordInputWidth= "1";
      passwordCharacter= "•";
    };
  };
in {
	services.desktopManager = {
		# Enable Desktop Environment.
		plasma6.enable = true;
	};

  # Default should be wayland
  services.displayManager = {
    sddm = {
      enable = true;
      theme = "${sddmTheme}/share/sddm/themes/where_is_my_sddm_theme";
      wayland = {
        enable = true;

        compositor = "kwin";
      };
    };
    defaultSession = "plasma";
  };
}