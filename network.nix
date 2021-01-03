let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs { };
in {
  network = {
    inherit pkgs;
    description = "satan";
  };
}
