{ config, nixosConfig, pkgs, inputs, lib,  ... }:

let
  username = "osi";
  homeDir = "/home/" + username; 

  heygptWrapper = pkgs.writeShellApplication {
    name = "heygpt";
    text = ''
      OPENAI_API_BASE="https://api.openai.com/v1" \
      OPENAI_API_KEY=$(cat ${nixosConfig.sops.secrets."api-keys/open-ai".path}) \
      ${lib.getExe pkgs.heygpt} "$@"
    '';
  };

  # A small script that easily clones and pulls changes of the password store
  pass-fetch = pkgs.writeShellApplication {
    name = "pass-fetch";
    text = ''
      REPO_URL="git@github.com:OsiPog/pass.git"
      DEST_DIR="${homeDir}/.password-store"

      if [ ! -d "$DEST_DIR" ]; then
        git clone "$REPO_URL" "$DEST_DIR"
      else
        ${lib.getExe pkgs.pass} git pull
        ${lib.getExe pkgs.pass} git push
      fi
    '';
  };

  vscodeExts = inputs.nix-vscode-extensions.extensions.x86_64-linux;
in {

  # Import modules
  imports = [
    # KDE setup
    ./modules/home/plasma.nix

    # Dropdown terminal settings
    ./modules/home/yakuake.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDir;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages  = with pkgs; [
    signal-desktop # secure messaging
    yakuake # dropdown terminal
    heygptWrapper # terminal gpt integration
    xournalpp # stylus note taking app
    obsidian # markdown note taking app
    spectacle # screenshot utility

    wl-clipboard-rs # copy to clipboard from terminal
    
    pass-fetch # script for fetching password store repo
  ];

  # Password store
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
    ]);
    settings = {
      PASSWORD_STORE_DIR="$HOME/.password-store";
    };
  };


  # Some encryption stuff
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # btop - task manager
  programs.btop = {
    enable = true;
    settings = {
      # Using the theme provided by the terminal
      force_tty = "False";
    };
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
  };
  
  # better cd
  programs.zoxide.enable = true;

  # enable nix-direnv
  programs.direnv = {
    enable = true;
    silent = true;
  };

  # git stuff
  programs.git = {
    enable =true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      user = {
        email = "osibluber@protonmail.com";
        name = "Osi Bluber";
      };
    };
  };

  # code editor
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = {
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
                expr = "(builtins.getFlake \"${homeDir}/nixos/config\").nixosConfigurations.default.options";
            };
            home-manager = {
                expr = "(builtins.getFlake \"${homeDir}/nixos/config\").homeConfigurations.default.options";
            };
          };
        };
      };
    };
    extensions = with vscodeExts.vscode-marketplace; with vscodeExts.open-vsx-release; [
      jnoortheen.nix-ide
    ];
  };

  # terminal that makes me wet
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    plugins = [
      # A nice theme
      {
        name = "eclm";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-eclm";
          rev = "185c84a41947142d75c68da9bc6c59bcd32757e7";
          sha256 = "sha256-OBku4wwMROu3HQXkaM26qhL0SIEtz8ShypuLcpbxp78=";
        };
      }
    ];
    functions = {
      termgpt = ''
        ${lib.getExe heygptWrapper} --model "gpt-4o" """$argv""" | ${lib.getExe pkgs.glow}
      '';
      rebuild = ''
        # Delete all backup files
        find ~ -type f -name "*.homeManagerBackupFileExtension" -delete 2>/dev/null

        # No VSCodium, these plugins are NOT obsolete!
        if [ -e ~/.vscode-oss/extensions/.obsolete ]; then
          rm -f ~/.vscode-oss/extensions/.obsolete
          rm -f ~/.vscode-oss/extensions/extensions.json
        end

        # add all new files to git, so that they are seen by nixos
        set PREV_PWD "$PWD"
        cd ~/nixos/config
        git add *

        sudo nixos-rebuild --flake ~/nixos/config#default $argv

        # only commit if succeeded
        if test $status -eq 0
          # commit all changes
          gptcommit
        end

        # Go back to previous cwd
        cd "$PREV_PWD"
      '';
      gptcommit = ''
        set message $(\
          heygpt --model "gpt-4o" \
            --system="You are a git commit generator. When given a certain diff you will reply with \
            ONLY ONE commit message following the conventional commits specification. Make sure to use scopes. \
            The allowed commit types are feat, fix, chore and refactor. \
            No Markdown, no codeblocks just a commit message. I REPEAT: No codeblocks and allowed commit types \
            are feat, fix, chore and refactor!" \
            --temperature 0.1 \
            """$(git diff --staged)"""
        )

        git commit -m """$message"""
      '';

      silent-plasma-restart = ''
        # restart plasmashell without any console output
        echo "Restarting KDE..."
        plasmashell --replace >/dev/null 2>1 &

        # detach from terminal
        disown
      '';
    };
  };

  # -- DANGER ZONE -- 
  # maybe I should not change those values

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
