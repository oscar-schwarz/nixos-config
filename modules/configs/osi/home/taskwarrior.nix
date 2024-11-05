{ pkgs, ... }: 

{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    dataLocation = "$HOME/files/local/task-warrior";
  };
}