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
    # Keybindings
    # `when` makes the keybind only available in certain contexts: more on that here
    # https://code.visualstudio.com/api/references/when-clause-contexts
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

      # Comments
      { # Line
        key = "ctrl+/";
        command = "editor.action.commentLine";
        when = "editorTextFocus && !editorReadonly";
      }
      { # Block
        key = "ctrl+shift+/";
        command = "editor.action.blockComment";
        when = "editorTextFocus && !editorReadonly";
      }
      { # phpDoc block
        key = "ctrl+enter";
        command = "phpdoc-generator.generatePHPDoc";
        when = "editorLangId == php";
      }

      # Imports
      { # PHP Imports
        key = "ctrl+o i";
        command = "namespaceResolver.import";
        when = "editorLangId == php";
      }

      # Diff
      {
        key = "ctrl+shift+l";
        command = "toggle.diff.renderSideBySide";
      }
    ];
    extensions = with vscodeExts.vscode-marketplace; with vscodeExts.open-vsx-release; [
      # UTILITIES
      davidlgoldberg.jumpy2 # jumping cursors with short letter combo 

      # PHP
      xdebug.php-debug # debugging php applications
      ronvanderheijden.phpdoc-generator # generate php doc comments
      mehedidracula.php-namespace-resolver # php everything namespace
    
      # NIX
      jnoortheen.nix-ide # nix language features

      # NODE
      vue.volar # vue language features 
    ];
  };

  # Set VSCodium to be git editor
  programs.git.extraConfig = let codium = "codium --wait --new-window"; in {
    core.editor = "codium --wait";
    diff.tool = "vscodium";
    "difftool \"vscodium\"".cmd = codium + " --diff $LOCAL $REMOTE";
    merge.tool = "vscodium";
    "mergetool \"vscodium\"".cmd = codium + " \"$MERGED\"";
  };
}