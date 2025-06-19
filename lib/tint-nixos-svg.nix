{
  blue,
  cyan,
  ...
}: {
  nixos-icons,
  runCommand,
  ...
}: runCommand "tinted-nixos-svg" {} ''
  img=${nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg
  blue="${blue}"
  cyan="${cyan}"
  sed "
    s/699ad7/$cyan/g;
    s/7eb1dd/$cyan/g;
    s/7ebae4/$cyan/g;
    s/415e9a/$blue/g;
    s/4a6baf/$blue/g;
    s/5277c3/$blue/g;
  " $img > $out
''