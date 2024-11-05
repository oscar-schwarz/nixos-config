{ pkgs, ... }: 

{
  home.packages = with pkgs; [
    todo-txt-cli
  ];

  
}