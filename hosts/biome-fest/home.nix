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
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        trust = 5;
        text = ''-----BEGIN PGP PUBLIC KEY BLOCK-----

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
VwasqP4uNduPqrMf89I0tu6zGqXCNggOnopuUt8=
=ufms
-----END PGP PUBLIC KEY BLOCK-----
        '';
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
