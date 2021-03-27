{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  name = "satan";
  buildInputs = [ git-crypt nixfmt ];
}
