{ pkgs, lib, ... }:

{
  # terminal that makes me wet
  programs.fish = {
    enable = true;
    plugins = [
      # A nice theme
      {
        name = "eclm";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-eclm";
          rev = "185c84a41947142d75c68da9bc6c59bcd32757e7";
          sha256 = "sha256-OBku4wwMROu3HQXkaM26qhL0SIEtz8ShypuLcpbxp78=";
        };
      }
    ];
    shellAliases = {
      lg = "lazygit";
      logout = "hyprctl dispatch exit 1";
      c = "codium";
    };
    functions = {
      # Nix stuff
      ns = "nix-shell -p $argv";
      nsc = "nix-shell -p $argv --command $argv";
      ask = ''
        heygpt --model "gpt-4o-mini" """$argv""" | ${lib.getExe pkgs.glow}
      '';
      rebuild = ''
        # Delete all backup files (not necessary anymore)
        # find ~ -type f -name "*.homeManagerBackupFileExtension" -delete 2>/dev/null
        
        # No VSCodium, these plugins are NOT obsolete!
        if test -f ~/.vscode-oss/extensions/.obsolete
          rm -f ~/.vscode-oss/extensions/.obsolete
        end
        
        # add all new files to git, so that they are seen by nixos
        set PREV_PWD "$PWD"
        cd ~/nixos
        direnv reload
        git add --all

        sudo nixos-rebuild --flake ~/nixos#biome-fest $argv

        # only commit if succeeded
        if test $status -eq 0
          # commit all changes
          gptcommit
          git push
        end

        # Go back to previous cwd
        cd "$PREV_PWD"
      '';
      gptcommit = ''
        set message $(\
          heygpt --model "gpt-4o-mini" \
            --system="You are a git commit generator. When given a certain diff you will reply with \
            ONLY ONE commit message following the conventional commits specification. Make sure to use scopes. \
            The allowed commit types are feat, fix, chore and refactor. \
            No Markdown, no codeblocks just a commit message. I REPEAT: No codeblocks and allowed commit types \
            are feat, fix, chore and refactor!" \
            --temperature 0.1 \
            """$(git diff --staged)"""
        )

        git commit -m """$message"""
      '';

      silent-plasma-restart = ''
        # restart plasmashell without any console output
        echo "Restarting KDE..."
        plasmashell --replace >/dev/null 2>1 &

        # detach from terminal
        disown
      '';
      ssh = "TERM=xterm-256color ${lib.getExe pkgs.openssh} $argv";
    };
  };

}