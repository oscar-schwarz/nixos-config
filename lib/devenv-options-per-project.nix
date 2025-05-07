{
  runCommand,
  copyPathToStore,
  ...
}:
let
  inherit (builtins) elemAt readFile foldl' attrNames getEnv match replaceStrings typeOf toFile;

  flakeFilePath = (getEnv "PWD") + "/.devenv.flake.nix";

  setToString = set: "{" + (
    foldl' (acc: name: acc + "${name}=${
        if (typeOf set.${name} == "set") then
          setToString set.${name}
        else
          "\"${set.${name}}\""
      };"
    ) "" (attrNames set)
  ) + "}"; 
  
  # Building a flake.nix file from the .devenv.flake.nix:
  # -- inputs
  # as in normal flakes anything else than literal expressions are forbidden, we need to
  # evaluate the .devenv.flake.nix file to get the inputs. For some reason there's no function anywhere
  # to convert a set to a string, so we use the custom one above.
  # -- outputs 
  # we cannot evaluate the outputs normally as it uses the custom behaviour of flakes
  # so we just extract the expression for the outputs from the .devenv.flake.nix file and append it to
  # our new flake.nix. Note that we are adding a custom output "project", which is defined in the let
  # statement above in the file. It contains the necessary information about options.
  outputsSuffix = elemAt (match ".*(outputs.*$)" (readFile flakeFilePath)) 0;
  flakeFile = toFile "flake.nix" ''
    { inputs = ${setToString (import flakeFilePath).inputs};
    ${replaceStrings ["devShell ="] ["inherit project;devShell ="] outputsSuffix}
  '';
in
  # To use the above defined flake.nix file we need to create a folder for that flake in the nix store.
  # Also the devenv.nix file is needed for the flake to function (and to get the options defined!)
  # Lastly we add a default.nix with `builtins.getFlake` so that the import statement parses the flake.
  (import (runCommand "project-devenv-flake" { } ''
    mkdir -p $out
    cp ${flakeFile} $out/flake.nix
    cp ${copyPathToStore ((getEnv "PWD") + "/devenv.nix")} $out/devenv.nix
    echo "builtins.getFlake \"$out\"" > $out/default.nix
  ''))
  # This works because we exposed the output above
  .outputs.project.options