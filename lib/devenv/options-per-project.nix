flake:
let
  pkgs = import flake.inputs.nixpkgs {};

  inherit (builtins) getEnv hasAttr mapAttrs getFlake readFile replaceStrings toFile;
  inherit (pkgs) runCommand copyPathToStore;
  inherit (pkgs.lib) pipe;
  inherit (pkgs.lib.attrsets) filterAttrs;
  
  devenvFlake = pipe (
    (getEnv "PWD") + "/.devenv.flake.nix"
  ) [
    # get the content
    readFile
    # little hack to include a very necessary output
    (replaceStrings ["devShell ="] ["inherit project;devShell ="])
    # transform to a file again
    (toFile "flake.nix")
    # put this file together with devenv.nix
    (file: runCommand "devenv-flake" {} ''
      mkdir -p $out
      cp ${copyPathToStore ((getEnv "PWD") + "/devenv.nix")} $out/devenv.nix
      cp ${file} $out/default.nix; # needs to be called default.nix for the import statement below
    '')
    # and evaluate as regular set
    import
  ];

  correctedInputs = pipe (
    devenvFlake.inputs
  ) [
    # Only allow inputs that have an url
    (filterAttrs (_: value: hasAttr "url" value ))
    # transform each to flake
    (mapAttrs (_: value: getFlake value.url))
  ];

in
  devenvFlake.outputs correctedInputs