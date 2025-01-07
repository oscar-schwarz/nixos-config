{ config, lib, ... }: 
let 
  literal = config.lib.formats.rasi.mkLiteral;
in {
  programs.rofi.theme = with config.lib.stylix.colors.withHashtag; {
    "*" = {
      lightbg = lib.mkForce (literal base00);
    };
    
    mainbox = {
      padding = literal "20px 20px";
      
      border-color = literal base0D;
      border-radius = literal "20px";
      border = literal "3px";

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
      text-color = lib.mkForce ( literal base0C );
    };
    listview = {
      scrollable = false;
    };
    element = {
      highlight = literal "bold underline";
      spacing = literal "5px";
      children = map literal [ "element-icon" "element-text" ];
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
      background-color = lib.mkForce ( literal base00 );
    };
  };
}