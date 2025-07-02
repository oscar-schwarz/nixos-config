{
  biome-fest = {
    ip-address = "10.12.21.10";
    ssh.public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIcVpuDI9fFcNWeMEHelbaItqQJwmAkibSFR+nBhxng root@biome-fest";
    # NixOS modules this host consists of
    nixos-modules = [
      # kernel
      ({pkgs, ...}: {boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;})
      
      # theme
      "themes/prismarine/"

      # Essential things
      "essentials"
      "sound"

      # connection to the world
      "networking"

      "speicherfresser"

      # fingerprint sensor
      "fingerprint"

      # Allow selected unfree packages
      "allow-some-unfree"

      # printing documents with printers
      "printing"

      # gaming
      "steam/"

      # Settings specific to my monitor setup
      "monitors"

      "obs-studio"
    ];
    users.osi = {
      hm-modules = [
        # shell
        "fish"

        "git"
        
        # terminal
        "kitty"

        # Window manager
        "hyprland/" # base config
        "hyprland/laptop" # for laptops
        "hyprland/touch" # for laptops
        "hyprland/waybar" # utility bar
        "hyprland/lockscreen" # lockscreen with auto enable on inactivity
        "hyprland/runner"
        "hyprland/workspaces"

        # code editor
        "vscode"
        "nvf"

        # web browser
        "firefox"
        "chromium" # when firefox fails

        # password manager
        "password-store"

        # Game Engine
        # "godot" # currently broken

        # Some common desktop apps I need
        "desktop-apps"
        "cli-tools"

        "syncthing/"
      ];
      # NixOS modules here is given an additional attribute to the set called username, which is the user above
      user-nixos-modules = [
        # base user
        "normal-wheel-user"

        # set the password of the root user to the one of the user
        (username: {config, ...}: {users.users.root.hashedPasswordFile = config.getSopsFile "pass-hashes/${username}";})

        # Use greetd as display manager and autologin to hyprland
        "greetd-hyprland-autologin"

        # University specific configuration
        "uni"

        # certain ssh keys configured
        "github-ssh"
      ];
    };
  };
  blind-spots = {
    ip-address = "10.12.21.40";
    ssh = {
      public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlvatOzYr9PmTl6v2Q1JiHNaOzbCOOe0/nL2RJS+VqV root@blind-spots";
      allow-connections-from = [ "biome-fest" ];
    }; 
  };
  haunt-muskie = {
    ip-address = "188.245.92.110";
    ssh = {
      public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAp5UxVvqO6i0Jp4W68CqYnKh5yEB+6ZzS987dT/eNtL root@haunt-muskie";
      allow-connections-from = [ "biome-fest" ];
    };
    nixos-modules = [ 
      "essentials"
      "disko/basic"
    ];
  };
}
