{ pkgs,  ... }:

{
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "topydo";
      runtimeInputs = [ topydo ];
      text = ''
        topydo -t "$HOME"/files/local/todo/todo.txt -d "$HOME"/files/local/todo/done.txt "$@"
      '';
    })
  ];

  programs.fish = {
    interactiveShellInit = ''
      topydo ls -F "- %s" -g due | ${pkgs.glow}/bin/glow
    '';
    shellAliases.t = "topydo";
  };
}