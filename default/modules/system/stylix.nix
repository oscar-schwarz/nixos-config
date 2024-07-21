{pkgs, lib,  config, ...}:

let
  themeName = "oceanicnext";
in {
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
    image = ../../images/nms.jpg;
    polarity = "dark";
    autoEnable = false;

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