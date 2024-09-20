{ pkgs, lib, inputs, ... }:

let
  vscodeExts = inputs.nix-vscode-extensions.extensions.x86_64-linux;
in {
    # code editor
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = {
      # extra stuff turned off
      "window.commandCenter" = false;
      "workbench.layoutControl.enabled" = false;
      "workbench.editor.showTabs" = "none";
      "window.menuBarVisibility" = "toggle"; # hide menu bar unless alt is pressed
      "workbench.startupEditor" = "none"; # no welcome page

      # Trust all workspaces
      "security.workspace.trust.enabled" = false;

      # minimap
      "editor.minimap.maxColumn" = 100;
      "editor.minimap.showSlider" = "always";
      "editor.minimap.renderCharacters" = false;

      # zen mode settings
      "zenMode.restore" = true;
      "zenMode.hideStatusBar" = true;
      "zenMode.showTabs" = "none";
      "zenMode.hideLineNumbers" = false;
      "zenMode.fullScreen" = false;
      "zenMode.centerLayout" = false;

      "php.debug.executablePath" = lib.getExe pkgs.php83;

      "files.exclude" = {
        "**/.git" = false;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${lib.getExe pkgs.nixd}";
      "nix.serverSettings" = {
        nixd =  {
          formatting = {
            command = ["${lib.getExe pkgs.nixpkgs-fmt}"];
          };
          options = {
            nixos = {
                expr = ''(builtins.getFlake "/home/osi/nixos").nixosConfigurations.default.options'';
            };
            home-manager = {
                expr = ''(builtins.getFlake "/home/osi/nixos").homeConfigurations.default.options'';
            };
          };
        };
      };
    };
    keybindings = [
      {
        key = "ctrl+k b";
        command = "merge-conflict.accept.both";
      }
      {
        key = "ctrl+k i";
        command = "merge-conflict.accept.incoming";
      }
      {
        key = "ctrl+k c";
        command = "merge-conflict.accept.current";
      }
      {
        # Open the search results as a text file in the editor
        key = "ctrl+enter";
        command = "search.action.openInEditor";
        when = "hasSearchResult && searchViewletFocus";
      }
    ];
    extensions = with vscodeExts.vscode-marketplace; with vscodeExts.open-vsx-release; [
      vue.volar 
      jnoortheen.nix-ide
      davidlgoldberg.jumpy2
      xdebug.php-debug
    ];
  };

}