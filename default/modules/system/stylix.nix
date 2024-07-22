{pkgs, lib,  config, inputs, ...}:

let
  # The base 16 colorscheme used, modify this to see a theme change!
  themeName = "oceanicnext";
  # themeName = "sakura";
in {

  stylix = {
    enable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
    image = ../../images/nms.jpg;
    polarity = "dark";
    autoEnable = true;

    opacity = {
      desktop = 0.5;
      terminal = 0.9;
    };

    cursor = {
      # package = pkgs.quintom-cursor-theme; name = "Quintum_Snow";
      name = "breeze_cursors"; # KDE default, looks the best from what I've seen
      size = 25;
    };
  };
}