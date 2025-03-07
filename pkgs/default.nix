{ pkgs ? import <nixpkgs> { } }:

{
  claude-code = pkgs.callPackage ./claude-code.nix { };
}
