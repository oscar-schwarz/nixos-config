{
  pkgs,
  lib,
  ...
}: let
  # The base 16 colorscheme used, modify this to see a theme change!
  # themeName = "oceanicnext";
  # themeName = "sakura";
  # themeName = "aztec";
  themeName = "hopscotch";

  # helper
  absoluteNixFilesInDir = dir:
    pipe (readDir dir) [
      (filterAttrs (_: value: value == "regular"))
      attrNames
      (map (path: dir + "/${path}"))
    ];

  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (builtins) readDir;
  inherit (lib) mkOption types pipe;
in {
  # Some options not handled by stylix
  options.prismarineTheme = {
    border-radius = mkOption {
      description = "The border radius of windows, widgets, etc. (in pixels)";
      type = types.int;
    };
    border-width = mkOption {
      description = "The border width of windows, widgets, etc. (in pixels)";
      type = types.int;
    };
    margin = mkOption {
      description = "The margin around windows, widgets, etc. (in pixels)";
      type = types.int;
    };
    padding = mkOption {
      description = "The padding inside terminal-like windows, widgets, etc. (in pixels)";
      type = types.int;
    };
  };

  config = {
    # Implement the defined options from above
    prismarineTheme = {
      border-radius = 3;
      border-width = 5;
      margin = 3;
      padding = 5;
    };

    # Stylix does the heavy lifting when it comes to styling here
    stylix = {
      enable = true;
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
      base16Scheme = ./anya.yaml;
      image = ./anya.jpg;
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

    # Enable plymouth for boot
    boot = {
      plymouth.enable = true;
      kernelParams = [
        "quiet"
        "splash"
      ];
    };

    # import additional modules
    # import = (absoluteNixFilesInDir ./nixos);

    home-manager.sharedModules =
      (absoluteNixFilesInDir ./hm)
      ++ [
        ({pkgs, ...}: {
          # consisent icon theme
          home.packages = with pkgs; [
            adwaita-icon-theme
          ];
          # little fix for gtk apps
          gtk.iconTheme.name = "Adwaita";

          stylix.targets = {
            firefox.profileNames = ["default"];
            vscode.profileNames = ["default"];
          };
        })
      ];
  };
}
