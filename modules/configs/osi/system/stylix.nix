{ pkgs, ... }:

let
  # The base 16 colorscheme used, modify this to see a theme change!
  themeName = "oceanicnext";
  # themeName = "sakura";
  # themeName = "aztec";
in {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
    image = ../../../../images/nms.jpg;
    polarity = "dark";
    autoEnable = true;

    opacity = {
      desktop = 1.0;
      terminal = 1.0;
    };

    cursor = {
      package = pkgs.graphite-cursors; 
      name = "graphite-dark";
      size = 25;
    };

    fonts = {
      monospace = {
        package = pkgs.comic-mono;
        name = "ComicMono";
      };
      sansSerif = {
        package = pkgs.source-sans;
        name = "SourceSans3";
      };
      sizes = {
        popups = 18;
        desktop = 16;
        terminal = 12;
        applications = 13;
      };
    };
  };

  home-manager.sharedModules = [({...} : {
    stylix.targets = {
      firefox.profileNames = [ "default" ];
      vscode.profileNames = [ "default" ];
    };
  })];
}