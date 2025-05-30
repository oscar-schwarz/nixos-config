{ pkgs, lib, config, ... }: 
let
  heygptWrapper = pkgs.writeShellApplication {
    name = "heygpt";
    text = ''
      OPENAI_API_BASE="https://api.openai.com/v1" \
      OPENAI_API_KEY=$(cat ${config.getSopsFile "api-keys/open-ai"}) \
      ${lib.getExe pkgs.heygpt} --model "''${HEYGPT_MODEL:-gpt-4o}" "$@"
    '';
  };
in {
  home.packages = with pkgs; [
    bluetuith # bluetooth tui
    devenv # dev environments made easy
    ncpamixer # Pulse Audio mixer utility
    restic
    nushell # a new and fancy type of shell
    # Tools
    wl-clipboard-rs # copy to clipboard from terminal

    # Scripts
    heygptWrapper # terminal gpt integration
  ];

  # Secrets needed in this file
  sops.secrets = {
    "api-keys/open-ai" = {};
  };

  # Mounting usb devices easily
  programs.bashmount.enable = true;

  # Youtube downloader
  programs.yt-dlp = {
    enable = true;
  };

  # nice cli git experience
  programs.lazygit = {
    enable = true;
    settings = {
      mouseEvents = false; # don't need no mouse
    };
  };
}
