let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  network = {
    inherit pkgs;
    description = "satan";
  };

  funnel = import ./machines/funnel;
}
