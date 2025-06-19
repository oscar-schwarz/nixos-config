{
  pkgs,
  lib,
  config,
  ...
}: let
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

  # Generate a PNG or SVG image of the NixOS logo fitting the colorscheme
    lib.stylix.nixos-logo = {
      blue ? "blue",
      cyan ? "cyan",
      svg ? false,
      size ? 256, # ignored when svg is true
    }:
      pkgs.runCommand "stylix-nixos-logo.${if svg then "svg" else "png"}" {
        inherit size;
        blue = config.lib.stylix.colors.${blue};
        cyan = config.lib.stylix.colors.${cyan};
        svg = if svg then "true" else "false";
        img = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      } ''
        sed "
          s/699ad7/$cyan/g;
          s/7eb1dd/$cyan/g;
          s/7ebae4/$cyan/g;
          s/415e9a/$blue/g;
          s/4a6baf/$blue/g;
          s/5277c3/$blue/g;
        " $img > $out

        if ! $svg; then
          cp $out $TMPDIR/svg
          ${lib.getExe' pkgs.imagemagick "convert"} $TMPDIR/svg -resize "$size""x""$size" $out
        fi
      '';

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
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/oceanicnext.yaml";
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

      targets = {
        # plymouth.logo = pkgs.runCommand "tinted-nixos-256x256-png" {} ''
        #   ${pkgs.imagemagick}/bin/convert -resize 256x256
        # '';
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

    nixpkgs.overlays = [(final: prev: {
      fastfetch = prev.fastfetch;
    })];

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
