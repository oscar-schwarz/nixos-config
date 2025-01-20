{ pkgs, lib, inputs, ... }:

{
  # Bootloader setup
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 42;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint epsonscan2 ];
  };

  # needed packages
  environment.systemPackages = with pkgs; [
    fastfetch # System info
    tree # File tree
    bat # Better cat
    atool # Extract any archive
    jq # tool to parse json
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
    sharedModules = [({...}: {
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

      programs.bashmount.enable = true;

      # little fix for gtk apps
      gtk.iconTheme.name = lib.mkDefault "Adwaita";
    })];
  };

  # Mounts to /run/media/username
  services.udisks2.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Make all keyboards the same

  # xserver keymap
  services.xserver = {
    # Configure keymap in X11.
		xkb.layout = "us,us";
		xkb.variant = "colemak,";
    xkb.options = "grp:win_space_toggle";
  };

  # Configure console keymap
  console.keyMap = "colemak";

  # Disable generation of man caches
  documentation.man.generateCaches = false;
}