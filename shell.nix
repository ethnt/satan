let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { };
  PWD = "${builtins.getEnv "PWD"}";
in pkgs.mkShell rec {
  name = "satan";

  buildInputs = with pkgs; [ git-crypt niv nixfmt morph ];

  shellHook = ''
    export SSH_IDENTITY_FILE="${PWD}/keys/satan"
  '';
}
