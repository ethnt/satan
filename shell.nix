{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  name = "tilde";
  buildInputs = [ nixfmt git-crypt ];
}
