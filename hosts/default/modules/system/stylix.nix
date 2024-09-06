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
      desktop = 1.0;
      terminal = 0.9;
    };

    cursor = {
      package = pkgs.graphite-cursors; 
      name = "graphite-dark";
      size = 25;
    };

    fonts = {
      monospace = {
        package = pkgs.source-code-pro;
        name = "SourceCodePro";
      };
      sansSerif = {
        package = pkgs.source-sans;
        name = "SourceSans3";
      };
      sizes = {
        popups = 25;
        desktop = 14;
        applications = 14;
      };
    };
  };

  home-manager.sharedModules = [
    ../../../../global-modules/home/yakuake-theme.nix
  ];
}