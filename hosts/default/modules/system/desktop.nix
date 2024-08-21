{ pkgs, lib, config, ... }:

let
  sddmTheme = pkgs.where-is-my-sddm-theme.override {
    themeConfig.General = with config.lib.stylix.colors; {
      hideCursor = "true";
      passwordFontSize= "48";
      passwordInputWidth= "1";
      passwordCharacter= "•";
      
      # Colors
      backgroundFill = "#" + base00-hex;
      basicTextColor = "#" + base05-hex;
      passwordCursorColor = "#" + base0B-hex;
    };
  };
in {
  
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

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