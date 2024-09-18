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

    # Dropdown terminal settings
    ./modules/home/yakuake.nix

    # All hyprland options (a lot of them)
    ./modules/home/hyprland.nix

    # VSCodium setup
    ./modules/home/vscode.nix

    # Shell
    ./modules/home/fish.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
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
    package = pkgs.firefox-wayland;

    # Some installation-wide settings and extensions
    # https://mozilla.github.io/policy-templates/
    policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Cookies = "reject-foreign";

        DisablePocket = true;
        ShowHomeButton = false;
        DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"
        TranslateEnabled = false;

        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        
        DontCheckDefaultBrowser = true;
        
        SanitizeOnShutdown = {
          Cache = true;
          FormData = true;
          History = true;
        };

        ExtensionSettings = {
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Time-to-Work
          "{c52a7349-0c5d-479d-9917-0155a0c58c0a}" = {
            install_url = "https://github.com/OsiPog/time-to-work/releases/download/v1.2.5/time-to-work-1.2.5.xpi";
            installation_mode = "force_installed";
          };
          # Chameleon, user-agent headers and more spoofer
          "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4349329/chameleon_ext-0.22.65.1.xpi";
            installation_mode = "force_installed";
          };
          # Vimium, keyboard driven website navigation
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4259790/vimium_ff-2.1.2.xpi";
            installation_mode = "force_installed";
          };
        };
    };
    profiles = let 
      merge = lib.recursiveUpdate;

      # All options that should be shared by all profiles
      sharedOptions = {
        settings = {
          media.gmp-widevinecdm.enabled = true;
        };
      };

    in {

      # The default profile
      default = merge sharedOptions {
        id = 0;
        isDefault = true;
      };

      # A profile meant for work stuff
      work = merge sharedOptions {
        id = 1;
        settings = {
          # Set a by-default installed distinguishable theme from the default
          "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
        };
      };
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
