{ pkgs, sops-nix, ... }:

with pkgs;

mkShell {
  sopsPGPKeyDirs = [ "./keys/users" "./keys/hosts" ];

  name = "satan";
  nativeBuildInputs = with pkgs; [
    git-crypt
    gnupg
    nixfmt
    nixopsUnstable
    sops
    ssh-to-pgp
    terraform
    (pkgs.callPackage sops-nix { }).sops-pgp-hook
  ];
}
