{ config, lib, ... }:
with config.stylix.fonts;
{
  programs.vscode.userSettings = {
    "editor.fontSize" = lib.mkForce sizes.terminal;
    "debug.console.fontSize" = lib.mkForce sizes.terminal;
    "markdown.preview.fontSize" = lib.mkForce sizes.terminal;
    "terminal.integrated.fontSize" = lib.mkForce sizes.terminal;
    "chat.editor.fontSize" = lib.mkForce sizes.terminal;
  };
}