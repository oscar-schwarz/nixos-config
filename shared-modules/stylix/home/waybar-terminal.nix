{ 
  border ? {
    radius = 10;
    width = 3;
  },
  margin ? 3,
  terminal-padding ? 7,

  config, lib, ... 
}:

let
  # Defined by stylix somewhere else
  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors;
  opacity = config.stylix.opacity;

  # Some functions
  str = builtins.toString; # need that a lot
  # Function that takes a base16 color id (like 0A) and outputs a string with rgb values (like "129,89,199)
  rgbString = colorID:
      builtins.concatStringsSep ","
        (map (x: config.lib.stylix.colors."${colorID}-${x}") ["rgb-r" "rgb-g" "rgb-b"]);

  filterStr = str: cs: builtins.concatStringsSep "" (lib.filter (c: ! builtins.elem c cs) (lib.splitString "" str));
in {
  stylix.targets.waybar.enable = false; # turn off stylix ricing that style.css can be changed
  programs.waybar = {
    style = with colors.withHashtag;''
      /* STYLIX COLORS */
      @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
      @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

      @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
      @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};


      /* FONT SETTINGS */
      * {
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: "${fonts.monospace.name}";
        font-weight: 500;
        font-size: ${str fonts.sizes.terminal}pt;
      }


      window#waybar {
        /* transparent background */
        background-color: rgba(0, 0, 0, 0);
      }

      .modules-left, .modules-center, .modules-right {
        padding-top: ${str margin}px;
      }
      .modules-left {
        padding-left: ${str margin}px;
      }
      .modules-right {
        padding-right: ${str margin}px;
      }


      /* BASE STYLE OF MODULES */
      .module {
        border-style: solid;
        border-width: ${str border.width}px;
        border-radius: ${str border.radius}pt;
        border-color: @base03;

        margin-left: ${str margin}px;
        margin-right: ${str margin}px;

        padding: ${str terminal-padding}px;

        background-color: rgba(${rgbString "base00"}, ${str (opacity.terminal * 0.9)});

        color: @base05;

        transition: all 0.3s ease;
      }

      .module:hover {
        border-color: @base0D;
        background-color: rgba(${rgbString "base00"}, ${str opacity.terminal});
      }

      /* SHORT BORDER CHANGE ON UPDATE */
      ${builtins.concatStringsSep "\n" (
        map (selector: 
        let 
          animationName = "notifyChange" + (filterStr selector ["#" "."]); 
        
          defaultStyle = ''
            border-color: @base03;          
          '';

          emphasizedStyle = ''
            border-color: @base0D;
          '';
        in ''
          @keyframes ${animationName} {
            0% {
              ${defaultStyle}
            }
            25% {
              ${emphasizedStyle}
            }
            75% {
              ${emphasizedStyle}
            }
            100% {
              ${defaultStyle}
            }
          }
          ${selector} {
            animation: ${animationName} 1s ease-in-out;
            animation-play-state: running;
          } 
        '') [
          "#battery.charging" 
          "#battery.not_charging"
          "#battery.discharging"
        ]
      )}


      /* BATTERY */
      label#battery:not(.charging):not(.discharging) {
        color: @base0B;
      }
      #battery.warning {
        color: @base0A;
      }
      #battery.critical {
        color: @base09;
      }
      #battery.fatal {
        color: @base08;
      }
    '';
  };
}