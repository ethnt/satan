{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  sopsPGPKeyDirs = [ "./keys/users" "./keys/hosts" ];

  name = "satan";
  buildInputs = [
    git-crypt
    gnupg
    nixfmt
    sops
    ssh-to-pgp
    # (pkgs.callPackage <sops-nix> { }).sops-pgp-hook
  ];
}
