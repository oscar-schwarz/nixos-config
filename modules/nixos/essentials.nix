{
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (lib.attrsets) mapAttrs;
in {
  # Bootloader setup
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 42;
  };

  # needed packages
  environment.systemPackages = with pkgs; [
    fastfetch # System info
    tree # File tree
    bat # Better cat
    atool # Extract any archive
    jq # tool to parse json
    usbutils # for lsusb and such
    fzf
    ripgrep
  ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # configure fish* and set default shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # disable the greeting
      set fish_greeting
    '';
  };
  users.defaultUserShell = pkgs.fish;

  # Configure direnv
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };

  environment.variables = {
    # Fix for electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Setup home-manager
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    useGlobalPkgs = true;

    # Home manager settings for every user
    sharedModules = [
      ({...}: {
        # Let home manager manage itself
        programs.home-manager.enable = true;

        # better cd
        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };

        # Git
        programs.git = {
          enable = true;
          extraConfig = {
            user = {
              name = "Oscar Schwarz";
              email = "121044740+oscar-schwarz@users.noreply.github.com";
            };
            init.defaultBranch = "main";
            pull.rebase = true;
          };
        };

        programs.btop = {
          enable = true;
          settings = {
            # Using the theme provided by the terminal
            force_tty = "False";
          };
        };
      })
    ];
  };

  # Mounts to /run/media/username
  services.udisks2.enable = true;

  # language specific
  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    # Home sweet home german formats
    extraLocaleSettings = mapAttrs (_: value: mkDefault value) {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  # Make all keyboards the same

  # xserver keymap
  services.xserver = {
    # Configure keymap in X11.
    xkb.layout = "us,de";
    xkb.variant = "colemak,";
    xkb.options = "grp:win_space_toggle";
  };

  # Configure console keymap
  console.keyMap = "colemak";

  # Disable generation of man caches
  documentation.man.generateCaches = false;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
