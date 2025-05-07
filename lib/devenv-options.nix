flake:
let
  pkgs = import flake.inputs.nixpkgs {};

  inherit (builtins) getEnv hasAttr mapAttrs getFlake readFile replaceStrings toFile pathExists;
  inherit (pkgs) runCommand copyPathToStore;
  inherit (pkgs.lib) pipe;
  inherit (pkgs.lib.attrsets) filterAttrs;
  
  # all options provided by devenv 
  devenvOptions = let 
    devenvFlake = flake.inputs.devenv;
    pkgs = import devenvFlake.nixpkgs {};
  in
  # This is copied and adapted from: 
  # https://github.com/cachix/devenv/blob/3febc91939aea65bdff8850f026443afb6b6b22f/flake.nix#L95
  (pkgs.lib.evalModules {
    modules = [
      (devenvFlake.outPath + "/src/modules/top-level.nix")
    ];
    specialArgs = {
      inherit pkgs;
      inputs = devenvFlake.inputs;
    };
  }).options;

  # The options specific for the currently openend devenv project
  projectOptions = pipe (
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

    # now we can call the outputs function, for that the inputs attrset needs to be converted to an attrset of flakes
    (flakeSet: flakeSet.outputs (
      pipe flakeSet.inputs [
        # Only allow inputs that have an url
        (filterAttrs (_: value: hasAttr "url" value ))
        # transform each to flake
        (mapAttrs (_: value: getFlake value.url))
      ]
    ))

    # lastly, we can extract the options
    (outputs: outputs.project.options)
  ];

in
  # only include general devenv options when devenv is in inputs of provided flake
  (if hasAttr "devenv" flake.inputs then devenvOptions else {})
  //
  # only include project options if we actually are in a devenv project
  (if pathExists ((getEnv "PWD") + "/.devenv.flake.nix") then projectOptions else {})
  