{pkgs, ...}:

let
  # The base 16 colorscheme used, modify this to see a theme change!
  themeName = "oceanicnext";
  # themeName = "sakura";
  # themeName = "aztec";
in {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
    image = ../../images/nms.jpg;
    polarity = "dark";
    autoEnable = true;

    opacity = {
      desktop = 0.5;
      terminal = 0.9;
    };

    cursor = {
      package = pkgs.material-cursors; 
      name = "material_dark_cursors";
      size = 25;
    };

    fonts = {
      monospace = {
        package = pkgs.source-code-pro;
        name = "Source Code Pro";
      };
      sizes = {
        popups = 25;
      };
    };
  };

  home-manager.sharedModules = [
    ../../../../global-modules/home/yakuake-theme.nix
  ];
}