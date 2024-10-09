{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      # Global settings
      xdebugPort = 19003;

      mysql = {
        defaultDatabase = "database";
        username = "user";
        userPassword = "user";
        port = 13306;
      };
    in
    {
      packages.${system}.devenv-up = self.devShells.${system}.default.config.procfileScript;

      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, ... }: {
      
            # Language settings
            languages = {
              # PHP
              php = {
                enable = true;
                package = pkgs.php82.buildEnv {
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
                };
              };

              # JS, nodejs with npm
              javascript = {
                enable = true;
                npm = {
                  enable = true;
                  install.enable = true; # run npm install on init
                };
              };
            };


            # Services
            services = {
              # Database
              mysql = {
                enable = true;
                package = pkgs.mariadb;
                # Change existing port to not interfer with running services
                settings.mysqld.port = mysql.port;
                # Create two databases
                initialDatabases = map (name: {inherit name;}) [
                  mysql.defaultDatabase
                  "test"
                ];
                # Create a user and give it permission to the db
                ensureUsers = [
                  {
                    name = mysql.username;
                    password = mysql.userPassword;
                    ensurePermissions = {
                      "${mysql.defaultDatabase}.*" = "ALL PRIVILEGES";
                    };
                  }
                ];
              };
            };


            # Additional packages
            packages = with pkgs; [
              # Nice welcomer
              onefetch
            ];

            # Processes run with `devenv up`
            processes = {
              # the php laravel server
              laravel-server.exec = "php artisan serve";
              # node
              vite.exec = "npm run dev";
            };

            # Run on entering the shell with `nix develop` or automatically with direnv
            enterShell = ''
              onefetch
            '';
          })
        ];
      };
    };
}