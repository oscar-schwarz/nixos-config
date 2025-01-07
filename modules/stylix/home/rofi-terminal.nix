{ config, ... }: 
let 
  literal = config.lib.formats.rasi.mkLiteral;
in {
  stylix.targets.waybar.enable = true; # turn off stylix ricing that theme can be changed

  programs.rofi.theme = with config.lib.stylix.colors.withHashtag; {
    "*" = {
      background-color = literal base00;
    };

    mainbox = {
      padding = literal "20px 20px";
      
      border-color = literal base0D;
      border-radius = literal "20px";
      border-width = literal "3px";

      spacing = literal "5px";
      
      children = map literal [ "inputbar" "listview" "message" ];
    };

    inputbar = {
      margin-bottom = literal "5px";
      children = map literal [ "textbox-prompt-colon" "entry" ];
    };
    textbox-prompt-colon = {
      margin = literal "2px 6px 0px 0px";
      
      expand = false;
      
      str = ">";
      text-color = literal base0C;
    };
    entry = {
      text-color = literal base0B;
    };

    listview = {
      scrollable = false;
    };
    element = {
      highlight = literal "bold underline";
      spacing = literal "5px";
      children = map literal [ "element-icon" "element-text" ];
    };
    "element .normal" = {
      text-color = literal base07;
    };
    "element .urgent" = {
      text-color = literal base0F;
    };
    "element .active" = {
      text-color = literal base0B;
    };
    "element selected" = {
      background-color = literal base03;
    };
    element-text = {
      background-color = literal "inherit";
      foreground-color = literal "inherit";
      text-color = literal "inherit";
    };
    element-icon = {
      background-color = literal "inherit";
      foreground-color = literal "inherit";
      text-color = literal "inherit";
    };

    message = {
      background-color = literal base00;

      margin = literal "20px 5px 0px 5px";
    };
    textbox = {
      background-color = literal base00;
      text-color = literal base03;
    };
  };
}