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
  # A fix for obsidian to properly open attachments:
  # basically making electron think its on gnome so that is uses "gio" (from glib) to open programs
  # https://forum.obsidian.md/t/obsidian-freezes-entirely-when-an-attachment-is-open-with-an-external-program/78861
  obsidianOverride = pkgs.obsidian.overrideAttrs (prev: {
    installPhase =
      prev.installPhase
      + ''
        wrapProgram $out/bin/obsidian \
          --prefix PATH : ${pkgs.glib}/bin \
          --set XDG_CURRENT_DESKTOP "GNOME"
      '';
  });
in {
  # Import modules
  imports = [
    # KDE setup (disabled for now as I switched to hyprland)
    # ./modules/home/plasma.nix
    # ./modules/home/yakuake.nix

    # Everything todo
    # ./home/todo.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bluetuith # bluetooth tui
    devenv # dev environments made easy
    gnome-disk-utility # format disks
    libreoffice # office suite
    loupe # Image Viewer
    nautilus # File Browser
    ncpamixer # Pulse Audio mixer utility
    obsidianOverride # markdown note taking app
    prismlauncher # Open Source Minecraft Launcher
    restic
    signal-desktop # secure messaging
    vlc # Media Player
    xournalpp # stylus note taking app
    gimp # image editor
    obs-studio # screen capture goat
    krita # best drawing

    # Add AI Tools here when available

    # Tools
    wl-clipboard-rs # copy to clipboard from terminal

    # Scripts
    heygptWrapper # terminal gpt integration
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
