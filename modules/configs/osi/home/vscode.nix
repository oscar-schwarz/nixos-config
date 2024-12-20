{ pkgs, lib, inputs, ... }:

let
  vscodeExts = inputs.nix-vscode-extensions.extensions.x86_64-linux;
in {

  # Make codium default
  xdg.mimeApps.defaultApplications = lib.attrsets.genAttrs [
    "text/plain"
    "text/x-c"
    "text/x-c++src"
    "text/x-java"
    "text/x-python"
    "text/x-shellscript"
    "application/json"
    "application/xml"
    "application/javascript"
    "text/html"
    "text/css"
    "text/x-markdown"
    "text/x-yaml"
    "application/x-php"
    "application/x-ruby"
    "application/x-perl"

  ] (type: "codium.desktop");

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.overrideAttrs (prev: with builtins; with lib.strings; {
      # As NIXOS_OZONE_WL is enabled, it is tried here too. But VSCodium shows a warning that is it an
      # unsupported parameter. This hack removes that parameter added by the environment variable.
      preFixup = concatStringsSep "\n" (
        # Filter out the line containing the parameter that causes the warning
        filter
          (str: (match ".*ozone-platform-hint.*" str) == null)
          (splitString "\n" prev.preFixup)
      );
    });
    userSettings = {
      # --- VSCODE ---
      # extra stuff turned off
      "window.commandCenter" = false;
      "workbench.layoutControl.enabled" = false;
      "workbench.editor.showTabs" = "none";
      "window.menuBarVisibility" = "toggle"; # hide menu bar unless alt is pressed
      "workbench.startupEditor" = "none"; # no welcome page
      "workbench.editor.editorActionsLocation" = "hidden"; # hide some buttons on the native title bar


      # Activity bar at the bottom
      "workbench.sideBar.location" = "bottom";

      # Trust all workspaces
      "security.workspace.trust.enabled" = false;

      # minimap
      "editor.minimap.maxColumn" = 100;
      "editor.minimap.showSlider" = "always";
      "editor.minimap.renderCharacters" = false;

      # Include git files in file tree and file search
      "files.exclude" = {
        "**/.git" = false;
      };

      # zen mode settings
      "zenMode.restore" = true;
      "zenMode.hideStatusBar" = true;
      "zenMode.showTabs" = "none";
      "zenMode.hideLineNumbers" = false;
      "zenMode.fullScreen" = false;
      "zenMode.centerLayout" = false;


      # --- PHP ---
      "php.debug.executablePath" = lib.getExe pkgs.php83;
      "namespaceResolver.autoSort" = false;


      # --- NIX ---
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


      # --- JAVA ---
      # All JDKs used for compiling
      "java.configuration.runtimes" = with pkgs; [
        {
          name = "JavaSE-11";
          path = openjdk11 + "/lib/openjdk";
        }
        {
          name = "JavaSE-17";
          path = openjdk17 + "/lib/openjdk";
        }
        {
          name = "JavaSE-21";
          path = openjdk21  + "/lib/openjdk";
        }
      ];
      "java.jdt.ls.java.home" = pkgs.openjdk + "/lib/openjdk"; # JDK used for the language server
      "java.configuration.detectJdksAtStart" = false; # Do not try to detect JDKs


      # --- GODOT ---
      "godotTools.editorPath.godot4" = lib.getExe pkgs.godot_4;


    };
    # Keybindings
    # `when` makes the keybind only available in certain contexts: more on that here
    # https://code.visualstudio.com/api/references/when-clause-contexts
    keybindings = [
      # --- MISC ---
      {
        # Open the search results as a text file in the editor
        key = "ctrl+enter";
        command = "search.action.openInEditor";
        when = "hasSearchResult && searchViewletFocus";
      }


      # --- GIT ---
      # Merge conflicts accept
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


      # --- COMMENTS ---
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
      # --- DOCBLOCK ---
      { # phpDoc
        key = "ctrl+enter";
        command = "phpdoc-generator.generatePHPDoc";
        when = "editorLangId == php";
      }
      { # JSDoc
        key = "ctrl+enter";
        command = "docthis.documentThis";
        when = "editorLangId =~ /vue|js|ts|jsx|tsx/";
      }


      # --- IMPORTS ---
      { # PHP Imports
        key = "ctrl+o i";
        command = "namespaceResolver.import";
        when = "editorLangId == php";
      }


      # --- DEBUGGING ---
      { # Start debugger
        key = "ctrl+o e";
        command = "workbench.action.debug.start";
        when = "debuggersAvailable && !inDebugMode";
      }
      { # Stop debugger
        key = "ctrl+o e";
        command = "workbench.action.debug.stop";
        when = "inDebugMode";
      }
      { # Contiune when stopped
        key = "ctrl+shift+o";
        command = "workbench.action.debug.continue";
        when = "inDebugMode";
      }
      { # Open watch panel
        key = "ctrl+o w";
        command = "workbench.debug.action.focusWatchView";
        when = "inDebugMode";
      }
      { # Add a watch expression
        key = "shift+enter";
        command = "workbench.debug.viewlet.action.addWatchExpression";
        when = "watchExpressionsFocused";
      }
      { # Remove a watched expression
        key = "shift+backspace";
        command = "debug.removeWatchExpression";
        when = "watchExpressionsFocused";
      }
      { # Edit a watched expression
        key = "enter";
        command = "debug.renameWatchExpression";
        when = "watchExpressionsFocused";
      }
      { # Toggle breakpoint
        key = "ctrl+shift+t";
        command = "editor.debug.action.toggleBreakpoint";
      }
    ];
    extensions = with vscodeExts.vscode-marketplace; with vscodeExts.open-vsx-release; [
      # --- UTILITIES ---
      davidlgoldberg.jumpy2 # jumping cursors with short letter combo
      eamodio.gitlens

      # --- PHP ---
      xdebug.php-debug # debugging php applications
      ronvanderheijden.phpdoc-generator # generate php doc comments
      mehedidracula.php-namespace-resolver # php everything namespace

      # --- NIX ---
      jnoortheen.nix-ide # nix language features

      # --- NODE ---
      vue.volar # vue language features
      oouo-diogo-perdigao.docthis # jsdoc

      # --- JAVA ---
      redhat.java # language features
      vscjava.vscode-java-debug # debugger
      vscjava.vscode-java-dependency # project manager

      # --- GODOT ENGINE ---
      geequlim.godot-tools

      # --- SQL ---
      adpyke.vscode-sql-formatter
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