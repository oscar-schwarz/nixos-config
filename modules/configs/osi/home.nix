{
  config,
  nixosConfig,
  pkgs,
  lib,
  ...
}: let
  heygptWrapper = pkgs.writeShellApplication {
    name = "heygpt";
    text = ''
      OPENAI_API_BASE="https://api.openai.com/v1" \
      OPENAI_API_KEY=$(cat ${nixosConfig.getSopsFile "api-keys/open-ai"}) \
      ${lib.getExe pkgs.heygpt} --model "''${HEYGPT_MODEL:-gpt-4o}" "$@"
    '';
  };

  # A small script that easily clones and pulls changes of the password store
  pass-fetch = pkgs.writeShellApplication {
    name = "pass-fetch";
    text = ''
      REPO_URL="git@github.com:OsiPog/pass.git"
      DEST_DIR="${config.home.homeDirectory}/.password-store"

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

    # Everything todo
    # ./home/todo.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "osi";
  home.homeDirectory = "/home/osi";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bluetuith # bluetooth tui
    devenv # dev environments made easy
    gnome-disk-utility # format disks
    godot_4
    gource # Git history visualisation
    libreoffice # office suite
    loupe # Image Viewer
    nautilus # File Browser
    nnn # terminal file manager
    ncpamixer # Pulse Audio mixer utility
    obsidian # markdown note taking app
    prismlauncher # Open Source Minecraft Launcher
    qrcode # simple qr code tool
    restic
    signal-desktop # secure messaging
    vlc # Media Player
    xournalpp # stylus note taking app
    gimp # image editor

    # Tools
    wl-clipboard-rs # copy to clipboard from terminal

    # Scripts
    pass-fetch # script for fetching password store repo
    heygptWrapper # terminal gpt integration

    # Icons
    adwaita-icon-theme
  ];

  home.sessionVariables = {
    "EDITOR" = "hx";
  };

  # Default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "video/mp4" = ["vlc.desktop"];
      "image/jpeg" = ["org.gnome.Loupe.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
    };
  };

  # Password store
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-otp
    ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };

  # Some encryption stuff
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        source = nixosConfig.getSopsFile "pgp-keys/id-0x675D2CB5013E8731/public";
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
    # relatively simple (vivaldi is overkill for my usecase of "this page doesnt work in firefox") with an ad-blocker
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
    ];
  };

  # nice cli git experience
  programs.lazygit = {
    enable = true;
    settings = {
      mouseEvents = false; # don't need no mouse
    };
  };

  # Youtube downloader
  programs.yt-dlp = {
    enable = true;
  };

  programs.helix = {
    enable = true;
  };

  # -- DANGER ZONE --
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";
}
