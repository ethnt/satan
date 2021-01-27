let
  mkSystem = cfg: system:
    let
      pkgs = import ./nix/nixpkgs.nix {
        inherit system;

        config.allowUnfree = true;
      };
    in { lib, ... }: {
      imports = [ cfg ];
      nixpkgs = {
        pkgs = lib.mkForce pkgs;
        localSystem.system = system;
      };
    };
in {
  network = { description = "satan"; };

  funnel = mkSystem ./machines/funnel/configuration.nix "x86_64-linux";
  controller = mkSystem ./machines/controller/configuration.nix "aarch64-linux";
}
