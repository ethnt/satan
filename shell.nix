{ pkgs, sops-nix, ... }:

with pkgs;

mkShell {
  sopsPGPKeyDirs = [ "./keys/users" "./keys/hosts" ];

  name = "satan";
  nativeBuildInputs = with pkgs; [
    git-crypt
    gnupg
    nixfmt
    sops
    ssh-to-pgp
    (pkgs.callPackage sops-nix { }).sops-pgp-hook
  ];
}
