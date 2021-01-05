let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { };
in pkgs.mkShell rec {
  name = "satan";

  buildInputs = with pkgs; [ git-crypt niv nixfmt morph ];

  # shellHook = ''
  #   export NIXOPS_STATE=./opt/deployments.nixops
  #   export NIXOPS_DEPLOYMENT=satan
  # '';
}
