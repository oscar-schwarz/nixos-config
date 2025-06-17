{
  pkgs,
  lib,
  config,
  nixosConfig,
  ...
}: let
  inherit (builtins) readFile getAttr listToAttrs concatStringsSep;
  inherit (lib) pipe attrsToList flatten concatLines;
  fromYAML = import ../../lib/from-yaml.nix pkgs;

  gitAuthorKeysFromSops = pipe nixosConfig.sops.defaultSopsFile [
    readFile
    fromYAML
    (sopsFile: sopsFile.git-authors or {})
    attrsToList
    (map (getAttr "name"))
  ];
in {
  home.packages = with pkgs; [
    lazygit
    (writeShellApplication {
      name = "git-set-author";
      runtimeInputs = with pkgs; [ git fzf jq ];
      text = let 
        
      in ''
        declare -A names
        ${pipe gitAuthorKeysFromSops [
          (map (author: ''names["${author}"]=$(cat ${config.getSopsFile "git-authors/${author}/name"})''))
          concatLines
        ]}
        declare -A emails
        ${pipe gitAuthorKeysFromSops [
          (map (author: ''emails["${author}"]=$(cat ${config.getSopsFile "git-authors/${author}/email"})''))
          concatLines
        ]}

        author=$(echo -e "${
          pipe gitAuthorKeysFromSops [
            (map (author: "${author} - \${names['${author}']}"))
            (concatStringsSep "\\n")
          ]
        }" | fzf | awk '{print $1}')

        git config user.name "''${names["$author"]}"
        git config user.email "''${emails["$author"]}"
      '';
    })
  ];

  sops.secrets = pipe gitAuthorKeysFromSops [
    (map (author: [
      {
        name = "git-authors/${author}/name";
        value = {};
      }
      {
        name = "git-authors/${author}/email";
        value = {};
      }
    ]))
    flatten
    listToAttrs
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # nice cli git experience
  programs.lazygit = {
    enable = true;
    settings = {
      mouseEvents = false; # don't need no mouse
    };
  };
}
