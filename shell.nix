{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  name = "satan";
  buildInputs = [ nixfmt git-crypt ];
}
