# Laravel, a PHP framework

# Optional arguments in a wrapper around the module
{
  phpPackageName ? "php",
  xdebugPort ? 9003,
}:

# Actual module starts here
{ pkgs, ... }:

{
  packages = with pkgs; [
    (pkgs.${phpPackageName}.buildEnv {
      extensions = ({ enabled, all }: enabled ++ (with all; [
        xdebug
        dom
        curl
        bcmath
        pdo
        tokenizer
        mbstring
        mysqli
      ]));
      extraConfig = ''
        [XDebug]
        xdebug.mode=debug
        xdebug.start_with_request=yes
        xdebug.client_port=${toString xdebugPort}
      '';
    })
  ];

  processes = {
    laravel-server.exec = "php artisan serve";
  };
}