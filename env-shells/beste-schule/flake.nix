{
  description = "A dev environment for a project with Laravel and Vue";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # VSCode extension from marketplace and vscode oss
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for "eachDefaultSystem"
    flake-utils.follows = "nix-vscode-extensions/flake-utils";
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Aliases that simulate a module
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Functions
        writeJson = set: pkgs.writeTextFile {
          name = "filename"; # this does not need to be unique
          text = builtins.toJSON set;
        };
        writeList = list: pkgs.writeTextFile {
          name = "filename";
          text = lib.concatStringsSep "\n" list;
        };
        writeYaml = set: pkgs.writeTextFile {
          name = "filename";
          text = lib.generators.toYAML {} set;
        };
        writeDotEnv = set: pkgs.writeTextFile {
          name = "filename";
          text = builtins.concatStringsSep "\n" (
            map (attr: 
              let
                # Add quotation marks to value if it contains spaces
                containsChar = char: str: builtins.any (c: c == char) (lib.strings.stringToCharacters str);
                raw = builtins.getAttr attr set;
                value = if containsChar " " raw then ("\"" + raw + "\"") else raw;
              in
                "${attr}=${value}"
            ) (builtins.attrNames set)
          ) + "\n";
        };


        # PHP
        phpPackageName = "php82";
        php = pkgs.${phpPackageName}.buildEnv {
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
            xdebug.client_port=${phpConfig.xdebugTcpPort}
          '';
        };
        phpConfig = {
          xdebugTcpPort = "19003";
        };


        # MariaDB
        mariadb = pkgs.mariadb;
        mariadbConfig = {
          tcpPort = "13306";
          pidFile = ''"$XDG_RUNTIME_DIR"/besteschule-mariadb.pid'';
          socketFile = ''"$XDG_RUNTIME_DIR"/besteschule-mariadb.sock'';
          dataDirRelative = ".mariadb-data";
          dataDir = ''"$PWD/${mariadbConfig.dataDirRelative}"'';
          
          user = {
            name = "user";
            password = "user";
          };
          database = "database";
        };


        # NodeJS
        nodejs = pkgs.nodejs;
        nodejsConfig = {
          tcpPort = "15173";
        };


        # Git config
        # This config structure is just for readability
        # The actual assignments happen below
        gitConfig = {
          exclude = [
            ".envrc"
            ".direnv"
            ".pre-commit-config.yaml"
            mariadbConfig.dataDirRelative
          ];
          pre-commit-config = {
            repos = [
              {
                repo = "https://github.com/pre-commit/pre-commit-hooks";
                rev = "v3.2.0";
                hooks = [
                  # {
                  #   id = "trailing-whitespace";
                  # }
                  {
                    id = "end-of-file-fixer";
                  }
                  {
                    id = "check-yaml";
                  }
                  {
                    id = "check-added-large-files";
                  }
                  {
                    id = "no-commit-to-branch";
                    args = [
                      "--branch" "master"
                      "--branch" "main"
                      "--branch" "production"
                    ];
                  }
                ];
              }
              {
                repo = "local";
                hooks = [
                  {
                    id = "check-types-ts";
                    name = "Check export type declaration order";
                    entry = "./scripts/check-types-ts";
                    language = "script";
                    files = "^resources/js/types\\.ts$";
                  }
                ];
              }
            ];
          };
        };


        dotEnv = {
          SERVER_HOST="localhost";
          SERVER_PORT="18000";

          APP_NAME = "beste lokale Schule";
          APP_DEBUG = "true";
          APP_ENV = "local";
          APP_URL = "http://${dotEnv.SERVER_HOST}:${dotEnv.SERVER_PORT}";
          APP_KEY = "base64:Igl3VDbdMSWnCDABL7k9ioK8hJ1EKgM25kh6vnxUntQ="; # This has to be set

          VITE_APP_ENV = "debug";

          TOKEN_VALID = "14";
          TOKEN_LENGTH = "16";

          SESSION_LIFETIME = "30";
          MIX_SESSION_LIFETIME = "30";

          API_VERSION = "0.3";

          RATE_LIMIT = "60";

          LOG_CHANNEL = "stack";
          LOG_STACK_CHANNELS = "daily";
          LOG_LEVEL = "debug"; #emergency, alert, critical, error, warning, notice, info, or debug

          DB_CONNECTION = "mysql";
          DB_HOST = "127.0.0.1";
          DB_PORT = mariadbConfig.tcpPort;
          DB_DATABASE = mariadbConfig.database;
          DB_USERNAME = mariadbConfig.user.name;
          DB_PASSWORD = mariadbConfig.user.password;

          PLAN_SCHULE_URL = "http://plan.schule";

          # Whether report generation is dispatched async (default true).
          # Use false for debugging to catch break points in ReportProcessor
          REPORT_DISPATCH_ASYNC = "true";

          # For debugging: Allows to execute large reports without writing the result to cache
          # This allows to read the reports' SQL queries in the API response
          REPORT_BYPASS_CACHE = "false";

          # Report queue
          QUEUE_CONNECTION = "database";
        };


        # Useful scripts
        shellScripts = [
          # Alias for mariadb with correct socket
          (pkgs.writeShellApplication {
            name = "mariadb";
            runtimeInputs = [ mariadb ];
            text = ''
              mariadb --socket=${mariadbConfig.socketFile} "$@"
            '';
          })

          # Easy access to the database with the cli client with auto login to configured user and
          # database (a wrapper for the wrapper above, wrapper-ception)
          (pkgs.writeShellApplication {
            name = "sql";
            text = ''
              mariadb \
                --user=${mariadbConfig.user.name} \
                --password=${mariadbConfig.user.password} \
                --database=${mariadbConfig.database} \
                "$@"
            '';
          })

          # Alias for mariadbd-safe with correct socket and datadir
          (pkgs.writeShellApplication {
            name = "mariadbd-safe";
            runtimeInputs = [ mariadb ];
            text = ''
              mariadbd-safe \
                --socket=${mariadbConfig.socketFile} \
                --datadir=${mariadbConfig.dataDir} \
                --pid-file=${mariadbConfig.pidFile} \
                --port=${mariadbConfig.tcpPort} \
                "$@"
            '';
          })          

          # Run install on the package managers and setup the database 
          (pkgs.writeShellApplication {
            name = "env-install";
            text = let
              setupSql = pkgs.writeTextFile {
                name = "setup.sql";
                text = ''
                  CREATE DATABASE IF NOT EXISTS ${mariadbConfig.database};
                  
                  CREATE USER IF NOT EXISTS '${mariadbConfig.user.name}'@'localhost' IDENTIFIED BY '${mariadbConfig.user.password}';
                  GRANT ALL PRIVILEGES ON *.* TO '${mariadbConfig.user.name}'@'localhost' WITH GRANT OPTION;
                  FLUSH PRIVILEGES;
                '';
              };
            in ''
              # continue on error (e.g. something exists already)
              set +e

              composer install

              # Some node modules need this python version
              PATH="${pkgs.python311Full}/bin:$PATH"
              npm install --loglevel verbose

              # Setup mariadb
              echo Setup mariadb...
              mkdir -p ${mariadbConfig.dataDir} 

              ${mariadb}/bin/mariadb-install-db --datadir=${mariadbConfig.dataDir}

              # setup db (start server temporarily if not started)
              KILL_AFTERWARDS=false
              if [ ! -f ${mariadbConfig.pidFile} ]; then
                KILL_AFTERWARDS=true
                mariadbd-safe &
              else # restart server
                kill "$(cat ${mariadbConfig.pidFile})"
                sleep 1 
                mariadbd-safe &
              fi
              sleep 2 # wait a moment for it to boot


              
              # Create user and database
              mariadb < ${setupSql}

              # Kill server again if necessary
              if $KILL_AFTERWARDS; then
                kill "$(cat ${mariadbConfig.pidFile})"
              fi
            '';
          })

          # Starting all processes and killing them again after CTRL+C
          (pkgs.writeShellApplication {
            name = "env-up";
            text = ''
              # Database server
              mariadbd-safe &

              # Laravel Server
              php artisan serve &

              # on nodejs 20 ctrl+c will exit failure which normally stops this bash script entirely
              # instead of continuing to the shutting down step, this prevents that
              set +e

              # Main process is vite, which can be stopped using CTRL+C
              npm run dev -- --port ${nodejsConfig.tcpPort} --mode development --debug

              # After vite was stopped kill the processes
              echo "Stopping services..."
              kill "$(cat ${mariadbConfig.pidFile})"
            '';
          })

          # Create a symlink with additional checks
          (pkgs.writeShellApplication {
            name = "try-symlink";
            text = ''
              FILE="$1"
              STORE="$2"

              # If file doesn't exist create it
              if [ ! -f  "$FILE" ]; then
                touch "$FILE"
              fi

              # Only overwrite symlink when FILE is already a symlink
              SYMLINK=$(readlink "$FILE")
              if [ "$SYMLINK" == "" ]; then
                echo "cannot create symlink at $FILE. Move it to another location to use this flake."
                exit
              fi

              # Only update on change
              if [ "$SYMLINK" != "$STORE" ]; then
                echo "Updating $FILE"
                ln -fs "$STORE" "$FILE"
              fi
            '';
          })
        ];

        devShells.default = pkgs.mkShell {
          # The packages exposed to the shell
          buildInputs =
            shellScripts ++
          [
            php
            nodejs

            pkgs.pre-commit
          ];

          # Generate necessary files and create symlinks to them
          shellHook = ''
            # Git exclude
            try-symlink .git/info/exclude "${writeList gitConfig.exclude}"

            # Pre commit config
            try-symlink .pre-commit-config.yaml "${writeYaml gitConfig.pre-commit-config}"
            pre-commit install

            # Write .env, not a symlink because php cant read it
            newEnvPath="${writeDotEnv dotEnv}"
            if [ ! -e ".env" ]; then
              touch .env # to make diff never fail
            fi
            if [ "$(diff $newEnvPath .env)" != "" ]; then
              echo "Updating .env"
              echo -e "$(cat $newEnvPath)" > .env
            fi

            echo "Entering Beste Schule Dev Environment"
          '';
        };
      in
      {
        inherit devShells;
      }
    );
}