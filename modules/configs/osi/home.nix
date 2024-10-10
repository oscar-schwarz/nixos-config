{ nixosConfig, pkgs, lib, ... }:

let
  username = "osi";
  homeDir = "/home/" + username; 

  heygptWrapper = pkgs.writeShellApplication {
    name = "heygpt";
    text = ''
      OPENAI_API_BASE="https://api.openai.com/v1" \
      OPENAI_API_KEY=$(cat ${nixosConfig.sops.secrets.${nixosConfig.osi.secrets.openAiKey}.path}) \
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
    ./home/hyprland.nix

    # VSCodium setup
    ./home/vscode.nix

    # Shell
    ./home/fish.nix
  
    # Firefox settings
    ./home/firefox.nix
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
    libreoffice # office suite
    ncpamixer # Pulse Audio mixer utility
    restic
    nautilus # File Browser
    loupe # Image Viewer
    vlc # Media Player
    prismlauncher # Open Source Minecraft Launcher

    # Tools
    wl-clipboard-rs # copy to clipboard from terminal
    
    # Scripts
    pass-fetch # script for fetching password store repo
    heygptWrapper # terminal gpt integration
  ];

  # Default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "video/mp4" = [ "vlc.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
    };
  };

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
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        source = nixosConfig.sops.secrets.${nixosConfig.osi.secrets.publicPgpKey}.path;
      }
    ];
  };

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

  # nice cli git experience
  programs.lazygit = {
    enable = true;
    settings = {
      mouseEvents = false; # don't need no mouse
    };
  };

  # -- DANGER ZONE -- 
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
