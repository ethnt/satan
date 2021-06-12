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
    (pkgs.callPackage sops-nix { }).sops-pgp-hook
  ];

  shellHook = ''
    export AWS_ACCESS_KEY_ID=$(sops -d --extract '["aws_access_key_id"]' ./secrets.yaml)
    export AWS_SECRET_ACCESS_KEY=$(sops -d --extract '["aws_secret_access_key"]' ./secrets.yaml)
  '';
}
