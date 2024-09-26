{
  description = "A dev environment for a Laravel Sail project";

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
    # For api script
    malte = {
      flake = false;
      url = "git+https://git.tammena.me/megamanmalte/nixos?rev=bd3f6996d6ecaa6f4d9718cd9385e456e5edc3de";
    };
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
          text = builtins.concatStringsSep "\n" list;
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

        # Useful scripts
        shellScripts = [
          # Alias for ./vendor/bin/sail
          (pkgs.writeShellApplication {
            name = "sail";
            text = ''sudo ./vendor/bin/sail "$@"'';
          })

          # Alias to quickly execute a command inside the container
          (pkgs.writeShellApplication {
            name = "run-in-sail";
            text = ''sudo ./vendor/bin/sail exec --user root laravel.test """$@"""'';
          })

          # Starts the docker daemon, the sail daemon and vite. After CTRL+C on vite the daemons are killed again
          # pass "debug" as an argument to get a verbose output
          (pkgs.writeShellApplication {
            name = "env-up";
            text = ''
              ARG1=''${1:-normal}
              if [ "$ARG1" == "debug" ]; then
                DEBUG=true
              else
                DEBUG=false
              fi

              # Install sail
              composer install

              # ---- Start containers ----

              # Run docker daemon
              if $DEBUG; then
                sudo dockerd &
              else
                sudo dockerd >/dev/null 2>&1 &
              fi
              DOCKER_PID="$!"
              
              # Wait for docker to boot
              sleep 3

              # Run sail container
              sail up -d

              # Run install node modules
              run-in-sail npm install
              # revert the package-lock changes
              git restore package-lock.json


              # ---- Hacks and workarounds ----

              # insert xdebug config and restart container (yeah I know, nasty)
              run-in-sail cat /etc/php/8.3/cli/php.ini > php.ini
              if [ "$(grep xdebug < php.ini)" == "" ]; then
                echo "Injecting php xdebug config"
                echo -e "[xdebug]\\nxdebug.start_with_request = yes" >> php.ini 
                run-in-sail cp php.ini /etc/php/8.3/cli/php.ini
                echo "Restart container for injection to take effect"
                sail restart laravel.test
              fi
              rm php.ini

              # Little hack to fix permissions in laravel storage
              if [ "$(stat -c "%a" ./storage)" != "777" ]; then
                echo "The ./storage directory does not have the 777 permission, without it the sail user in the container cannot write to it. Sudo is required to add it."
                sudo chmod -R 777 ./storage
              fi

              # on nodejs 20 ctrl+c will exit failure which normally stops this bash script entirely
              # instead of continuing to the shutting down step, this prevents that
              set +e


              # ---- Vite ---- 

              # run vite (This is listening to CTRL+C)
              if $DEBUG; then
                run-in-sail npm run dev -- --debug
              else
                run-in-sail npm run dev
              fi


              # ---- Kill services again (after CTRL+C) ----

              echo "SIGINT received, shutting down."
              sail down
              sudo kill "$DOCKER_PID"
            '';
          })

          # A small snippet to check if the types in the 'types.ts' file are in the correct order
          (pkgs.writeShellApplication {
            name = "check-types-ts";
            text = ''grep -o '^export type \w\+' "''${@}" | sort --check'';
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


        dotEnv = {
          APP_ENV = "local";
          APP_DEBUG= "true";
          APP_NAME = "Laravel-Sail-App";
          APP_URL = "http://localhost:8000";
          APP_PORT = "8000";
          VITE_PORT = "5173";
          APP_KEY = "base64:Igl3VDbdMSWnCDABL7k9ioK8hJ1EKgM25kh6vnxUntQ="; # This has to be set

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
          DB_HOST = "mariadb";
          DB_PORT = "3306"; # TODO: Use a slightly different port to allow other database services on the system
          DB_DATABASE = "database";
          DB_USERNAME = "user";
          DB_PASSWORD = "user";

          PLAN_SCHULE_URL = "http://plan.schule";

          # Whether report generation is dispatched async (default true).
          # Use false for debugging to catch break points in ReportProcessor
          REPORT_DISPATCH_ASYNC = "false";

          # For debugging: Allows to execute large reports without writing the result to cache
          # This allows to read the reports' SQL queries in the API response
          REPORT_BYPASS_CACHE = "false";

          # Report queue
          QUEUE_CONNECTION = "database";

          # XDebug config
          SAIL_XDEBUG_MODE = "develop,debug,coverage";

          # Pusher variables (I don't use pusher, thats to disable the warning about 
          # them not being defined)
          PUSHER_APP_ID= "app-id";
          PUSHER_APP_KEY= "app-key";
          PUSHER_APP_SECRET= "app-secret";
        };

        # Git config
        # This config structure is just for readability
        # The actual assignments happen below
        gitConfig = {
          exclude = [
            ".envrc"
            ".direnv"
            ".pre-commit-config.yaml"
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
                    entry = "check-types-ts"; # Declared above in 'shellScripts'
                    language = "system";
                    files = "^resources/js/types\\.ts$";
                  }
                ];
              }
            ];
          };
        };

        # The actual shell config
        devShells.default = pkgs.mkShell {
          # The packages exposed to the shell
          buildInputs = with pkgs;
            shellScripts ++
          [
            # Nushell script to interact with application api
            (callPackage "${inputs.malte}/pkgs/api.nix" {})

            # You probably won't need these packages because 'env-up' should deal with them
            docker
            git
            pre-commit
            nodejs
            php83Packages.composer
          ];

          # Generate necessary files and create symlinks to them
          shellHook = ''
            # Docker needs that to function properly
            export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

            echo "Entering Laravel-Sail Dev Environment"

            # Git exclude
            try-symlink .git/info/exclude "${writeList gitConfig.exclude}" 

            # Pre commit config
            try-symlink .pre-commit-config.yaml "${writeYaml gitConfig.pre-commit-config}" 
            pre-commit install -f --hook-type pre-commit >/dev/null

            # .env setup (This can't be a symlink, laravel does not like that)
            # Also, only rewrite the .env if theres a change

            newEnvPath="${writeDotEnv dotEnv}"
            if [ ! -e ".env" ]; then
              touch .env # to make diff never fail
            fi
            if [ "$(diff $newEnvPath .env)" != "" ]; then
              echo "Updating .env"
              echo -e "$(cat $newEnvPath)" > .env
            fi
            
          '';
        };
      in
      {
        inherit devShells;
      }
    );
}