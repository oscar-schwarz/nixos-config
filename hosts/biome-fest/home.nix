{ nixosConfig, pkgs, lib, ... }:

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
in {

  # Import modules
  imports = [
    # KDE setup (disabled for now as I switched to hyprland)
    # ./modules/home/plasma.nix
    # ./modules/home/yakuake.nix

    # All hyprland options (a lot of them)
    ./modules/home/hyprland.nix

    # VSCodium setup
    ./modules/home/vscode.nix

    # Shell
    ./modules/home/fish.nix
  
    # Firefox settings
    ./modules/home/firefox.nix
  ];

  # Home Manager needs a bit of tinformation about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDir;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages  = with pkgs; [
    signal-desktop # secure messaging
    xournalpp # stylus note taking app
    obsidian # markdown note taking app
    libreoffice
    ncpamixer # Pulse Audio mixer utilityh
    
    # Tools
    wl-clipboard-rs # copy to clipboard from terminal
    
    # Scripts
    pass-fetch # script for fetching password store repo
    heygptWrapper # terminal gpt integration
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
  };

  # btop - task manager
  programs.btop = {
    enable = true;
    settings = {
      # Using the theme provided by the terminal
      force_tty = "False";
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {
        # Vimium
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
      }
      {
        # Vue Devtools
        id = "nhdogjmejiglipccpnnnanhbledajbpd";
      }
    ]
    ;
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

  # nice cli git experience
  programs.lazygit = {
    enable = true;
    settings = {
      mouseEvents = false; # don't need no mouse
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
